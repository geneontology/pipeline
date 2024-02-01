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
	TARGET_GO_SITE_BRANCH = 'mouse_upstream_from_silver_325_pipeline'
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
	TARGET_ADMIN_EMAILS = 'smoxon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'smoxon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'smoxon@lbl.gov'
    // The file bucket(/folder) combination to use.
    TARGET_BUCKET = null
    // The URL prefix to use when creating site indices.
    TARGET_INDEXER_PREFIX = 'http://experimental.geneontology.io'
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
    MAKECMD = 'make --jobs 3 --max-load 10.0'
    //MAKECMD = 'make'

	///
	/// PANTHER/PAINT metadata.
	///

	PANTHER_VERSION = '17.0'

	///
	/// Application tokens.
	///

	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
    ZENODO_ARCHIVE_CONCEPT = null
    // Distribution ID for the AWS CloudFront for this branch,
    // used soley for invalidations. Versioned release does not
    // need this as it is always a new location and the index
    // upload already has an invalidation on it. For current,
    // snapshot, and experimental.
    AWS_CLOUDFRONT_DISTRIBUTION_ID = null
    AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = null

	///
	/// Ontobio Validation
	///
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/ontology/extensions/go-amigo.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/products/upstream_and_raw_data/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/products/panther/arbre.tgz"
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
	//GORULE_TAGS_TO_SUPPRESS="silent"

    // Optional. Groups to run.
    RESOURCE_GROUPS="ecocyc goa mgi paint pseudocap wb"
    // Optional. Datasets to skip within the resources that we
    // will run (defined in the line above).
	DATASET_EXCLUDES="goa_uniprot_gcrp goa_pdb goa_chicken_isoform goa_chicken_rna goa_cow goa_cow_complex goa_cow_isoform goa_cow_rna goa_dog goa_dog_complex goa_dog_isoform goa_dog_rna goa_human goa_human goa_human_complex goa_human_rna paint_cgd paint_dictybase paint_fb paint_goa_chicken paint_goa_human paint_other paint_rgd paint_sgd paint_tair paint_zfin"
    // Optional. This acts as an override, /if/ it's grabbed (as
    // defined above).
    GOA_UNIPROT_ALL_URL="http://skyhook.berkeleybop.org/goa_uniprot_short.gaf.gz"
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
	// Build owltools and get it into the shared filesystem.
	stage('Ready production software') {
	    steps {
		parallel(
		    "Ready owltools": {
			// Legacy: build 'owltools-build'
			dir('./owltools') {
			    // Remember that git lays out into CWD.
			    git 'https://github.com/owlcollab/owltools.git'
			    sh 'mvn -f OWLTools-Parent/pom.xml -U clean install -DskipTests -Dmaven.javadoc.skip=true -Dsource.skip=true'
			    // Attempt to rsync produced into bin/.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-Runner/target/owltools skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-Oort/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-NCBI/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				sh 'rsync -vhac -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" --exclude ".git" OWLTools-Oort/reporting/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				sh 'rsync -vhac -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" --exclude ".git" OWLTools-Runner/contrib/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
			    }
			}
		    },
		    "Ready minerva": {
			dir('./minerva') {
			    // Remember that git lays out into CWD.
			    git branch: TARGET_MINERVA_BRANCH, url: 'https://github.com/geneontology/minerva.git'
			    sh './build-cli.sh'
			    // Attempt to rsync produced into bin/.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" minerva-cli/bin/minerva-cli.* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
			    }
			}
		    },
		    "Ready robot": {
			// Legacy: build 'robot-build'
			dir('./robot') {
			    // Remember that git lays out into CWD.
			    git branch: TARGET_ROBOT_BRANCH, url:'https://github.com/kltm/robot-old.git'

			    // Update the POMs by replacing "SNAPSHOT"
			    // with the current Git hash. First make
			    // sure maven-help-plugin is installed
			    sh 'mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version'
			    // Now get and set the version.
			    // Originally: sh 'VERSION=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\[' | sed 's/-SNAPSHOT//'`'
			    sh 'VERSION=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v \'\\[\' | sed \'s/-SNAPSHOT//\'`'
			    sh 'BUILD=`git rev-parse --short HEAD`'
			    sh 'mvn versions:set -DnewVersion=$VERSION+$BUILD'
			    sh 'mvn -U clean install -DskipTests'
			    // Attempt to rsync produced into bin/.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
			    }
			}
		    },
		    "Ready arachne": {
			dir('./arachne') {
			    sh 'wget -N https://github.com/balhoff/arachne/releases/download/v1.0.2/arachne-1.0.2.tgz'
			    sh 'tar -xvf arachne-1.0.2.tgz'
			    // Attempt to rsync produced into bin/.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" arachne-1.0.2/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				// WARNING/BUG: needed for arachne to
				// run at this point.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" arachne-1.0.2/lib/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/'
			    }
			}
		    },
		    "Ready blazegraph-runner": {
			dir('./blazegraph-runner') {
			    sh 'wget -N https://github.com/balhoff/blazegraph-runner/releases/download/v1.4/blazegraph-runner-1.4.tgz'
			    sh 'tar -xvf blazegraph-runner-1.4.tgz'
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				// Attempt to rsync bin into bin/.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" blazegraph-runner-1.4/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				// Attempt to rsync libs into lib/.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" blazegraph-runner-1.4/lib/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/'
			    }
			}
		    },
		    "Ready Gaferencer": {
			dir('./gaferencer') {
			    sh 'wget -N https://github.com/geneontology/gaferencer/releases/download/v0.5/gaferencer-0.5.tgz'
			    sh 'tar -xvf gaferencer-0.5.tgz'
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				// Attempt to rsync bin into bin/.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" gaferencer-0.5/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				// Attempt to rsync libs into lib/.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" gaferencer-0.5/lib/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/'
			    }
			}
		    }
		)
	    }
	}
	// Download GAFs from datasets.yaml in go-site and then upload
	// to skyhook in their appropriate locations.
	stage("Download annotation data") {
	    steps {
		dir("./go-site") {
		    git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		    script {
			def excluded_datasets_args = ""
			if ( env.DATASET_EXCLUDES ) {
			    excluded_datasets_args = DATASET_EXCLUDES.split(" ").collect { "-x ${it}" }.join(" ")
			}
			def included_resources = ""
			if (env.RESOURCE_GROUPS) {
			    included_resources = RESOURCE_GROUPS.split(" ").collect { "-g ${it}" }.join(" ")
			}
			def goa_mapping_url = ""
			if (env.GOA_UNIPROT_ALL_URL) {
			    goa_mapping_url = "-m goa_uniprot_all gaf ${GOA_UNIPROT_ALL_URL}"
			}
			sh "python3 ./scripts/download_source_gafs.py all --datasets ./metadata/datasets --target ./target/ --type gaf ${excluded_datasets_args} ${included_resources} ${goa_mapping_url}"
		    }

		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			// Upload to skyhook to the expected location.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/'
		    }
		}
	    }
	}
	stage('Produce GAFs, TTLs, and journal (*)') {
	    agent {
		docker {
		    image 'geneontology/dev-base:ea32b54c822f7a3d9bf20c78208aca452af7ee80_2023-08-28T125255'
		    args "-u root:root --tmpfs /opt:exec -w /opt"
		}
	    }
	    // CHECKPOINT: Recover key environmental variables.
	    environment {
		START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/$BRANCH_NAME/metadata/dow.txt', , returnStdout: true).trim()
		START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/$BRANCH_NAME/metadata/date.txt', , returnStdout: true).trim()
	    }

	    steps {

		// Legacy: build 'gaf-production'
		sh "mkdir -p /opt/go-site"
		sh "cd /opt/ && git clone -b $TARGET_GO_SITE_BRANCH https://github.com/geneontology/go-site.git"
		// sh "pwd"
		sh "mkdir -p /opt/bin"
		sh "mkdir -p /opt/lib"
		sh "mkdir -p /opt/go-site/gaferencer-products"
		sh "mkdir -p /opt/go-site/gaferencer-products-tmp"
		// git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* /opt/bin/'
		    // WARNING/BUG: needed for blazegraph-runner
		    // to run at this point.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/* /opt/lib/'
		    // Copy the sources we downloaded earlier to local.
		    // We're grabbing anything that's gaf, zipped or unzipped. This leaves gpad or anything else behind since currently we only expect gafs
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/release/products/upstream_and_raw_data/*.gaf*  /opt/go-site/sources/'
		}
		sh "chmod +x /opt/bin/*"

		// Install the python requirements.
		sh "cd /opt/go-site/scripts && pip3 install -r requirements.txt"
		// Re-establish location in the filesystem expected by steps below.
		sh "cd /opt/"
		sh "python3 /opt/go-site/scripts/download_source_gafs.py organize --datasets /opt/go-site/metadata/datasets --source /opt/go-site/sources --target /opt/go-site/pipeline/target/groups/"
		sh "rm /opt/go-site/sources/*"

		// Make minimal GAF products.
		// sh "cd /opt/go-site/pipeline"
		// sh "pwd"
		// Gunna need some memory.
		// In addition to the memory, try and simulate
		// the environment changes for python venv activate.
		// Note the complex assignment of VIRTUAL_ENV and PATH.
		// https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-withenv-code-set-environment-variables
		// "PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/pipeline/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/pipeline/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin'
		withEnv(['JAVA_OPTS=-Xmx128G', 'OWLTOOLS_MEMORY=128G', 'BGMEM=128G', "ONTOLOGY=${VALIDATION_ONTOLOGY_URL}", "BRANCH_NAME=${BRANCH_NAME}"]){
		    // Note environment for future debugging.
		    // Note: https://issues.jenkins-ci.org/browse/JENKINS-53025 and
		    // https://issues.jenkins-ci.org/browse/JENKINS-49076
		    // Just shell out PATH does not work either
		    // sh 'export PATH=/opt/pipeline/bin:$PATH'
		    sh 'env > env.txt'
		    sh 'cat env.txt'

		    sh 'cd /opt/go-site/pipeline && pip3 install -r requirements.txt'
		    sh 'cd /opt/go-site/pipeline && pip3 install ../graphstore/rule-runner'

		    // Get a final accounting of software versions for
		    // run.
		    // https://github.com/geneontology/pipeline/issues/208
		    sh 'pip3 freeze --no-input > pip3_freeze.txt'
		    sh 'cat pip3_freeze.txt'

		    // Ready, set...
		    // Do this thing, but the watchdog sits
		    // waiting.
		    timeout(time: 20, unit: 'HOURS') {
			script {
			    /// All branches now try to produce all
			    /// targets in the go-site Makefile.
			    sh 'cd /opt/go-site/pipeline && PATH=/opt/bin:$PATH $MAKECMD PY_BIN=/usr/local/bin/ -e target/sparta-report.json'
			}
		    }
		}
		// Copy products over to skyhook.
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // All non-core GAFs to the side in
		    // products/gaf. Basically:
		    //  - all irregular gaffy files + anything paint-y
		    //  - but not uniprot_all anything (elsewhere)
		    //  - and not any of the ttls
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*\\(\\-src.gaf\\|\\-src.gpi\\|\\_noiea.gaf\\|\\_valid.gaf\\|paint\\_.*\\).gz$" -not -regex "^.*.ttl.gz$" -not -regex "^.*goa_uniprot_all_noiea.gaf.gz$" -not -regex "^.*.ttl.gz$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data \\;'
		    // No longer copy goa uniprot all source to products:
		    // https://github.com/geneontology/pipeline/issues/207
		    // // Now copy over the (single) uniprot
		    // // non-core; may not be there in all runs
		    // // (e.g. speed runs of master).
		    // script {
		    // 	try {
		    // 	    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all-src.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data'
		    // 	} catch (exception) {
		    // 	    echo "NOTE: No goa_uniprot_all-src.gaf.gz found for this run to copy."
		    // 	}
		    // }
		    // Finally, the non-zipped prediction files.
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*\\-prediction.gaf$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data \\;'
		    // Flatten all GAFs and GAF-like products
		    // onto skyhook. Basically:
		    //  - all product-y files
		    //  - but not uniprot_all anything (elsewhere)
		    //  - and not anything "irregular", like src
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*.\\(gaf\\|gpad\\|gpi\\).gz$" -not -regex "^.*\\(\\-src.gaf\\|\\-src.gpi\\|\\_noiea.gaf\\|\\_valid.gaf\\|noctua_.*\\|paint_.*\\).gz$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations \\;'
		    // Now copy over the four uniprot core
		    // files, if they are in our run set
		    // (e.g. may not be there on speed runs
		    // for master).
		    script {
			try {
			    // No longer copy goa uniprot all source to annotations:
			    // https://github.com/geneontology/pipeline/issues/207
			    //sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all_noiea.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all_noiea.gpi.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all_noiea.gpad.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			} catch (exception) {
			    echo "NOTE: At least one uniprot core file not found for this run to copy."
			}
		    }
		    // Find all {group}.gaferences.json files and combine into one JSON list in one file
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*.gaferences.json$" -exec cp {} /opt/go-site/gaferencer-products-tmp/ \\;'
		    sh 'python3 /opt/go-site/scripts/json-concat-lists.py  /opt/go-site/gaferencer-products-tmp/*.gaferences.json /opt/go-site/gaferencer-products/all.gaferences.json'
		    // DEBUG: remove debug line later
		    sh 'ls -AlF /opt/go-site/gaferencer-products'
		    sh 'pigz /opt/go-site/gaferencer-products/all.gaferences.json'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/gaferencer-products/all.gaferences.json.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/gaferencer'
		    // Flatten the TTLs into products/ttl/.
		    sh 'find /opt/go-site/pipeline/target/groups -type f -name "*.ttl.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/ttl \\;'
		    // Compress the journals.
		    sh 'pigz /opt/go-site/pipeline/target/blazegraph-internal.jnl'
		    sh 'pigz /opt/go-site/pipeline/target/blazegraph-production.jnl'
		    // Copy the journals directly to products.
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/blazegraph-production.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/blazegraph-internal.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/blazegraph-production.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/blazegraph-internal.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    // Copy the reports into reports.
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/sparta-report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/sparta-report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
		    // Plus: flatten product reports in json,
		    // md reports, text files, etc.
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*\\.\\(json\\|txt\\|md\\)$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports \\;'
		    script {
			try {
			    // WARNING: This is a hacky fix for https://github.com/geneontology/go-site/issues/1253 .
			    // It can (should) be removed with an overall flow change in https://github.com/geneontology/go-site/issues/1384 .
			    sh 'find /opt/go-site/pipeline/target/groups/paint -type f -regex "^.*\\.\\(json\\|txt\\|md\\)$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports \\;'
			} catch (exception) {
			    echo "NOTE: paint directory does not exist, so no reports to copy"
			}
		    }
		}

	    }
	}
}

// Check that we do not affect public targets on non-mainline runs.
void watchdog() {
    if( BRANCH_NAME != 'master' && TARGET_BUCKET == 'go-data-product-experimental'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'snapshot' && TARGET_BUCKET == 'go-data-product-snapshot'){
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
