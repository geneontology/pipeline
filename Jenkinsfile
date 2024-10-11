pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    triggers {
	// Master never runs--Feb 31st.
	cron('0 0 31 2 *')
	// Nightly @12am, for "snapshot", skip "release" night.
	//cron('0 0 2-31/2 * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
    }
    environment {

	///
	/// Internal run variables.
	///

	// The branch of geneontology/go-site to use.
	TARGET_GO_SITE_BRANCH = 'master'
	// The branch of geneontology/go-stats to use.
	TARGET_GO_STATS_BRANCH = 'master'
	// The branch of go-ontology to use.
	TARGET_GO_ONTOLOGY_BRANCH = 'master'
	// The branch of minerva to use.
	TARGET_MINERVA_BRANCH = 'master'
	// The branch of ROBOT to use in one silly section.
	// Necessary due to java version jump.
	// https://github.com/ontodev/robot/issues/997
	TARGET_ROBOT_BRANCH = 'master'
	// The branch of noctua-models to use.
	TARGET_NOCTUA_MODELS_BRANCH = 'master'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	// TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	// TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,suzia@stanford.edu,smoxon@lbl.gov'
	// TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,pascale.gaudet@sib.swiss,pgaudet1@gmail.com,smoxon@lbl.gov'
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov'
	// The file bucket(/folder) combination to use.
	//TARGET_BUCKET = 'go-data-product-snapshot'
	TARGET_BUCKET = 'go-data-TBD'
	// The URL prefix to use when creating site indices.
	//TARGET_INDEXER_PREFIX = 'http://snapshot.geneontology.org'
	TARGET_INDEXER_PREFIX = 'null'
	// This variable should typically be 'TRUE', which will cause
	// some additional basic checks to be made. There are some
	// very exotic cases where these check may need to be skipped
	// for a run, in that case this variable is set to 'FALSE'.
	WE_ARE_BEING_SAFE_P = 'TRUE'
	// Sanity check for solr index being built--overall min count.
	// See https://github.com/geneontology/pipeline/issues/315 .
	// Only used on release attempts (as it saves QC time and
	// getting the number for all branches would be a trick).
	SANITY_SOLR_DOC_COUNT_MIN = 11000000
	SANITY_SOLR_BIOENTITY_DOC_COUNT_MIN = 1400000
	// Control make to get through our loads faster if
	// possible. Assuming we're cpu bound for some of these...
	// wok has 48 "processors" over 12 "cores", so I have no idea;
	// let's go with conservative and see if we get an
	// improvement.
	MAKECMD = 'make --jobs --max-load 12.0'
	//MAKECMD = 'make'

	///
	/// PANTHER/PAINT metadata.
	///

	PANTHER_VERSION = '19.0'

	///
	/// Application tokens.
	///

	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
	//ZENODO_ARCHIVE_CONCEPT = '425666'
	ZENODO_ARCHIVE_CONCEPT = 'null'
	// Distribution ID for the AWS CloudFront for this branch,
	// used soley for invalidations. Versioned release does not
	// need this as it is always a new location and the index
	// upload already has an invalidation on it. For current,
	// snapshot, and experimental.
	//AWS_CLOUDFRONT_DISTRIBUTION_ID = 'E3UPPWY0HYLLL2'
	//AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'E2HF1DWYYDLTQP'
	AWS_CLOUDFRONT_DISTRIBUTION_ID = 'null'
	AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'null'

	///
	/// Ontobio Validation
	///
	// WARNING: This will need to be changed.
	VALIDATION_ONTOLOGY_URL="http://snapshot.geneontology.org/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	// WARNING: This will need to be changed.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://snapshot.geneontology.org/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/snapshot/ontology/extensions/go-amigo.owl"
	].join(" ")
	// WARNING: hard-coded for the moment.
	GOLR_INPUT_GAFS = [
	    "http://skyhook.berkeleybop.org/confinement-for-pipeline-388/union.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://snapshot.geneontology.org/products/panther/arbre.tgz"
	].join(" ")

	///
	/// Groups to run and tests to avoid running during the current
	/// mega-make.
	///

	// The gorule tag is used to identify which rules to suppress
	// reports from during the megastep and during templating the
	// reports after the megastep. The tags are currently
	// respected at two times in the pipeline: the gorules report
	// take the flag as a CLI argument, supressing it; ontobio
	// takes it during the same stage as the JSON
	// generation/parsing step, to supress the .md output. At this
	// time, this variable can be either nothing or empty string
	// for no rule suppression (default behavior everything), or a
	// single value (practically speaking pretty much always
	// "silent")
	GORULE_TAGS_TO_SUPPRESS="silent"

	// Optional. Groups to run.
	//RESOURCE_GROUPS=""
	// Optional. Datasets to skip within the resources that we
	// will run (defined in the line above).
	//DATASET_EXCLUDES=""
	// Optional. This acts as an override, /if/ it's grabbed (as
	// defined above).
	//GOA_UNIPROT_ALL_URL=""

    }
    options{
	timestamps()
	buildDiscarder(logRotator(numToKeepStr: '14'))
    }
    stages {
	// Very first: pause for a few minutes to give a chance to
	// cancel and clean the workspace before use.
	stage('Ready and clean') {
	    steps {

		// Check to make sure we have coherent metadata so we
		// don't clobber good products.
		watchdog();

		// Give us a minute to cancel if we want.
		sleep time: 1, unit: 'MINUTES'
		cleanWs deleteDirs: true, disableDeferredWipeout: true
	    }
	}

	stage('Initialize') {
	    steps {

		///
		/// Automatic run variables.
		///

		// Pin dates and day to beginning of run.
		script {
		    env.START_DATE = sh (
			script: 'date +%Y-%m-%d',
			returnStdout: true
		    ).trim()

		    env.START_DAY = sh (
			script: 'date +%A',
			returnStdout: true
		    ).trim()
		}

		// Reset base.
		initialize();

		sh 'env > env.txt'
		sh 'echo $BRANCH_NAME > branch.txt'
		sh 'echo "$BRANCH_NAME"'
		sh 'cat env.txt'
		sh 'cat branch.txt'
		sh 'echo $START_DAY > dow.txt'
		sh 'echo "$START_DAY"'
		sh 'echo $START_DATE > date.txt'
		sh 'echo "$START_DATE"'
	    }
	}

	// stage('TTL pathways package') {
	//     steps {
	// 	script {

	// 	    // Setup repo.
	// 	    dir('./sparql-for-pathway-go-cams') {
	// 		// Remember that git lays out into CWD.
	// 		git branch: 'main', url: 'https://github.com/geneontology/sparql-for-pathway-go-cams.git'

	// 		// Get production blazegraph.
	// 		sh 'rm -f blazegraph-production.jnl || true'
	// 		sh 'rm -f blazegraph-production.jnl.gz || true'
	// 		sh 'wget -N http://skyhook.berkeleybop.org/snapshot/products/blazegraph/blazegraph-production.jnl.gz'
	// 		sh 'gunzip blazegraph-production.jnl.gz'

	// 		// Get noctua-models checkout.
	// 		sh 'pwd'
	// 		sh 'ls -AlFrt'
	// 		// Change check method to address
	// 		// https://github.com/geneontology/go-site/issues/2336.
	// 		sh "git clone --no-tags --depth=1 -b $TARGET_NOCTUA_MODELS_BRANCH https://github.com/geneontology/noctua-models.git"

	// 		// Debug check.
	// 		sh 'env'
	// 		sh 'pwd'
	// 		sh 'ls -AlFrt'

	// 		sh 'NOCTUA_MODELS_PATH=./noctua-models make target/pathway-like_go-cams.tar.gz'

	// 		// Port files out to skyhook snapshot.
	// 		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
	// 		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY target/pathway-like_go-cams.tar.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/ttl/pathway-like_go-cams.tar.gz'
	// 		}
	// 	    }
	// 	}
	//     }
	// }

	//...
	stage('Produce derivatives (*)') {
	    agent {
		docker {
		    image 'geneontology/golr-autoindex:28a693d28b37196d3f79acdea8c0406c9930c818_2022-03-17T171930_master'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root --mount type=tmpfs,destination=/srv/solr/data'
		}
	    }
	    // CHECKPOINT: Recover key environmental variables.
	    environment {
		START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/derivatives-from-goa/metadata/dow.txt', , returnStdout: true).trim()
		START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/derivatives-from-goa/metadata/date.txt', , returnStdout: true).trim()
	    }

	    steps {

		// Build index into tmpfs.
		sh 'bash /tmp/run-indexer.sh'

		// Immediately check to see if it looks like we have
		// enough docs when trying a
		// release. SANITY_SOLR_DOC_COUNT_MIN must be greater
		// than what we seen in the index.
		script {
		    if( env.BRANCH_NAME == 'release' ){

			// Test overall.
			echo "SANITY_SOLR_DOC_COUNT_MIN:${env.SANITY_SOLR_DOC_COUNT_MIN}"
			sh 'curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json"'
			sh 'if [ $SANITY_SOLR_DOC_COUNT_MIN -gt $(curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json" | grep -oh \'"numFound":[[:digit:]]*\' | grep -oh [[:digit:]]*) ]; then exit 1; else echo "We seem to be clear wrt doc count"; fi'

			// Test bioentity.
			echo "SANITY_SOLR_BIOENTITY_DOC_COUNT_MIN:${env.SANITY_SOLR_BIOENTITY_DOC_COUNT_MIN}"
			sh 'curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json&fq=document_category:bioentity"'
			sh 'if [ $SANITY_SOLR_BIOENTITY_DOC_COUNT_MIN -gt $(curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json&fq=document_category:bioentity" | grep -oh \'"numFound":[[:digit:]]*\' | grep -oh [[:digit:]]*) ]; then exit 1; else echo "We seem to be clear wrt doc count"; fi'
		    }
		}

		// Copy tmpfs Solr contents onto skyhook.
		sh 'tar --use-compress-program=pigz -cvf /tmp/golr-index-contents.tgz -C /srv/solr/data/index .'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // Copy over index.
		    // Copy over log.
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/products/solr/'
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/products/solr/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/products/solr/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/products/solr/'
		}

		// Solr should still be running in the background here
		// from indexing--create stats products from running
		// GOlr.
		// Prepare a working directory based around go-site.
		dir('./go-stats') {
		    git branch: TARGET_GO_STATS_BRANCH, url: 'https://github.com/geneontology/go-stats.git'

		    // Not much want or need here--simple
		    // python3. However, using the information hidden
		    // in run-indexer.sh to know where the Solr
		    // instance is hiding.
		    sh 'mkdir -p /tmp/stats/ || true'
		    sh 'cp ./libraries/go-stats/*.py /tmp'
		    // Needed as extra library.
		    sh 'pip3 install --force-reinstall requests==2.19.1'
		    sh 'pip3 install --force-reinstall networkx==2.2'

		    // Final command, sealed into docker work
		    // environment.
		    echo "Check that results have been stored properly"
		    sh "curl 'http://localhost:8080/solr/select?q=*:*&rows=0'"
		    echo "End of results"
		    retry(3){
			sh 'python3 /tmp/go_reports.py -g http://localhost:8080/solr/ -s http://current.geneontology.org/release_stats/go-stats.json -n http://current.geneontology.org/release_stats/go-stats-no-pb.json -c http://snapshot.geneontology.org/ontology/go.obo -p http://current.geneontology.org/ontology/go.obo -r http://current.geneontology.org/release_stats/go-references.tsv -o /tmp/stats/ -d $START_DATE'
		    }
		    retry(3) {
		    	sh 'wget -N http://current.geneontology.org/release_stats/aggregated-go-stats-summaries.json'
		    }

		    // Roll the stats forward.
		    sh 'python3 /tmp/aggregate-stats.py -a aggregated-go-stats-summaries.json -b /tmp/stats/go-stats-summary.json -o /tmp/stats/aggregated-go-stats-summaries.json'

		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    	retry(3) {
			    // Copy over stats files.
			    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/stats/* skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/release_stats/'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/stats/* skyhook@skyhook.berkeleybop.org:/home/skyhook/derivatives-from-goa/release_stats/'
			}
		    }
		}
	    }
	}

	// //...
	// stage('Sanity II') {
	//     when { anyOf { branch 'release' } }
	//     steps {

	// 	//
	// 	echo 'Push pre-release to http://amigo-staging.geneontology.io for testing.'

	// 	// Ninja in our file credentials from Jenkins.
	// 	withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY'), file(credentialsId: 'go-svn-private-key', variable: 'GO_SVN_IDENTITY'), file(credentialsId: 'ansible-bbop-local-slave', variable: 'DEPLOY_LOCAL_IDENTITY'), file(credentialsId: 'go-aws-ec2-ansible-slave', variable: 'DEPLOY_REMOTE_IDENTITY')]) {

	// 	    // Get our operations code and decend into ansible
	// 	    // working directory.
	// 	    dir('./operations') {

	// 		git([branch: 'master',
	// 		     credentialsId: 'bbop-agent-github-user-pass',
	// 		     url: 'https://github.com/geneontology/operations.git'])
	// 		dir('./ansible') {

	// 		    retry(3){
	// 			sh 'ansible-playbook update-golr-w-skyhook-forced.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e skyhook_branch=release -e target_host=amigo-golr-staging'
	// 		    }

	// 		    // Pause on user input.
	// 		    echo 'Sanity II: Awaiting user input before proceeding.'
	// 		    emailext to: "${TARGET_RELEASE_HOLD_EMAILS}",
	// 			subject: "GO Pipeline waiting on input for ${env.BRANCH_NAME}",
	// 			body: "The ${env.BRANCH_NAME} pipeline is waiting on user input. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
	// 		    lock(resource: 'release-run', inversePrecedence: true) {
	// 			echo "Sanity II: A release run holds the lock."
	// 			timeout(time:7, unit:'DAYS') {
	// 			    input message:'Approve release products?'
	// 			}
	// 		    }
	// 		    echo 'Sanity II: Positive user input input given.'
	// 		}
	// 	    }
	// 	}
	// 	// Temporary stop here so that we can have an index to
	// 	// examine for data issues before going with "full"
	// 	// snapshot. 2024-07-15.
	// 	echo 'Only master can touch that target.'
	// 	sh '`exit -1`'
	//     }
	// }

	// stage('Archive (*)') {
	//     // CHECKPOINT: Recover key environmental variables.
	//     environment {
	// 	START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/dow.txt', , returnStdout: true).trim()
	// 	START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/date.txt', , returnStdout: true).trim()
	//     }

	//     when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	//     steps {
	// 	// Experimental stanza to support mounting the sshfs
	// 	// using the "hidden" skyhook identity.
	// 	sh 'mkdir -p $WORKSPACE/mnt/ || true'
	// 	withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
	// 	    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'

	// 	    // Try to catch and prevent goa_uniprot_all-src
	// 	    // from getting into zenodo archive, etc. Re:
	// 	    // #207.
	// 	    sh 'pwd'
	// 	    sh 'ls -AlF $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/ || true'
	// 	    sh 'rm -f $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/goa_uniprot_all-src.gaf.gz || true'
	// 	    sh 'ls -AlF $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/ || true'

	// 	    // Redo goa_uniprot_all names for publication. From:
	// 	    // https://github.com/geneontology/go-site/issues/1984
	// 	    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all.gaf.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all.gaf.gz || true'
	// 	    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gaf.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gaf.gz || true'
	// 	    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gpad.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gpad.gz || true'
	// 	    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gpi.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gpi.gz || true'

	// 	    // Get annotation download directory prepped. From:
	// 	    // https://github.com/geneontology/go-site/issues/1971
	// 	    sh 'rm -f README-annotation-downloads.txt || true'
	// 	    sh 'wget -N https://raw.githubusercontent.com/geneontology/go-site/$TARGET_GO_SITE_BRANCH/static/pages/README-annotation-downloads.txt'
	// 	    sh 'mv README-annotation-downloads.txt $WORKSPACE/mnt/snapshot/annotations/README.txt || true'

	// 	    // Try and remove /lib and /bin from getting into
	// 	    // the archives by removing them now that we're
	// 	    // done using them for product builds. Re: #268.
	// 	    sh 'ls -AlF $WORKSPACE/mnt/snapshot/'
	// 	    sh 'rm -r -f $WORKSPACE/mnt/snapshot/bin || true'
	// 	    sh 'rm -r -f $WORKSPACE/mnt/snapshot/lib || true'
	// 	    sh 'ls -AlF $WORKSPACE/mnt/snapshot/'
	// 	}
	// 	// Copy the product to the right location. As well,
	// 	// archive.
	// 	withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'zenodo_go_production_token', variable: 'ZENODO_PRODUCTION_TOKEN'), string(credentialsId: 'zenodo_go_sandbox_token', variable: 'ZENODO_SANDBOX_TOKEN')]) {
	// 	    // Ready...
	// 	    dir('./go-site') {
	// 		git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

	// 		// WARNING: Caveats and reasons as same
	// 		// pattern above. We need this as some clients
	// 		// are not standard and it turns out there are
	// 		// some subtle incompatibilities with urllib3
	// 		// and boto in some versions, so we will use a
	// 		// virtual env to paper that over.  See:
	// 		// https://github.com/geneontology/pipeline/issues/8#issuecomment-356762604
	// 		sh 'python3 -m venv mypyenv'
	// 		withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

	// 		    // Extra package for the indexer.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'

	// 		    // Correct for (possibly) bad boto3,
	// 		    // as mentioned above.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install boto3==1.18.52'
	// 		    sh 'python3 ./mypyenv/bin/pip3 install botocore==1.21.52'

	// 		    // Needed to work around new incompatibility:
	// 		    // https://github.com/geneontology/pipeline/issues/286
	// 		    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall certifi==2021.10.8'

	// 		    // Extra package for the uploader.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

	// 		    // Grab BDBag.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install bdbag'

	// 		    // Need for large uploads in requests.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install requests-toolbelt'

	// 		    // Need as replacement for awful requests lib.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install pycurl'

	// 		    // Apparently something wrong with default
	// 		    // version; error like
	// 		    // https://stackoverflow.com/questions/45821085/awshttpsconnection-object-has-no-attribute-ssl-context
	// 		    sh 'python3 ./mypyenv/bin/pip3 install awscli'

	// 		    // A temporary workaround for
	// 		    // https://github.com/geneontology/pipeline/issues/247,
	// 		    // forcing requests used by bdbags to a
	// 		    // verion that is usable by python 3.5
	// 		    // (our current raw machine default
	// 		    // version of python3).
	// 		    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall requests==2.25.1'

	// 		    // Well, we need to do a couple of things here in
	// 		    // a structured way, so we'll go ahead and drop
	// 		    // into the scripting mode.
	// 		    script {

	// 			// Build either a release or testing
	// 			// version of a generic BDBag/DOI
	// 			// workflow, keeping special bucket
	// 			// mappings in mind.
	// 			if( env.BRANCH_NAME == 'release' ){
	// 			    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/snapshot/ --remote http://release.geneontology.org/$START_DATE --output manifest.json'
	// 			}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'snapshot-post-fail' ){
	// 			    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/snapshot/ --remote $TARGET_INDEXER_PREFIX --output manifest.json'
	// 			}

	// 			// To make a full BDBag, we first need
	// 			// a copy of the data as BDBags change
	// 			// directory layout (e.g. data/).
	// 			sh 'mkdir -p $WORKSPACE/copyover/ || true'
	// 			sh 'cp -r $WORKSPACE/mnt/snapshot/* $WORKSPACE/copyover/'
	// 			// Make the BDBag in the copyover/
	// 			// (unarchived, as we want to leave it
	// 			// to pigz).
	// 			sh 'python3 ./mypyenv/bin/bdbag $WORKSPACE/copyover'
	// 			// Tarball the whole directory for
	// 			// "deep" archive (handmade BDBag).
	// 			sh 'tar --use-compress-program=pigz -cvf go-release-archive.tgz -C $WORKSPACE/copyover .'

	// 			// We have the archives, now let's try
	// 			// and get them into position--this is
	// 			// fail-y, so we are going to try and
	// 			// buffer failure here for the time
	// 			// being until we work it all out. We
	// 			// are going to do the "hard"/large
	// 			// one first, then skip the
	// 			// "easy"/small one if we fail, so
	// 			// that we can retry this whole stage
	// 			// again on failure.
	// 			try {
	// 			    // Archive full archive.
	// 			    if( env.BRANCH_NAME == 'release' ){
	// 				sh 'python3 ./scripts/zenodo-version-update.py --verbose --key $ZENODO_PRODUCTION_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
	// 			    }else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){
	// 				// WARNING: to save Zenodo 1TB
	// 				// a month, for snapshot,
	// 				// we'll lie about the DOI
	// 				// that we get (not a big lie
	// 				// as they don't resolve on
	// 				// sandbox anyways).
	// 				//sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
	// 				sh 'echo \'{\' > ./release-archive-doi.json'
	// 				sh 'echo \'    "doi": "10.5072/zenodo.000000"\' >> ./release-archive-doi.json'
	// 				sh 'echo \'}\' >> ./release-archive-doi.json'

	// 			    }else if( env.BRANCH_NAME == 'master' ){
	// 				sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
	// 			    }

	// 			    // Get the DOI to skyhook for
	// 			    // publishing, but don't bother
	// 			    // with the full thing--too much
	// 			    // space and already in Zenodo.
	// 			    sh 'cp release-archive-doi.json $WORKSPACE/mnt/snapshot/metadata/release-archive-doi.json'

	// 			} catch (exception) {
	// 			    // Something went bad with the
	// 			    // Zenodo archive upload.
	// 			    echo "There has been a failure in the archive upload to Zenodo."
	// 			    emailext to: "${TARGET_ADMIN_EMAILS}",
	// 				subject: "GO Pipeline Zenodo archive upload fail for ${env.BRANCH_NAME}",
	// 				body: "There has been a failure in the archive upload to Zenodo, in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
	// 			    // Hard die if this is a release.
	// 			    if( env.BRANCH_NAME == 'release' ){
	// 				error 'Zenodo archive upload error on release--no recovery.'
	// 			    }
	// 			}
	// 		    }
	// 		}
	// 	    }
	// 	}
	//     }
	//     // WARNING: Extra safety as I expect this to sometimes fail.
	//     post {
	// 	always {
	// 	    // Bail on the remote filesystem.
	// 	    sh 'fusermount -u $WORKSPACE/mnt/ || true'
	// 	    // Purge the copyover point.
	// 	    sh 'rm -r -f $WORKSPACE/copyover || true'
	// 	}
	//     }
	// }
	// stage('Publish') {
	//     when { anyOf { branch 'release'; branch 'snapshot'; branch 'snapshot-post-fail'; branch 'master' } }
	//     // CHECKPOINT: Recover key environmental variables.
	//     environment {
	// 	START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/dow.txt', , returnStdout: true).trim()
	// 	START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/date.txt', , returnStdout: true).trim()
	//     }
	//     steps {
	// 	// Experimental stanza to support mounting the sshfs
	// 	// using the "hidden" skyhook identity.
	// 	sh 'mkdir -p $WORKSPACE/mnt/ || true'
	// 	withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
	// 	    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
	// 	}
	// 	// Copy the product to the right location. As well,
	// 	// archive.
	// 	withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
	// 	    // Ready...
	// 	    dir('./go-site') {
	// 		git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

	// 		// TODO: Special handling still needed w/o OSF.io?
	// 		// WARNING: Caveats and reasons as same
	// 		// pattern above. We need this as some clients
	// 		// are not standard and it turns out there are
	// 		// some subtle incompatibilities with urllib3
	// 		// and boto in some versions, so we will use a
	// 		// virtual env to paper that over.  See:
	// 		// https://github.com/geneontology/pipeline/issues/8#issuecomment-356762604
	// 		sh 'python3 -m venv mypyenv'
	// 		withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

	// 		    // Extra package for the indexer.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'

	// 		    // Extra package for the uploader.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

	// 		    // Let's be explicit here as well, as there were recent issues.
	// 		    //
	// 		    sh 'python3 ./mypyenv/bin/pip3 install rsa'
	// 		    sh 'python3 ./mypyenv/bin/pip3 install awscli'

	// 		    // Version locking for boto3 / botocore
	// 		    // upgrade that is incompatible with
	// 		    // python3.5. See issues #250 and #271.
	// 		    sh 'python3 ./mypyenv/bin/pip3 install boto3==1.18.52'
	// 		    sh 'python3 ./mypyenv/bin/pip3 install botocore==1.21.52'
	// 		    sh 'python3 ./mypyenv/bin/pip3 install s3transfer==0.5.0'

	// 		    // Well, we need to do a couple of things here in
	// 		    // a structured way, so we'll go ahead and drop
	// 		    // into the scripting mode.
	// 		    script {

	// 			// Create working index off of
	// 			// skyhook. For "release", this will
	// 			// be "current". For "snapshot", this
	// 			// will be "snapshot".
	// 			sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/snapshot --prefix $TARGET_INDEXER_PREFIX -x'

	// 			// Push into S3 buckets. Simple
	// 			// overall case: copy tree directly
	// 			// over. For "release", this will be
	// 			// "current". For "snapshot", this
	// 			// will be "snapshot".
	// 			sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket $TARGET_BUCKET --number $BUILD_ID --pipeline snapshot'

	// 			// Also, some runs have special maps
	// 			// to buckets...
	// 			if( env.BRANCH_NAME == 'release' ){

	// 			    // "release" -> dated path for
	// 			    // indexing (clobbering
	// 			    // "current"'s index.
	// 			    sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/snapshot --prefix http://release.geneontology.org/$START_DATE -x -u'
	// 			    // "release" -> dated path for S3.
	// 			    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket go-data-product-release/$START_DATE --number $BUILD_ID --pipeline snapshot'

	// 			    // Build the capper index.html...
	// 			    sh 'python3 ./scripts/bucket-indexer.py --credentials $S3_PUSH_JSON --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html'
	// 			    // ...and push it up to S3.
	// 			    sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html'

	// 			}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){

	// 			    // Currently, the "daily"
	// 			    // debugging buckets are intended
	// 			    // to be RO directly in S3 for
	// 			    // debugging.
	// 			    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket go-data-product-daily/$START_DOW --number $BUILD_ID --pipeline snapshot'

	// 			}else if( env.BRANCH_NAME == 'master' ){
	// 			    // Pass.
	// 			}

	// 			// Invalidate the CDN now that the new
	// 			// files are up.
	// 			sh 'echo "[preview]" > ./awscli_config.txt && echo "cloudfront=true" >> ./awscli_config.txt'
	// 			sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_DISTRIBUTION_ID --paths "/*"'
	// 			// The release branch also needs to
	// 			// deal with the second location.
	// 			if( env.BRANCH_NAME == 'release' ){
	// 			    sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID --paths "/*"'
	// 			}
	// 		    }
	// 		}
	// 	    }
	// 	}
	//     }
	//     // WARNING: Extra safety as I expect this to sometimes fail.
	//     post {
	// 	always {
	// 	    // Bail on the remote filesystem.
	// 	    sh 'fusermount -u $WORKSPACE/mnt/ || true'
	// 	}
	//     }
	// }
	// // Big things to do on major branches.
	// stage('Deploy') {
	//     // For exploration of #204, we'll hold back attempts to push out to AmiGO for master and snapshot
	//     // so we don't keep clobbering #204 trials out.
	//     //when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	//     when { anyOf { branch 'release' } }
	//     steps {
	// 	parallel(
	// 	    "AmiGO": {

	// 		// Ninja in our file credentials from Jenkins.
	// 		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY'), file(credentialsId: 'go-svn-private-key', variable: 'GO_SVN_IDENTITY'), file(credentialsId: 'ansible-bbop-local-slave', variable: 'DEPLOY_LOCAL_IDENTITY'), file(credentialsId: 'go-aws-ec2-ansible-slave', variable: 'DEPLOY_REMOTE_IDENTITY')]) {

	// 		    // Get our operations code and decend into ansible
	// 		    // working directory.
	// 		    dir('./operations') {

	// 			git([branch: 'master',
	// 			     credentialsId: 'bbop-agent-github-user-pass',
	// 			     url: 'https://github.com/geneontology/operations.git'])
	// 			dir('./ansible') {
	// 			    ///
	// 			    /// Push out to an AmiGO.
	// 			    ///
	// 			    script {
	// 				if( env.BRANCH_NAME == 'release' ){

	// 				    echo 'No current public push on release to Blazegraph.'
	// 				    // retry(3){
	// 				    //	sh 'ansible-playbook update-endpoint.yaml --inventory=hosts.local-rdf-endpoint --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_user=bbop --extra-vars="pipeline=current build=production endpoint=production"'
	// 				    // }

	// 				    echo 'No current public push on release to GOlr.'
	// 				    // retry(3){
	// 				    //	sh 'ansible-playbook ./update-golr.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_host=amigo-golr-aux -e target_user=bbop'
	// 				    // }
	// 				    // retry(3){
	// 				    //	sh 'ansible-playbook ./update-golr.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_host=amigo-golr-production -e target_user=bbop'
	// 				    // }

	// 				}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){

	// 				    echo 'Push snapshot out internal Blazegraph'
	// 				    retry(3){
	// 					sh 'ansible-playbook update-endpoint.yaml --inventory=hosts.local-rdf-endpoint --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_user=bbop --extra-vars="pipeline=current build=internal endpoint=internal"'
	// 				    }

	// 				    echo 'Push snapshot out to experimental AmiGO'
	// 				    retry(3){
	// 					sh 'ansible-playbook ./update-golr-w-snap.yaml --inventory=hosts.amigo --private-key="$DEPLOY_REMOTE_IDENTITY" -e target_host=amigo-golr-exp -e target_user=ubuntu'
	// 				    }

	// 				}else if( env.BRANCH_NAME == 'master' ){

	// 				    echo 'Push master out to experimental AmiGO'
	// 				    retry(3){
	// 					sh 'ansible-playbook ./update-golr-w-exp.yaml --inventory=hosts.amigo --private-key="$DEPLOY_REMOTE_IDENTITY" -e target_host=amigo-golr-exp -e target_user=ubuntu'
	// 				    }

	// 				}
	// 			    }
	// 			}
	// 		    }
	// 		}
	// 	    }
	// 	)
	//     }
	//     // WARNING: Extra safety as I expect this to sometimes fail.
	//     post {
	// 	always {
	// 	    // Bail on the remote filesystem.
	// 	    sh 'fusermount -u $WORKSPACE/mnt/ || true'
	// 	}
	//     }
	// }
	// stage('TODO: Final status') {
	//     steps {
	//	echo 'TODO: final'
	//     }
	// }
    }
    post {
	// Let's let our people know if things go well.
	success {
	    script {
		if( env.BRANCH_NAME == 'release' || env.BRANCH_NAME == 'snapshot-post-fail' || env.BRANCH_NAME == 'derivatives-from-goa' ){
		    echo "There has been a successful run of the ${env.BRANCH_NAME} pipeline."
		    emailext to: "${TARGET_SUCCESS_EMAILS}",
			subject: "GO Pipeline success for ${env.BRANCH_NAME}",
			body: "There has been successful run of the ${env.BRANCH_NAME} pipeline. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
		}
	    }
	}
	// Let's let our internal people know if things change.
	changed {
	    echo "There has been a change in the ${env.BRANCH_NAME} pipeline."
	    emailext to: "${TARGET_ADMIN_EMAILS}",
		subject: "GO Pipeline change for ${env.BRANCH_NAME}",
		body: "There has been a pipeline status change in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
	}
	// Let's let our internal people know if things go badly.
	failure {
	    echo "There has been a failure in the ${env.BRANCH_NAME} pipeline."
	    emailext to: "${TARGET_ADMIN_EMAILS}",
		subject: "GO Pipeline FAIL for ${env.BRANCH_NAME}",
		body: "There has been a pipeline failure in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
	}
    }
}

// Check that we do not affect public targets on non-mainline runs.
void watchdog() {
    if( BRANCH_NAME != 'master' && TARGET_BUCKET == 'go-data-product-experimental'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'snapshot-post-fail' && TARGET_BUCKET == 'go-data-product-snapshot'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'release' && TARGET_BUCKET == 'go-data-product-release'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }
}

// Reset and initialize skyhook base.
void initialize() {

    // Possibly protect against issues like #350 by making sure
    // $BRANCH_NAME is there and vaguely sane.
    if(BRANCH_NAME instanceof String && BRANCH_NAME.size() >= 3 ) {

	// Get a mount point ready
	sh 'mkdir -p $WORKSPACE/mnt || true'
	// Ninja in our file credentials from Jenkins.
	withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
	    // Try and ssh fuse skyhook onto our local system.
	    sh 'sshfs -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
	}
	// Remove anything we might have left around from
	// times past.
	sh 'rm -r -f $WORKSPACE/mnt/$BRANCH_NAME || true'
	// Rebuild directory structure.
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/bin || true'
	// WARNING/BUG: needed for arachne to run at
	// this point.
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/lib || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/ttl || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/json || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/blazegraph || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/upstream_and_raw_data || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/pages || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/solr || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/panther || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/gaferencer || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/metadata || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/annotations || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/ontology || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/reports || true'
	sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/release_stats || true'
	// Tag the top to let the world know I was at least
	// here.
	sh 'echo "Runtime summary." > $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'date >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "Release notes: https://github.com/geneontology/go-site/tree/master/releases" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "Branch: $BRANCH_NAME" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "Start day: $START_DAY" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "Start date: $START_DATE" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "$START_DAY" > $WORKSPACE/mnt/$BRANCH_NAME/metadata/dow.txt'
	sh 'echo "$START_DATE" > $WORKSPACE/mnt/$BRANCH_NAME/metadata/date.txt'

	sh 'echo "Official release date: metadata/release-date.json" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "Official Zenodo archive DOI: metadata/release-archive-doi.json" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	sh 'echo "TODO: Note software versions." >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
	// TODO: This should be wrapped in exception
	// handling. In fact, this whole thing should be.
	sh 'fusermount -u $WORKSPACE/mnt/ || true'
    }else{
	sh 'echo "HOW DID THIS EVEN HAPPEN?"'
    }
}
