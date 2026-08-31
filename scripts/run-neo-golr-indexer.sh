#!/usr/bin/env bash
####
#### NEO GOlr index build: start the in-container Solr, run the
#### owltools flex load, gate on doc count, package and upload to
#### skyhook. Replaces the image-baked /tmp/run-indexer.sh as the
#### body of the GOlr portion of the "Produce derivatives" stage.
####
#### Runs INSIDE geneontology/golr-autoindex-ontology (Java 10,
#### jetty9, Solr 3.6). Fetched fresh from this branch at stage
#### start, so a script fix plus "Restart from Stage" takes effect
#### without an image rebuild (pattern from pipeline-from-goa).
####
#### PRE: GOLR_INPUT_ONTOLOGIES, SANITY_SOLR_DOC_COUNT_MIN, and
####   BRANCH_NAME are set by the Jenkinsfile; SKYHOOK_IDENTITY is
####   the skyhook ssh key file (withCredentials); /srv/solr/data is
####   a tmpfs mount; WORKSPACE is host-mounted (GC logs written
####   there survive the container).
#### POST (success): rolling artifact golr-index-contents.tgz +
####   golr_timestamp.log + GC logs under
####   skyhook:$BRANCH_NAME/products/solr/.
#### POST (failure): nonzero exit at the failing step; whatever
####   index exists is uploaded as golr-index-contents.FAILED.tgz --
####   inspectable per geneontology/neo#118 -- and the rolling
####   artifact is left untouched.
####
#### SKIP_UPLOAD=1 skips every skyhook push (local testing).
####

set -euo pipefail

## Fail early with names, not set -u stack noise.
: "${GOLR_INPUT_ONTOLOGIES:?set by Jenkinsfile environment}"
: "${SANITY_SOLR_DOC_COUNT_MIN:?set by Jenkinsfile environment}"
: "${BRANCH_NAME:?set by Jenkins}"
if [ "${SKIP_UPLOAD:-}" != "1" ]; then
    : "${SKYHOOK_IDENTITY:?skyhook ssh key; wrap in withCredentials}"
fi

## CAVEAT: bigger is not safer for the Solr heap -- an oversized
## fixed heap makes worst-case GC/swap pauses long enough that the
## loader's TCP connection dies (~15-30 min kernel give-up) while
## Solr itself survives. The index is a few GB; right-size it.
SOLR_MEM=${GOLR_SOLR_MEMORY:-32G}
LOADER_MEM=${GOLR_LOADER_MEMORY:-32G}
## Loader floor deliberately below the ceiling: committing the full
## ceiling up front (-Xms == -Xmx) starves the rest of the box when
## several branches build at once.
LOADER_XMS=${GOLR_LOADER_XMS:-64G}
WORK=${WORKSPACE:-/tmp}
SKYHOOK_DEST="skyhook@skyhook.berkeleybop.org:/home/skyhook/${BRANCH_NAME}/products/solr/"

## Upload one or more files to the skyhook products/solr dir, 3
## attempts each invocation.
push_retry() {
    if [ "${SKIP_UPLOAD:-}" = "1" ]; then
        echo "SKIP_UPLOAD=1; not pushing: $*"
        return 0
    fi
    local i
    for i in 1 2 3; do
        if rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" "$@" "$SKYHOOK_DEST"; then
            return 0
        fi
        echo "upload attempt $i/3 failed: $*"
        sleep 15
    done
    return 1
}

## On any failure: preserve the partial index and the GC evidence,
## then propagate the original exit code. Never touches the rolling
## artifact name, so consumers cannot pick up a partial index.
on_exit() {
    local status=$?
    [ "$status" -eq 0 ] && return 0
    set +e
    echo "FAILED (exit $status); capturing partial index and GC logs for inspection."
    tar --use-compress-program=pigz -cf /tmp/golr-index-contents.FAILED.tgz -C /srv/solr/data/index . || true
    push_retry /tmp/golr-index-contents.FAILED.tgz || true
    push_retry "$WORK"/golr-gc-*.log* || true
    exit "$status"
}
trap on_exit EXIT

