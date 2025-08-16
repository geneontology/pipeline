pipeline {
    agent any
    // triggers {
    //     // No triggers - pipeline will only run manually
    // }
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
	// The branch/tag of gocam-py to use.
	TARGET_GOCAM_PY_BRANCH = 'v0.5.3-rc2'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,smoxon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,smoxon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,smoxon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'null'
	// The URL prefix to use when creating site indices.
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
	MAKECMD = 'make --jobs 3 --max-load 10.0'
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
	ZENODO_ARCHIVE_CONCEPT = '1170314'
	// Distribution ID for the AWS CloudFront for this branch,
	// used soley for invalidations. Versioned release does not
	// need this as it is always a new location and the index
	// upload already has an invalidation on it. For current,
	// snapshot, and experimental.
	AWS_CLOUDFRONT_DISTRIBUTION_ID = 'E2CDVG5YT5R4K4'
	AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'E2HF1DWYYDLTQP'

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

		// Give us a beat to cancel if we want.
		sleep time: 15, unit: 'SECONDS'
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
	stage('GO-CAM Translation') {
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
		sh "mkdir -p /opt/go-site"
		sh "cd /opt/ && git clone -b $TARGET_GOCAM_PY_BRANCH https://github.com/geneontology/gocam-py.git"
		sh "cd /opt/gocam-py"
		sh "pwd"
		sh "cd /opt/gocam-py && ls -lrt"
		sh "cd /opt/gocam-py && pip3 install poetry"
		sh "cd /opt/gocam-py && poetry install"
		sh "cd /opt/gocam-py && pip3 install networkx"
		sh "cd /opt/gocam-py && poetry run gocam translate-collection --max-workers 20"

		// Find and copy the generated tar.gz files to skyhook
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'find /opt/gocam-py/networkx -name "*.tar.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/json/ \\;'
		    sh 'find /opt/gocam-py/cx2 -name "*.tar.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/json/ \\;'
		}
	    }
	}
    }
    post {
	// Let's let our people know if things go well.
	success {
	    script {
		if( env.BRANCH_NAME == 'release' ){
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
