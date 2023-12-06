pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    //triggers {
	// Master never runs--Feb 31st.
	// cron('0 0 31 2 *')
	// Nightly @12am, for "snapshot", skip "release" night.
	//cron('0 0 2-31/2 * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
    //}
    environment {

	///
	/// Internal run variables.
	///

	// The branch of geneontology/go-site to use.
	TARGET_GO_SITE_BRANCH = 'gopreprocess'
	TARGET_GO_PREPROCESS_BRANCH = 'main'
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
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/master/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-amigo.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/master/products/upstream_and_raw_data/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/master/products/panther/arbre.tgz"
	].join(" ")

	///
	/// Groups to run and tests to avoid running during the current
	/// mega-make.
	///

	// The gorule tag is used to identify which rules to suppress
	// reports from during the megastep and during templating the
	// reports after the megastep. The tags are currently
	// respected at two times in the pipeline: the gorules report
	// take the flag as a CLI argument, suppressing it; ontobio
	// takes it during the same stage as the JSON
	// generation/parsing step, to supress the .md output. At this
	// time, this variable can be either nothing or empty string
	// for no rule suppression (default behavior everything), or a
	// single value (practically speaking pretty much always
	// "silent")
	//GORULE_TAGS_TO_SUPPRESS="silent"

	// Optional. Groups to run.
	RESOURCE_GROUPS="ecocyc goa mgi rgd paint pseudocap wb"
	// Optional. Datasets to skip within the resources that we
	// will run (defined in the line above).
	DATASET_EXCLUDES="goa_pig_complex goa_pig_rna goa_pig_isoform goa_pig goa_uniprot_gcrp goa_pdb goa_chicken goa_chicken_isoform goa_chicken_rna goa_cow goa_cow_complex goa_cow_isoform goa_cow_rna goa_dog goa_dog_complex goa_dog_isoform goa_dog_rna goa_human_complex goa_human_rna paint_cgd paint_dictybase paint_fb paint_goa_chicken paint_goa_human paint_other paint_rgd paint_sgd paint_tair paint_zfin"
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
	    agent {
		    docker {
		        image 'geneontology/dev-base:ea32b54c822f7a3d9bf20c78208aca452af7ee80_2023-08-28T125255'
		        args "-u root:root --tmpfs /opt:exec -w /opt"
		    }
		}
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
			        sh "cd scripts && pip3 install -r requirements.txt"
			        sh "python3 ./scripts/download_source_gafs.py all --datasets ./metadata/datasets --target ./target/ --type gaf ${excluded_datasets_args} ${included_resources} ${goa_mapping_url}"
			    }

		        withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			        // Upload to skyhook to the expected location.
			        sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/'
		        }
		    }
		    dir("./gopreprocess") {
		        git branch: TARGET_GO_PREPROCESS_BRANCH, url: 'https://github.com/geneontology/gopreprocess.git'
		        sh "pwd"
		        sh "ls -lrt"
		        sh "poetry install"
		        sh "make download_human"
		        sh "make download_rat"
                sh "ls -lrt ~/.data/HUMAN/"
                sh "ls -lrt ~/.data/RGD"
                sh "ls -lrt ~/.data/MGI"
		        withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			        // Upload pystow'd files from gopreprocess downloader to skyhook upstream and raw data folder.
			        sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ~/.data/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/preprocess_raw_files/'
		        }
		    }
	    }

	}
	// See https://github.com/geneontology/go-ontology for details
	// on the ontology release pipeline. This ticket runs
	// daily(TODO?) and creates all the files normally included in
	// a release, and deploys to S3.
	stage('Produce ontology (*)') {
	    agent {
		docker {
		    // Upgrade test for: geneontology/go-ontology#25019, from v1.2.32
    		    image 'obolibrary/odkfull:v1.4'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root'
		}
	    }
	    // CHECKPOINT: Recover key environmental variables.
	    environment {
		START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/$BRANCH_NAME/metadata/dow.txt', , returnStdout: true).trim()
		START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/$BRANCH_NAME/metadata/date.txt', , returnStdout: true).trim()
	    }
	    steps {
		// Create a relative working directory and setup our
		// data environment.
		dir('./go-ontology') {

		    // We're starting to run into problems with
		    // ontology download taking too long for the
		    // default 10m, so try and get into the guts of
		    // the git commands a little. Issues #248.
		    // git branch: TARGET_GO_ONTOLOGY_BRANCH, url: 'https://github.com/geneontology/go-ontology.git'
                    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: TARGET_GO_ONTOLOGY_BRANCH]], extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true, timeout: 120]], userRemoteConfigs: [[url: 'https://github.com/geneontology/go-ontology.git', refspec: "+refs/heads/${env.TARGET_GO_ONTOLOGY_BRANCH}:refs/remotes/origin/${env.TARGET_GO_ONTOLOGY_BRANCH}"]]]

		    // Default namespace.
		    sh 'env'

		    dir('./src/ontology') {
			retry(3){
			    sh 'make RELEASEDATE=$START_DATE OBO=http://purl.obolibrary.org/obo ROBOT_ENV="ROBOT_JAVA_ARGS=-Xmx48G" all'
			}
			retry(3){
			    sh 'make prepare_release'
			}
		    }

		    // Make sure that we copy any files there,
		    // including the core dump of produced.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			//sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology'
			sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -r target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/'
		    }

		    // Now that the files are safely away onto skyhook for
		    // debugging, test for the core dump.
		    script {
			if( WE_ARE_BEING_SAFE_P == 'TRUE' ){

			    def found_core_dump_p = fileExists 'target/core_dump.owl'
			    if( found_core_dump_p ){
				error 'ROBOT core dump detected--bailing out.'
			    }
			}
		    }

		    // Try and force destruction of anything remaining
		    // on disk after build as cleanup.
		    sh 'git clean -fx || true'
		}
	    }
	}
	stage('Generate automated annotations'){
		agent {
		    docker {
		        image 'geneontology/dev-base:ea32b54c822f7a3d9bf20c78208aca452af7ee80_2023-08-28T125255'
		        args "-u root:root --tmpfs /opt:exec -w /opt"
		    }
	    }
	    steps {
            dir("./gopreprocess") {
                git branch: TARGET_GO_PREPROCESS_BRANCH, url: 'https://github.com/geneontology/gopreprocess.git'
                sh "pwd"
                sh "ls -lrt"
                sh "poetry install"
                sh "make convert_rat"
                sh "make convert_human"
                sh "make convert_p2g_annotations"
                sh "make merge_gafs"
                sh "ls -lrt ~/.data/GAF_OUTPUT"
                withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			        // Upload pystow'd files from gopreprocess downloader to skyhook upstream and raw data folder.
			        sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ~/.data/GAF_OUTPUT/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/preprocessed_GAF_output/'
		            sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ~/.data/MGI/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/preprocess_raw_files/'
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

// Reset and initialize skyhook base.
void initialize() {
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
    sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/upstream_and_raw_data/preprocess_raw_files || true'
    sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/upstream_and_raw_data/preprocessed_GAF_output || true'
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
}
