pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    triggers {
	// Nightly @12am, for "goa-copy-for-mirror", skip "release" night.
	cron('0 0 2-31 * *')
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
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'go-mirror'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'http://mirror.geneontology.io'
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
	ZENODO_ARCHIVE_CONCEPT = 'null'
	// Distribution ID for the AWS CloudFront for this branch,
	// used soley for invalidations. Versioned release does not
	// need this as it is always a new location and the index
	// upload already has an invalidation on it. For current,
	// snapshot, and experimental.
	AWS_CLOUDFRONT_DISTRIBUTION_ID = 'null'
	AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'null'

	///
	/// Ontobio Validation
	///
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/goa-copy-to-mirror/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/ontology/extensions/go-amigo.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/goa-copy-to-mirror/products/upstream_and_raw_data/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/goa-copy-to-mirror/products/panther/arbre.tgz"
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
	// Download GAFs from datasets.yaml in go-site and then upload
	// to skyhook in their appropriate locations.
	stage("Download annotation data") {
	    steps {
		dir("./go-site") {
		    git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		    script {

			sh "grep -r 'ftp.ebi.ac.uk' ./metadata/datasets/ | grep -oh 'https:.*' > ./files.txt"
			sh "sed -e 's/https/ftp/g' ./files.txt > ./files.txt.changed"
			sh "time wget -i ./files.txt.changed -P ./copy"
		    }

		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			// Upload to skyhook to the expected location.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./copy/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/upstream_and_raw_data/'
		    }
		}
	    }
	}
    // 	stage('Publish') {
    // 	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
    // 	    steps {
    // 		// Experimental stanza to support mounting the sshfs
    // 		// using the "hidden" skyhook identity.
    // 		sh 'mkdir -p $WORKSPACE/mnt/ || true'
    // 		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
    // 		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
    // 		}
    // 		// Copy the product to the right location. As well,
    // 		// archive.
    // 		withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
    // 		    // Ready...
    // 		    dir('./go-site') {
    // 			git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

    // 			// TODO: Special handling still needed w/o OSF.io?
    // 			// WARNING: Caveats and reasons as same
    // 			// pattern above. We need this as some clients
    // 			// are not standard and it turns out there are
    // 			// some subtle incompatibilities with urllib3
    // 			// and boto in some versions, so we will use a
    // 			// virtual env to paper that over.  See:
    // 			// https://github.com/geneontology/pipeline/issues/8#issuecomment-356762604
    // 			sh 'python3 -m venv mypyenv'
    // 			withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

    // 			    // Extra package for the indexer.
    // 			    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'

    // 			    // Extra package for the uploader.
    // 			    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

    // 			    // Let's be explicit here as well, as there were recent issues.
    // 			    //
    // 			    sh 'python3 ./mypyenv/bin/pip3 install rsa'
    // 			    sh 'python3 ./mypyenv/bin/pip3 install awscli'

    // 			    // Version locking for boto3 / botocore
    // 			    // upgrade that is incompatible with
    // 			    // python3.5. See issues #250 and #271.
    // 			    sh 'python3 ./mypyenv/bin/pip3 install boto3==1.18.52'
    // 			    sh 'python3 ./mypyenv/bin/pip3 install botocore==1.21.52'
    // 			    sh 'python3 ./mypyenv/bin/pip3 install s3transfer==0.5.0'

    // 			    // Well, we need to do a couple of things here in
    // 			    // a structured way, so we'll go ahead and drop
    // 			    // into the scripting mode.
    // 			    script {

    // 				// Create working index off of
    // 				// skyhook. For "release", this will
    // 				// be "current". For "snapshot", this
    // 				// will be "snapshot".
    // 				sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/$BRANCH_NAME --prefix $TARGET_INDEXER_PREFIX -x'

    // 				// Push into S3 buckets. Simple
    // 				// overall case: copy tree directly
    // 				// over. For "release", this will be
    // 				// "current". For "snapshot", this
    // 				// will be "snapshot".
    // 				sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket $TARGET_BUCKET --number $BUILD_ID --pipeline $BRANCH_NAME'

    // 				// Also, some runs have special maps
    // 				// to buckets...
    // 				if( env.BRANCH_NAME == 'release' ){

    // 				    // "release" -> dated path for
    // 				    // indexing (clobbering
    // 				    // "current"'s index.
    // 				    sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/$BRANCH_NAME --prefix http://release.geneontology.org/$START_DATE -x -u'
    // 				    // "release" -> dated path for S3.
    // 				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket go-data-product-release/$START_DATE --number $BUILD_ID --pipeline $BRANCH_NAME'

    // 				    // Build the capper index.html...
    // 				    sh 'python3 ./scripts/bucket-indexer.py --credentials $S3_PUSH_JSON --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html'
    // 				    // ...and push it up to S3.
    // 				    sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html'

    // 				}else if( env.BRANCH_NAME == 'snapshot' ){

    // 				    // Currently, the "daily"
    // 				    // debugging buckets are intended
    // 				    // to be RO directly in S3 for
    // 				    // debugging.
    // 				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket go-data-product-daily/$START_DAY --number $BUILD_ID --pipeline $BRANCH_NAME'

    // 				}else if( env.BRANCH_NAME == 'master' ){
    // 				    // Pass.
    // 				}

    // 				// Invalidate the CDN now that the new
    // 				// files are up.
    // 				sh 'echo "[preview]" > ./awscli_config.txt && echo "cloudfront=true" >> ./awscli_config.txt'
    // 				sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_DISTRIBUTION_ID --paths "/*"'
    // 				// The release branch also needs to
    // 				// deal with the second location.
    // 				if( env.BRANCH_NAME == 'release' ){
    // 				    sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID --paths "/*"'
    // 				}
    // 			    }
    // 			}
    // 		    }
    // 		}
    // 	    }
    // 	    // WARNING: Extra safety as I expect this to sometimes fail.
    // 	    post {
    // 		always {
    // 		    // Bail on the remote filesystem.
    // 		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
    // 		}
    // 	    }
    // 	}
    }
    // post {
    // 	// Let's let our people know if things go well.
    // 	success {
    // 	    script {
    // 		if( env.BRANCH_NAME == 'release' ){
    // 		    echo "There has been a successful run of the ${env.BRANCH_NAME} pipeline."
    // 		    emailext to: "${TARGET_SUCCESS_EMAILS}",
    // 			subject: "GO Pipeline success for ${env.BRANCH_NAME}",
    // 			body: "There has been successful run of the ${env.BRANCH_NAME} pipeline. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
    // 		}
    // 	    }
    // 	}
    // 	// Let's let our internal people know if things change.
    // 	changed {
    // 	    echo "There has been a change in the ${env.BRANCH_NAME} pipeline."
    // 	    emailext to: "${TARGET_ADMIN_EMAILS}",
    // 		subject: "GO Pipeline change for ${env.BRANCH_NAME}",
    // 		body: "There has been a pipeline status change in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
    // 	}
    // 	// Let's let our internal people know if things go badly.
    // 	failure {
    // 	    echo "There has been a failure in the ${env.BRANCH_NAME} pipeline."
    // 	    emailext to: "${TARGET_ADMIN_EMAILS}",
    // 		subject: "GO Pipeline FAIL for ${env.BRANCH_NAME}",
    // 		body: "There has been a pipeline failure in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
    // 	    }
    //   }
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
}