echo "Starting jetty/solr (heap $SOLR_MEM)"
cd /usr/share/jetty9
java -Xms"$SOLR_MEM" -Xmx"$SOLR_MEM" \
     -XX:+UseG1GC -XX:MaxGCPauseMillis=500 \
     "-Xlog:gc*:file=$WORK/golr-gc-solr.log:time,uptime:filecount=3,filesize=50m" \
     -DentityExpansionLimit=8172000 \
     -Djava.awt.headless=true \
     -Dsolr.solr.home=/srv/solr \
     -Djava.io.tmpdir=/tmp/jetty9 \
     -Djava.library.path=/usr/lib \
     -Djetty.home=/usr/share/jetty9 \
     -Djetty.logs=/var/log/jetty9 \
     -Djetty.state=/tmp/jetty.state \
     -Djetty.host=0.0.0.0 \
     -Djetty.port=8080 \
     -jar /usr/share/jetty9/start.jar --daemon etc/jetty-logging.xml etc/jetty-started.xml &

echo "Launched, waiting for server response"
## Query-level readiness, not just a TCP bind.
COUNTER=0
while ! curl -sf 'http://localhost:8080/solr/select?q=*:*&rows=0' > /dev/null; do
    sleep 2
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -gt 60 ]; then
        echo "Solr not answering queries on 8080 after 120s"
        exit 1
    fi
done
echo "Solr answering queries on 8080"

echo "Running owltools loader (heap $LOADER_XMS..$LOADER_MEM)"
# GOLR_INPUT_ONTOLOGIES is deliberately unquoted: a
# whitespace-separated URL list.
java \
    -Xms"$LOADER_XMS" \
    -Xmx"$LOADER_MEM" \
    "-Xlog:gc*:file=$WORK/golr-gc-loader.log:time,uptime:filecount=3,filesize=50m" \
    -DentityExpansionLimit=8172000 \
    -Djava.awt.headless=true \
    -jar /srv/amigo/java/lib/owltools-runner-all.jar \
    $GOLR_INPUT_ONTOLOGIES \
    --log-info \
    --solr-config /srv/amigo/metadata/ont-config.yaml \
    --merge-support-ontologies \
    --merge-imports-closure \
    --remove-subset-entities upperlevel \
    --remove-disjoints \
    --silence-elk \
    --reasoner elk \
    --solr-taxon-subset-name amigo_grouping_subset \
    --solr-eco-subset-name go_groupings \
    --solr-url http://localhost:8080/solr/ \
    --solr-log /tmp/golr_timestamp.log \
    --solr-load-ontology \
    --solr-load-ontology-general \
    --solr-optimize

## A completed load writes the timestamp log; its absence means the
## loader lied about succeeding.
test -f /tmp/golr_timestamp.log

## Gate on doc count BEFORE packaging or upload. A non-numeric or
## multi-match read must fail the gate, not slide past `[ -gt ]`.
DOCS=$(curl -s 'http://localhost:8080/solr/select?q=*:*&rows=0&wt=json' | grep -oh '"numFound":[[:digit:]]*' | grep -oh '[[:digit:]]*')
echo "numFound: $DOCS (SANITY_SOLR_DOC_COUNT_MIN: $SANITY_SOLR_DOC_COUNT_MIN)"
if ! [[ "$DOCS" =~ ^[0-9]+$ ]]; then
    echo "Could not read a single doc count from Solr (got: '$DOCS')"
    exit 1
fi
if [ "$SANITY_SOLR_DOC_COUNT_MIN" -gt "$DOCS" ]; then
    echo "Doc count $DOCS below minimum $SANITY_SOLR_DOC_COUNT_MIN"
    exit 1
fi

echo "Packaging and uploading index"
tar --use-compress-program=pigz -cf /tmp/golr-index-contents.tgz -C /srv/solr/data/index .
## GC logs ride along as the baseline for future stall forensics;
## best-effort.
push_retry /tmp/golr_timestamp.log
push_retry "$WORK"/golr-gc-*.log* || true
## INVARIANT: the rolling tarball uploads last -- rsync replaces it
## atomically on complete transfer, making it the run's commit
## point; everything before it is advisory metadata.
push_retry /tmp/golr-index-contents.tgz

echo "GOlr index build complete"
