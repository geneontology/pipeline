[![Build Status](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/badge/icon)](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/)

# pipeline

This is the GitHub home for the declarative Jenkins pipeline for the
Gene Ontology. This pipeline is the "main" pipeline for the Gene
Ontology, currently covering synchronized ETL, QA/QC, and deployment
duties.

A standing slide set, giving an overview of the system and its
rationale, can be found here:
https://docs.google.com/presentation/d/1Te9fZZqTqYGisEdjyGbTJy-zhhJzyTi-NOxn0LWlxk8/edit?usp=sharing
.

# Development

## Basics

The pipeline and it's related development are based around the
Jenkinsfile in this repository. Our Jenkins instance is step to watch
for new branches and run them on discovery, update, or declarative
"cron" settings. Before developing and running pipelines, check with
the GO software group about issues around running, canceling, and
availability of resources.

The typical (and usually recommended) developmental flow would be to:

- make a branch of `master`
- remove "cron"
- change or remove the variables: "ZENODO\_REFERENCE\_CONCEPT", "ZENODO\_ARCHIVE\_CONCEPT", "TARGET\_BUCKET", "AWS\_CLOUDFRONT\_DISTRIBUTION\_ID", and "AWS\_CLOUDFRONT\_RELEASE\_DISTRIBUTION\_ID"
- leave the stages 'Ready and clean' and 'Initialize' in place (see: https://github.com/geneontology/pipeline/issues/145)
- remove or alter as needed to run experiments

Code that successfully goes through development on a branch will
graduate to being added to `master`. Once successful there, graduate
out the the other branches (see below).

For the sake of data safety, please check with the GO software group
before undertaking pipeline development.

## Data load

Ideally (and with very narrow exceptions), all pipeline code should be
able to run any arbitrary subset of ontologies or GAF (or GO-CAM
model) input, including doctored, reduced, or inflated files, as given
in the metadata stanza. The exceptions are largely carved out to
archive and deployment steps.

This is in order to ensure both code robustness and ease of
development for data experiments and variations.

## Functional branches

These are the current branches in the pipeline that server special
duties. All other branches should be development or experiment-only.

It should be noted that unless a change is percolating out from
testing, the "code" in `master`, `snapshot`, and `release` is
identical--only the "environment" (metadata) stanza should ever be
different.

### master

The main development and fast testing branch. It has no public exposure worth mentioning, but contains the same code as snapshot and release.

### snapshot

This runs about once a day (although is having issues at the moment https://github.com/orgs/geneontology/projects/149), automatically feeding snapshot.go.org. This is a matched set of annotation/GO-CAM data and an ontology build. It has no version, but can act as an un-QCed current state of the GO data for specifc types of users.

### release

This runs about once a month (although is having issues at the moment https://github.com/orgs/geneontology/projects/149), automatically feeding current.go.org and
release.go.org. This is a matched set of annotation/GO-CAM data and an ontology build. It has both a dated version and a DOI; it has been automatically and manually QCed to ensure no oddities.

This pipeline automatically feeds the "staging" version of AmiGO for testing, but requires a manual deployment to AmiGO once the release is finalized.

### issue-35-neo-test

This runs about once a week, Wednesday morning, unless manually triggered. Its purpose is to keep the noctua-golr endpoint (curation systems) up-to-date, where it requires a manual deployment. It produces a "super ontology", of both GO and NEO (all editable entities in the GO cinematic universe), which is realized as a Solr index. In addition to this, it produces go-lego-reacto.owl (used by minerva) and blazegraph-go-lego-reacto-neo.jnl.gz (also used by minerva), which are minerva file default locations.

### issue-go-site-1530-summary-emails

This runs daily at 4pm and sends the summary emails.
This branch is (ideally) temporary, while we work on migrating cron-based emails to GHA (see https://github.com/geneontology/go-site/issues/1530).

### issue-265-go-cam-products

This branch is (ideally) temporary. It creates JSON files for consumption by the GO-CAM API, and is run manually as part of the release process.

### go-ontology-dev

This is a standing branch that runs the entire ontology build, as part of an extended QC, as GH checks are quite narrow. If it passes, the product is pushed out to https://ontology-build.geneontology.org, for curation sites and other places that want the latest ontology, but cannot produce it themselves. It has no version.

(NOTE: Previously, this was a standing branch that we wanted to use in the future to test changes to the full ontology build without disrupting the other branches. For this, it is pared down to just setup and the ontology build and is tied to the `dev` branch of go-ontology.)

### noctua-models-migrations

This standing branch is used to simulate what an ontology update looks like from minerva's perspective WRT obsoletions, etc. The migration is simulated against the products produced by `issue-265-go-cam-products`.

# Quality control/assurance

## Manual QC steps
There is a step in the pipeline that halts the pipeline: https://build.geneontology.org/job/geneontology/job/pipeline/job/release/
Currently pgaudet is reponsible for checking the release. Notes for the checks are here: https://docs.google.com/document/d/1IMA54ycbHZxkFbIAyjRvzm_ybAaAj2V8q-Q670mE07U/edit#

Products are here: http://skyhook.berkeleybop.org/release/
AmiGO is here: https://amigo-staging.geneontology.io/amigo

Anomalies are evaluated, reported to the upstream sources and fixed, or ignored if the problem is no worse than the previous release.

# Run finalization

After a successful run, a manual "finalization" needs to be completed. See https://github.com/geneontology/operations/blob/master/README.pipeline-finalization.md .

# Troubleshooting deployment (TODO: likely needs updating)

## Manual finalization from Zenodo failure

This checklist can be used to manually finish a release that has
unrecoverably failed while operating with Zenodo. See worknotes for 2021-07-07 for last go through and changes.

- [ ] Go to zenodo for concept/last
- [ ] Discard if anything is open
- [ ] Get the date of the run and the run number to attach it to. For this example:
	- Date: 2020-04-23
	- Build number: 163
- [ ] query-replace the numbers above with the old ones from these instructions
- [ ] become jenkins user (to be able to write output files)
- [ ] get the releases into zenodo in `jenkins@wok:~/workspace/neontology\_pipeline\_release-L3OLSRDNGI3ZIUODKFYUI4AO45X5C6RUGMOQAC5WV2Q6ZQOIFHMA/go-site$`
	```bash
	time python3 ./scripts/zenodo-version-update.py --verbose --key OJBR7cntKKysaXiWHkoVdwVCZp4eoMyGC5a84OnykTMUROmLIOzXN3TiEEsU --concept 1205166 --file go-release-archive.tgz --output ./release-archive-doi.json --revision 2020-04-23
	```
	success
	```bash
	time python3 ./scripts/zenodo-version-update.py --verbose --key OJBR7cntKKysaXiWHkoVdwVCZp4eoMyGC5a84OnykTMUROmLIOzXN3TiEEsU --concept 1205159 --file go-release-reference.tgz --output ./release-reference-doi.json --revision 2020-04-23
	```
	success
- [ ] get DOIs and ensure in files as needed
      ```bash
      cat release-reference-doi.json
      ```
      ```json
      {
       "doi": "10.5281/zenodo.3765935"
      }
      ```
      ```bash
      cat release-archive-doi.json
      ```
      ```json
      {
       "doi": "10.5281/zenodo.3765910"
      }
      ```
- [ ] get a working "mount" in place"
      pre, on local machine:
      ```bash
      scp -i KEY_SKY S3_FILE key2 bbop@build.geneontology.org:/tmp
      ```
      main, on pipeline machine:
      ```bash
      mkdir -p /tmp/workspace
      ```
      ```bash
      mkdir -p /tmp/workspace/mnt/
      ```
      ```bash
      scp -r -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=/tmp/KEY_SKY skyhook@skyhook.berkeleybop.org:/home/skyhook/release /tmp/workspace/mnt/
      ```
      ```bash
      cp release-archive-doi.json /tmp/workspace/mnt/release/metadata/
      ```
      ```bash
      cp release-reference-doi.json /tmp/workspace/mnt/release/metadata/
      ```
- [ ] manual run of release publish stage
  Ready:
  ```
  pip3 install --user filechunkio boto3
  ```
  Get build number: 163
  Get date: 2020-04-23
- [ ] Current:
  ```
  python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory /tmp/workspace/mnt/release --prefix http://current.geneontology.org -x
  ```
  ```
  python3 ./scripts/s3-uploader.py -v --credentials /tmp/aws-go-push.json --directory /tmp/workspace/mnt/release/ --bucket go-data-product-current --number 163 --pipeline release
  ```
- [ ] Release sub-level:
  ```
  python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory /tmp/workspace/mnt/release --prefix http://release.geneontology.org/2020-04-23 -x -u
  ```
  ```
  python3 ./scripts/s3-uploader.py -v --credentials /tmp/aws-go-push.json --directory /tmp/workspace/mnt/release/ --bucket go-data-product-release/2020-04-23 --number 163 --pipeline release
  ```
- [ ] New top-level index.html for release:
  ```
  python3 ./scripts/bucket-indexer.py --credentials /tmp/aws-go-push.json --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html
  ```
  ```
  s3cmd -c /tmp/S3_FILE --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html
  ```
- [ ] manually run invalidations
  - [ ] current
  - [ ] release, top and inner
- [ ] test
  - [ ] http://current.geneontology.org
  - [ ] http://release.geneontology.org
