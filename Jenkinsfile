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
	/// Automatic run variables.
	///

	// Pin dates and day to beginning of run.
	START_DATE = sh (
	    script: 'date +%Y-%m-%d',
	    returnStdout: true
	).trim()

	START_DAY = sh (
	    script: 'date +%A',
	    returnStdout: true
	).trim()

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
	//TARGET_MINERVA_BRANCH = 'master'
	TARGET_MINERVA_BRANCH = 'issue-500'
	// The branch of ROBOT to use in one silly section.
	// Necessary due to java version jump.
	// https://github.com/ontodev/robot/issues/997
	TARGET_ROBOT_BRANCH = 'master'
	// The branch of noctua-models to use.
	TARGET_NOCTUA_MODELS_BRANCH = 'master'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,suzia@stanford.edu,smoxon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,pascale.gaudet@sib.swiss,pgaudet1@gmail.com,smoxon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'go-data-product-experimental'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'http://experimental.geneontology.io'
	// This variable should typically be 'TRUE', which will cause
	// some additional basic checks to be made. There are some
	// very exotic cases where these check may need to be skipped
	// for a run, in that case this variable is set to 'FALSE'.
	WE_ARE_BEING_SAFE_P = 'TRUE'
	// Variable to check if the "hard" ZENODO archive stage was passed.
	ZENODO_ARCHIVING_SUCCESSFUL = 'FALSE'
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

	PANTHER_VERSION = '15.0'
	// Currently unused, but see:
	// https://github.com/geneontology/pipeline/issues/86
	PAINT_RELEASE = 'XXXX-YY-ZZ'

	///
	/// Application tokens.
	///

	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
	ZENODO_REFERENCE_CONCEPT = '425671'
	ZENODO_ARCHIVE_CONCEPT = '425674'
	// Distribution ID for the AWS CloudFront for this branch,
	// used soley for invalidations. Versioned release does not
	// need this as it is always a new location and the index
	// upload already has an invalidation on it. For current,
	// snapshot, and experimental.
	AWS_CLOUDFRONT_DISTRIBUTION_ID = 'E2CDVG5YT5R4K4'
	AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'E2HF1DWYYDLTQP'

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
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-gaf.owl",
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/gorel.owl",
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-modules-annotations.owl",
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-taxon-subsets.owl",
	    "http://purl.obolibrary.org/obo/eco/eco-basic.owl",
	    "http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl",
	    // BUG: Temporarily lock in CL version; see:
	    // https://github.com/geneontology/go-ontology/issues/23510
	    //"http://purl.obolibrary.org/obo/cl/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/cl/releases/2022-02-16/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/pato.owl",
	    "http://purl.obolibrary.org/obo/po.owl",
	    "http://purl.obolibrary.org/obo/chebi.owl",
	    "http://purl.obolibrary.org/obo/uberon/basic.owl",
	    "http://purl.obolibrary.org/obo/wbbt.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/master/products/annotations/paint_other.gaf.gz",
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

		// Check that we do not affect public targets on
		// non-mainline runs.
		script {
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

		// Give us a minute to cancel if we want.
		sleep time: 1, unit: 'MINUTES'
		cleanWs deleteDirs: true, disableDeferredWipeout: true
	    }
	}
	stage('Initialize') {
	    steps {
		// Start preparing environment.
		parallel(
		    "Report": {
			sh 'env > env.txt'
			sh 'echo $BRANCH_NAME > branch.txt'
			sh 'echo "$BRANCH_NAME"'
			sh 'cat env.txt'
			sh 'cat branch.txt'
			sh 'echo $START_DAY > dow.txt'
			sh 'echo "$START_DAY"'
		    },
		    "Reset base": {
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
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/products/annotations || true'
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

			sh 'echo "Official release date: metadata/release-date.json" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
			sh 'echo "Official Zenodo archive DOI: metadata/release-archive-doi.json" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
			sh 'echo "Official Zenodo archive DOI: metadata/release-reference-doi.json" >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
			sh 'echo "TODO: Note software versions." >> $WORKSPACE/mnt/$BRANCH_NAME/summary.txt'
			// TODO: This should be wrapped in exception
			// handling. In fact, this whole thing should be.
			sh 'fusermount -u $WORKSPACE/mnt/ || true'
		    }
		)
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
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations/'
		    }
		}
	    }
	}
	// See https://github.com/geneontology/go-ontology for details
	// on the ontology release pipeline. This ticket runs
	// daily(TODO?) and creates all the files normally included in
	// a release, and deploys to S3.
	stage('Produce ontology') {
	    agent {
		docker {
		    image 'obolibrary/odkfull:v1.2.32'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root'
		}
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
		}
	    }
	}
	stage('Minerva generations') {
	    steps {
		parallel(
		    "Make Noctua GPAD": {

			// May be parallelized in the future, but may need to
			// serve as input into into mega step.
			script {

			    // Create a relative working directory and setup our
			    // data environment.
			    dir('./noctua-models') {

				// Attempt to trim/prune/speed up
				// noctua-models as we do for
				// go-ontology for
				// https://github.com/geneontology/pipeline/issues/278
				// .
				checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: TARGET_NOCTUA_MODELS_BRANCH]], extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true, timeout: 120]], userRemoteConfigs: [[url: 'https://github.com/geneontology/noctua-models.git', refspec: "+refs/heads/${env.TARGET_NOCTUA_MODELS_BRANCH}:refs/remotes/origin/${env.TARGET_NOCTUA_MODELS_BRANCH}"]]]

				// Make all software products
				// available in bin/ (and lib/).
				sh 'mkdir -p bin/'
				sh 'mkdir -p lib/'
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
				    // WARNING/BUG: needed for blazegraph-runner
				    // to run at this point.
				    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/* ./lib/'
				}
				sh 'chmod +x bin/*'

				// Compile models.
				sh 'mkdir -p legacy/gpad'
				withEnv(['MINERVA_CLI_MEMORY=128G']){
				    // "Import" models.
				    sh './bin/minerva-cli.sh --import-owl-models -f models -j blazegraph.jnl'
				    // Convert GO-CAM to GPAD.
				    sh './bin/minerva-cli.sh --lego-to-gpad-sparql --ontology $MINERVA_INPUT_ONTOLOGIES --ontojournal ontojournal.jnl -i blazegraph.jnl --gpad-output legacy/gpad'
				}

				// Collation.
				sh 'perl ./util/collate-gpads.pl legacy/gpad/*.gpad'

				// Rename, compress, and move to skyhook.
				sh 'mcp "legacy/*.gpad" "legacy/noctua_#1-src.gpad"'
				sh 'gzip -vk legacy/noctua_*.gpad'
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY legacy/noctua_*-src.gpad.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations/'
				}
			    }
			}
		    },
		    "JSON model generation": {

			// May be parallelized in the future, but may need to
			// serve as input into into mega step.
			script {

			    // Create a relative working directory and setup our
			    // data environment.
			    dir('./json-noctua-models') {

				// Attempt to trim/prune/speed up
				// noctua-models as we do for
				// go-ontology for
				// https://github.com/geneontology/pipeline/issues/278
				// .
				checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: TARGET_NOCTUA_MODELS_BRANCH]], extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true, timeout: 120]], userRemoteConfigs: [[url: 'https://github.com/geneontology/noctua-models.git', refspec: "+refs/heads/${env.TARGET_NOCTUA_MODELS_BRANCH}:refs/remotes/origin/${env.TARGET_NOCTUA_MODELS_BRANCH}"]]]

				// Make all software products
				// available in bin/ (and lib/).
				sh 'mkdir -p bin/'
				sh 'mkdir -p lib/'
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
				    // WARNING/BUG: needed for blazegraph-runner
				    // to run at this point.
				    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/* ./lib/'
				}
				sh 'chmod +x bin/*'

				// Compile models.
				sh 'mkdir -p jsonout'
				withEnv(['MINERVA_CLI_MEMORY=128G']){
				    // "Import" models.
				    sh './bin/minerva-cli.sh --import-owl-models -f models -j blazegraph.jnl'
				    // JSON out to directory.
				    sh './bin/minerva-cli.sh --dump-owl-json --journal blazegraph.jnl --ontojournal blazegraph-go-lego-reacto-neo.jnl --folder jsonout'
				}

				// Compress and out.
				sh 'tar --use-compress-program=pigz -cvf noctua-models-json.tgz -C jsonout .'
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY noctua-models-json.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/json/'
				}
			    }
			}
		    }
		)
	    }
	}

	stage('Produce GAFs, TTLs, and journal (mega-step)') {
	    agent {
		docker {
		    image 'geneontology/dev-base:857fc148379e5afea6c27f798d4c62b2fadf3577_2021-04-27T182251'
		    args "-u root:root --tmpfs /opt:exec -w /opt"
		}
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
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations/*.gaf*  /opt/go-site/sources/'
		}
		sh "chmod +x /opt/bin/*"

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
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*\\(\\-src.gaf\\|\\-src.gpi\\|\\_noiea.gaf\\|\\_valid.gaf\\|paint\\_.*\\).gz$" -not -regex "^.*.ttl.gz$" -not -regex "^.*goa_uniprot_all_noiea.gaf.gz$" -not -regex "^.*.ttl.gz$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations \\;'
		    // No longer copy goa uniprot all source to products:
		    // https://github.com/geneontology/pipeline/issues/207
		    // // Now copy over the (single) uniprot
		    // // non-core; may not be there in all runs
		    // // (e.g. speed runs of master).
		    // script {
		    // 	try {
		    // 	    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/pipeline/target/groups/goa/goa_uniprot_all-src.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations'
		    // 	} catch (exception) {
		    // 	    echo "NOTE: No goa_uniprot_all-src.gaf.gz found for this run to copy."
		    // 	}
		    // }
		    // Finally, the non-zipped prediction files.
		    sh 'find /opt/go-site/pipeline/target/groups -type f -regex "^.*\\-prediction.gaf$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations \\;'
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
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/blazegraph-production.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/blazegraph-internal.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
		    // Copy the reports into reports.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /opt/go-site/pipeline/target/sparta-report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
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
	// WARNING: This stage is a hack required to work around data damage described in https://github.com/geneontology/go-site/issues/1484 and
	// https://github.com/geneontology/pipeline/issues/220.
	// Redownload annotations and run ontobio-parse-assocs over them in various ways.
	stage('Temporary post filter') {
	    agent {
		docker {
		    image 'geneontology/dev-base:857fc148379e5afea6c27f798d4c62b2fadf3577_2021-04-27T182251'
		    args "-u root:root --tmpfs /opt:exec -w /opt"
		}
	    }
	    steps {

		// Starting with https://github.com/geneontology/go-site/issues/1484,
		// prepare a working directory based around go-site.
		sh "cd /opt/ && git clone -b $TARGET_GO_SITE_BRANCH https://github.com/geneontology/go-site.git"

		sh "mkdir -p /opt/go-site/annotations /opt/go-site/annotations_new /opt/go-site/gaferencer-products"

		sh "cd /opt/go-site/pipeline && pip3 install -r requirements.txt"

		// Download gaferencer products and /annotations
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations/* /opt/go-site/annotations/'
		    // Get rid of goa_uniprot_all_noiea-type products
		    // as they take too long to run.
		    sh 'rm -f /opt/go-site/annotations/*uniprot_all* || true'
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/gaferencer/all.gaferences.json.gz /opt/go-site/gaferencer-products/'

		    //sh "$MAKECMD -f /opt/go-site/scripts/Makefile-gaf-reprocess all"
		    sh "make -f /opt/go-site/scripts/Makefile-gaf-reprocess all"

		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/annotations_new/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
		    // sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/gaferencer-products/all.gaferences.json.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/gaferencer/gaferences.json.gz'

		    // From here, we are making corrections to the Noctua
		    // GPADs (https://github.com/geneontology/pipeline/issues/220) to fix errors that are
		    // apparent in the model upstream.
		    sh "mkdir -p /opt/go-site/noctua_sources /opt/go-site/noctua_target"

		    // Download source noctua files from skyhook
		    // Download noctua_*.gpad.gz from products/annotations/ in skyhook
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations/noctua_*-src.gpad.gz /opt/go-site/noctua_sources/'
		    // Do we need GPI files for GO Rules? Maybe? Try and see if these are needed for GO Rules.

		    // Run the noctua gpad through ontobio
		    withEnv(["ONTOLOGY=${VALIDATION_ONTOLOGY_URL}"]){
			sh "make -f /opt/go-site/scripts/Makefile-gaf-reprocess noctua_gpad"
		    }

		    // Upload result files to skyhook
		    // Upload noctua valid to skyhook
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/noctua_target/noctua*.gpad.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/noctua_target/*.report.* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports'
		}
	    }
	}
	// A new step to think about. What is our core metadata?
	stage('Produce metadata') {
	    steps {

		// Prep a copyover point, as the overhead for doing
		// large i/o over sshfs seems /really/ high.
		sh 'mkdir -p $WORKSPACE/copyover/ || true'
		// Mount the remote filesystem.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy over the files that we want to work on--both
		// annotations/ and reports/ (which we separated
		// earlier).
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/reports/* $WORKSPACE/copyover/'
		script {
		    try {
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/paint_* $WORKSPACE/copyover/'
		    } catch (exception) {
			// No PAINT files this run? It could happen if
			// on a limited run with only non-PAINT
			// resources involved (e.g. speed run master).
			echo "NOTE: No PAINT files were found for this run to copy."
		    }
		}
		// Make all software products available in bin/.
		sh 'mkdir -p $WORKSPACE/bin/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* $WORKSPACE/bin/'
		}
		sh 'chmod +x $WORKSPACE/bin/*'

		// Prepare a working directory based around go-site.
		dir('./go-site') {
		    git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		    // Generate interesting PANTHER information
		    // (.arbre files) based on upstream source.
		    sh 'wget -N http://data.pantherdb.org/PANTHER$PANTHER_VERSION/globals/tree_files.tar.gz'
		    sh 'wget -N http://data.pantherdb.org/PANTHER$PANTHER_VERSION/globals/names.tab'
		    sh 'tar -zxvf tree_files.tar.gz'
		    sh 'python3 ./scripts/prepare-panther-arbre-directory.py -v --names names.tab --trees tree_files --output arbre'
		    sh 'tar --use-compress-program=pigz -cvf arbre.tgz -C arbre .'
		    sh 'mv arbre.tgz $WORKSPACE/mnt/$BRANCH_NAME/products/panther'

		    // Generate combined annotation report for driving
		    // annotation download pages and drop it into
		    // reports/ for copyover.
		    sh 'python3 ./scripts/aggregate-json-reports.py -v --directory $WORKSPACE/copyover --metadata ./metadata/datasets --output ./combined.report.json'

		    // Generate the static download page directly from
		    // the metadata.
		    sh 'python3 ./scripts/downloads-page-gen.py -v --report ./combined.report.json --date $START_DATE --inject ./scripts/downloads-page-template.html > ./downloads.html'

		    // Generate the a users.yaml report for missing
		    // data in the GO pattern.
		    sh 'python3 ./scripts/sanity-check-users-and-groups.py --users metadata/users.yaml --groups metadata/groups.yaml > ./users-and-groups-report.txt'
		    // WARNING: Caveats and reasons as above. Started
		    // as be need* to process frontmatter using our
		    // in-house "yamldown" parser.
		    sh 'python3 -m venv mypyenv'
		    withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

			// "External" packages required to run these
			// scripts.
			sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall click==7.1.2'
			sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'
			sh 'python3 ./mypyenv/bin/pip3 install yamldown'
			sh 'python3 ./mypyenv/bin/pip3 install pypandoc'

			// Generate the static overall gorule report
			// page.

			// Build either a release or testing
			// version of a generic BDBag/DOI
			// workflow, keeping special bucket
			// mappings in mind.
			script {
			    if( env.GORULE_TAGS_TO_SUPPRESS && env.GORULE_TAGS_TO_SUPPRESS != "" ){
				sh 'python3 ./scripts/reports-page-gen.py --report ./combined.report.json --template ./scripts/reports-page-template.html --date $START_DATE --suppress-rule-tag $GORULE_TAGS_TO_SUPPRESS > gorule-report.html'
			    }else{
				sh 'python3 ./scripts/reports-page-gen.py --report ./combined.report.json --template ./scripts/reports-page-template.html --date $START_DATE > gorule-report.html'
			    }
			}

			// Generate the new GO refs data.
			sh 'python3 ./scripts/aggregate-references.py -v --directory ./metadata/gorefs --json ./metadata/go-refs.json --stanza ./metadata/GO.references'
		    }

		    // Get the date into the metadata, in a similar format
		    // to what is produced by the Zenodo sections.
		    sh 'echo \'{\' > ./metadata/release-date.json'
		    sh 'echo -n \'    "date": "\' >> ./metadata/release-date.json'
		    sh 'echo -n "$START_DATE" >> ./metadata/release-date.json'
		    sh 'echo \'"\' >> ./metadata/release-date.json'
		    sh 'echo \'}\' >> ./metadata/release-date.json'

		    // Some scripts that require NPM.
		    withEnv(['PATH+EXTRA=../bin:node_modules/.bin']){
			sh 'npm install'

			// Generate the TTL from users.yaml and
			// groups.yaml.  This is meant to be an
			// unwinding of the somewhat too hard-coded
			// go-site/scripts/yaml2turtle.sh from Jim.
			//sh 'GRPTEMP=`mktemp --tmpdir=. --suffix=.jsonld`'
			sh 'echo \'{"@context": \' > ./metadata/groups.tmp.jsonld'
			sh 'yaml2json ./metadata/users-groups-context.yaml >> ./metadata/groups.tmp.jsonld'
			sh 'echo \', "@graph": \' >> ./metadata/groups.tmp.jsonld'
			sh 'yaml2json metadata/groups.yaml >> ./metadata/groups.tmp.jsonld'
			sh 'echo \'}\' >> ./metadata/groups.tmp.jsonld'
			sh 'robot convert -i ./metadata/groups.tmp.jsonld -o ./metadata/groups.ttl'
			//sh 'USRTEMP=`mktemp --tmpdir=. --suffix=.jsonld`'
			sh 'echo \'{"@context": \' > ./metadata/users.tmp.jsonld'
			sh 'yaml2json ./metadata/users-groups-context.yaml >> ./metadata/users.tmp.jsonld'
			sh 'echo \', "@graph": \' >> ./metadata/users.tmp.jsonld'
			sh 'yaml2json metadata/users.yaml >> ./metadata/users.tmp.jsonld'
			sh 'echo \'}\' >> ./metadata/users.tmp.jsonld'
			sh 'robot convert -i ./metadata/users.tmp.jsonld -o ./metadata/users.ttl'

			// Convert db-xrefs into the legacy xrefs
			// formats.
			sh 'yaml2json -p ./metadata/db-xrefs.yaml > ./metadata/db-xrefs.json'
			sh 'node ./scripts/db-xrefs-yaml2legacy.js -i ./metadata/db-xrefs.yaml > ./metadata/db-xrefs.legacy'
			sh 'cp ./metadata/db-xrefs.legacy ./metadata/GO.xrf_abbs'

			// Contraints for Alex.
			sh 'yaml2json -p ./metadata/eco-usage-constraints.yaml > ./metadata/eco-usage-constraints.json'
		    }

		    // Carry everything we want to save over to
		    // skyhook.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {

			// Copy all upstream metadata into metadata folder.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" metadata/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/metadata'

			// Copy all of the reports to the reports
			// directory.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./combined.report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports'
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./users-and-groups-report.txt skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports'

			// Copy generated pages over to page output.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./downloads.html skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/pages'
			// Copy gorule report page to the reports directory
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./gorule-report.html skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports'
		    }

		    // Produce the slightly improved combined reports
		    // inplace on remote.
		    sh 'python3 ./scripts/merge-all-reports.py --verbose --directory $WORKSPACE/mnt/$BRANCH_NAME/reports'
		}
		// Run and report shared annotation check.
		dir('./shared-annotation-check') {
		    git url: 'https://github.com/geneontology/shared-annotation-check.git'
		    // Setup.
		    withEnv(['PATH+EXTRA=../bin:node_modules/.bin']){
			sh 'npm install'
			// Run annotation checks.
			sh 'node ./check-runner.js -i ./rules.txt -o $WORKSPACE/mnt/$BRANCH_NAME/reports/shared-annotation-check.html'
		    }
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
		always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
		    // Purge the copyover point.
		    sh 'rm -r -f $WORKSPACE/copyover || true'
		}
	    }
	}
	stage('Sanity I') {
	    steps {
		// Prep a copyover point, as the overhead for doing
		// large i/o over sshfs seems /really/ high.
		sh 'mkdir -p $WORKSPACE/copyover/ || true'
		// Mount the remote filesystem.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy over the files that we want to work on--both
		// annotations/ and reports/ (which we separated
		// earlier).
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/reports/* $WORKSPACE/copyover/'
		// Ready...
		dir('./go-site') {
		    git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		    // Run sanity checks.
		    sh 'python3 ./scripts/sanity-check-ann-report.py -v -d $WORKSPACE/copyover/ --ignore_noctua'
		    // Make sure that the SPARTA report has nothing
		    // nasty in it.
		    // Note: Used to be pipes (|), but Jenkins Pipeline shell
		    // commands do not apparently respect that.
		    sh 'jq \'.build\' $WORKSPACE/copyover/sparta-report.json > $WORKSPACE/build-status.txt'
		    sh 'grep -v \'fail\' $WORKSPACE/build-status.txt'
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
		always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
		    // Purge the copyover point.
		    sh 'rm -r -f $WORKSPACE/copyover || true'
		}
	    }
	}
	//...
	stage('Produce derivatives') {
	    agent {
		docker {
		    image 'geneontology/golr-autoindex:28a693d28b37196d3f79acdea8c0406c9930c818_2022-03-17T171930_master'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root --mount type=tmpfs,destination=/srv/solr/data'
		}
	    }
	    steps {

		// Build index into tmpfs.
		sh 'bash /tmp/run-indexer.sh'

		// Copy tmpfs Solr contents onto skyhook.
		sh 'tar --use-compress-program=pigz -cvf /tmp/golr-index-contents.tgz -C /srv/solr/data/index .'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // Copy over index.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/solr/'
		    // Copy over log.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/solr/'
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
			sh 'python3 /tmp/go_reports.py -g http://localhost:8080/solr/ -s http://current.geneontology.org/release_stats/go-stats.json -n http://current.geneontology.org/release_stats/go-stats-no-pb.json -c http://skyhook.berkeleybop.org/$BRANCH_NAME/ontology/go.obo -p http://current.geneontology.org/ontology/go.obo -r http://current.geneontology.org/release_stats/go-references.tsv -o /tmp/stats/ -d $START_DATE'
		    }
		    retry(3) {
		    	sh 'wget -N http://current.geneontology.org/release_stats/aggregated-go-stats-summaries.json'
		    }

		    // Roll the stats forward.
		    sh 'python3 /tmp/aggregate-stats.py -a aggregated-go-stats-summaries.json -b /tmp/stats/go-stats-summary.json -o /tmp/stats/aggregated-go-stats-summaries.json'

		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    	retry(3) {
			    // Copy over stats files.
			    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/stats/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/release_stats/'
			}
		    }
		}
	    }
	}
	//...
	stage('Sanity II') {
	    when { anyOf { branch 'release' } }
	    steps {

		//
		echo 'Push pre-release to http://amigo-staging.geneontology.io for testing.'

		// Ninja in our file credentials from Jenkins.
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY'), file(credentialsId: 'go-svn-private-key', variable: 'GO_SVN_IDENTITY'), file(credentialsId: 'ansible-bbop-local-slave', variable: 'DEPLOY_LOCAL_IDENTITY'), file(credentialsId: 'go-aws-ec2-ansible-slave', variable: 'DEPLOY_REMOTE_IDENTITY')]) {

		    // Get our operations code and decend into ansible
		    // working directory.
		    dir('./operations') {

			git([branch: 'master',
			     credentialsId: 'bbop-agent-github-user-pass',
			     url: 'https://github.com/geneontology/operations.git'])
			dir('./ansible') {

			    retry(3){
				sh 'ansible-playbook update-golr-w-skyhook-forced.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e skyhook_branch=release -e target_host=amigo-golr-staging'
			    }

			    // Pause on user input.
			    echo 'Sanity II: Awaiting user input before proceeding.'
			    emailext to: "${TARGET_RELEASE_HOLD_EMAILS}",
				subject: "GO Pipeline waiting on input for ${env.BRANCH_NAME}",
				body: "The ${env.BRANCH_NAME} pipeline is waiting on user input. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
			    lock(resource: 'release-run', inversePrecedence: true) {
				echo "Sanity II: A release run holds the lock."
				timeout(time:7, unit:'DAYS') {
				    input message:'Approve release products?'
				}
			    }
			    echo 'Sanity II: Positive user input input given.'
			}
		    }
		}
	    }
	}
	stage('Archive') {
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Experimental stanza to support mounting the sshfs
		// using the "hidden" skyhook identity.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'

		    // Try to catch and prevent goa_uniprot_all-src from getting into zenodo archive, etc.
		    // https://github.com/geneontology/pipeline/issues/207
		    sh 'pwd'
		    sh 'ls -AlF $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/ || true'
		    sh 'rm -f $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/goa_uniprot_all-src.gaf.gz || true'
		    sh 'ls -AlF $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/ || true'
		}
		// Copy the product to the right location. As well,
		// archive.
		withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'zenodo_go_production_token', variable: 'ZENODO_PRODUCTION_TOKEN'), string(credentialsId: 'zenodo_go_sandbox_token', variable: 'ZENODO_SANDBOX_TOKEN')]) {
		    // Ready...
		    dir('./go-site') {
			git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

			// WARNING: Caveats and reasons as same
			// pattern above. We need this as some clients
			// are not standard and it turns out there are
			// some subtle incompatibilities with urllib3
			// and boto in some versions, so we will use a
			// virtual env to paper that over.  See:
			// https://github.com/geneontology/pipeline/issues/8#issuecomment-356762604
			sh 'python3 -m venv mypyenv'
			withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

			    // Extra package for the indexer.
			    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'

			    // Correct for (possibly) bad boto3,
			    // as mentioned above.
			    sh 'python3 ./mypyenv/bin/pip3 install boto3==1.18.52'
			    sh 'python3 ./mypyenv/bin/pip3 install botocore==1.21.52'

			    // Needed to work around new incompatibility:
			    // https://github.com/geneontology/pipeline/issues/286
			    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall certifi==2021.10.8'

			    // Extra package for the uploader.
			    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

			    // Grab BDBag.
			    sh 'python3 ./mypyenv/bin/pip3 install bdbag'

			    // Need for large uploads in requests.
			    sh 'python3 ./mypyenv/bin/pip3 install requests-toolbelt'

			    // Need as replacement for awful requests lib.
			    sh 'python3 ./mypyenv/bin/pip3 install pycurl'

			    // Apparently something wrong with default
			    // version; error like
			    // https://stackoverflow.com/questions/45821085/awshttpsconnection-object-has-no-attribute-ssl-context
			    sh 'python3 ./mypyenv/bin/pip3 install awscli'

			    // A temporary workaround for
			    // https://github.com/geneontology/pipeline/issues/247,
			    // forcing requests used by bdbags to a
			    // verion that is usable by python 3.5
			    // (our current raw machine default
			    // version of python3).
			    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall requests==2.25.1'

			    // Well, we need to do a couple of things here in
			    // a structured way, so we'll go ahead and drop
			    // into the scripting mode.
			    script {

				// Build either a release or testing
				// version of a generic BDBag/DOI
				// workflow, keeping special bucket
				// mappings in mind.
				if( env.BRANCH_NAME == 'release' ){
				    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/$BRANCH_NAME/ --remote http://release.geneontology.org/$START_DATE --output manifest.json'
				}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'master' ){
				    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/$BRANCH_NAME/ --remote $TARGET_INDEXER_PREFIX --output manifest.json'
				}

				// Make holey BDBag in fixed directory.
				sh 'mkdir -p go-release-reference || true'
				sh 'python3 ./mypyenv/bin/bdbag ./go-release-reference --remote-file-manifest manifest.json --archive tgz'

				// To make a full BDBag, we first need
				// a copy of the data as BDBags change
				// directory layout (e.g. data/).
				sh 'mkdir -p $WORKSPACE/copyover/ || true'
				sh 'cp -r $WORKSPACE/mnt/$BRANCH_NAME/* $WORKSPACE/copyover/'
				// Make the BDBag in the copyover/
				// (unarchived, as we want to leave it
				// to pigz).
				sh 'python3 ./mypyenv/bin/bdbag $WORKSPACE/copyover'
				// Tarball the whole directory for
				// "deep" archive (handmade BDBag).
				sh 'tar --use-compress-program=pigz -cvf go-release-archive.tgz -C $WORKSPACE/copyover .'

				// We have the archives, now let's try
				// and get them into position--this is
				// fail-y, so we are going to try and
				// buffer failure here for the time
				// being until we work it all out. We
				// are going to do the "hard"/large
				// one first, then skip the
				// "easy"/small one if we fail, so
				// that we can retry this whole stage
				// again on failure.
				try {
				    // Archive full archive.
				    if( env.BRANCH_NAME == 'release' ){
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --key $ZENODO_PRODUCTION_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
				    }else if( env.BRANCH_NAME == 'snapshot' ){
					// WARNING: to save Zenodo 1TB
					// a month, for snapshot,
					// we'll lie about the DOI
					// that we get (not a big lie
					// as they don't resolve on
					// sandbox anyways).
					//sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
					sh 'echo \'{\' > ./release-archive-doi.json'
					sh 'echo \'    "doi": "10.5072/zenodo.000000"\' >> ./release-archive-doi.json'
					sh 'echo \'}\' >> ./release-archive-doi.json'

				    }else if( env.BRANCH_NAME == 'master' ){
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
				    }

				    // Get the DOI to skyhook for
				    // publishing, but don't bother
				    // with the full thing--too much
				    // space and already in Zenodo.
				    sh 'cp release-archive-doi.json $WORKSPACE/mnt/$BRANCH_NAME/metadata/release-archive-doi.json'

				    // We were successful.
				    ZENODO_ARCHIVING_SUCCESSFUL = 'TRUE'

				} catch (exception) {
				    // Something went bad with the
				    // Zenodo archive upload.
				    echo "There has been a failure in the archive upload to Zenodo."
				    emailext to: "${TARGET_ADMIN_EMAILS}",
					subject: "GO Pipeline Zenodo archive upload fail for ${env.BRANCH_NAME}",
					body: "There has been a failure in the archive upload to Zenodo, in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
				    // Hard die if this is a release.
				    if( env.BRANCH_NAME == 'release' ){
					error 'Zenodo archive upload error on release--no recovery.'
				    }
				}
				try {

				    // Do not attempt the "easy" path
				    // if the hard one failed so we
				    // can retry later at the stage
				    // level.
				    if( ZENODO_ARCHIVING_SUCCESSFUL == 'FALSE' ){
					error "Pre-failing on reference after a failed archive so we can retry at the stage level."
				    }

				    // Archive the holey bdbag for
				    // this run.
				    if( env.BRANCH_NAME == 'release' ){
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --key $ZENODO_PRODUCTION_TOKEN --concept $ZENODO_REFERENCE_CONCEPT --file go-release-reference.tgz --output ./release-reference-doi.json --revision $START_DATE'
				    }else if( env.BRANCH_NAME == 'snapshot' ){
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_REFERENCE_CONCEPT --file go-release-reference.tgz --output ./release-reference-doi.json --revision $START_DATE'
				    }else if( env.BRANCH_NAME == 'master' ){
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_SANDBOX_TOKEN --concept $ZENODO_REFERENCE_CONCEPT --file go-release-reference.tgz --output ./release-reference-doi.json --revision $START_DATE'
				    }
				    // Copy the referential metadata
				    // files and DOI to skyhook
				    // metadata/ for easy inspection.
				    sh 'cp go-release-reference.tgz $WORKSPACE/mnt/$BRANCH_NAME/metadata/go-release-reference.tgz'
				    sh 'cp manifest.json $WORKSPACE/mnt/$BRANCH_NAME/metadata/bdbag-manifest.json'
				    sh 'cp release-reference-doi.json $WORKSPACE/mnt/$BRANCH_NAME/metadata/release-reference-doi.json'
				} catch (exception) {
				    // Something went bad with the
				    // Zenodo reference upload.
				    echo "There has been a failure in the reference upload to Zenodo."
				    emailext to: "${TARGET_ADMIN_EMAILS}",
					subject: "GO Pipeline Zenodo reference upload fail for ${env.BRANCH_NAME}",
					body: "There has been a failure in the reference upload to Zenodo, in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
				    // Hard die if this is a release.
				    if( env.BRANCH_NAME == 'release' ){
					error 'Zenodo reference upload error on release--no recovery.'
				    }
				}
			    }
			}
		    }
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
		always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
		    // Purge the copyover point.
		    sh 'rm -r -f $WORKSPACE/copyover || true'
		}
	    }
	}
	stage('Publish') {
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Experimental stanza to support mounting the sshfs
		// using the "hidden" skyhook identity.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy the product to the right location. As well,
		// archive.
		withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
		    // Ready...
		    dir('./go-site') {
			git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

			// TODO: Special handling still needed w/o OSF.io?
			// WARNING: Caveats and reasons as same
			// pattern above. We need this as some clients
			// are not standard and it turns out there are
			// some subtle incompatibilities with urllib3
			// and boto in some versions, so we will use a
			// virtual env to paper that over.  See:
			// https://github.com/geneontology/pipeline/issues/8#issuecomment-356762604
			sh 'python3 -m venv mypyenv'
			withEnv(["PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){

			    // Extra package for the indexer.
			    sh 'python3 ./mypyenv/bin/pip3 install --force-reinstall pystache==0.5.4'

			    // Extra package for the uploader.
			    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

			    // Let's be explicit here as well, as there were recent issues.
			    //
			    sh 'python3 ./mypyenv/bin/pip3 install rsa'
			    sh 'python3 ./mypyenv/bin/pip3 install awscli'

			    // Version locking for boto3 / botocore
			    // upgrade that is incompatible with
			    // python3.5. See issues #250 and #271.
			    sh 'python3 ./mypyenv/bin/pip3 install boto3==1.18.52'
			    sh 'python3 ./mypyenv/bin/pip3 install botocore==1.21.52'
			    sh 'python3 ./mypyenv/bin/pip3 install s3transfer==0.5.0'

			    // Well, we need to do a couple of things here in
			    // a structured way, so we'll go ahead and drop
			    // into the scripting mode.
			    script {

				// Create working index off of
				// skyhook. For "release", this will
				// be "current". For "snapshot", this
				// will be "snapshot".
				sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/$BRANCH_NAME --prefix $TARGET_INDEXER_PREFIX -x'

				// Push into S3 buckets. Simple
				// overall case: copy tree directly
				// over. For "release", this will be
				// "current". For "snapshot", this
				// will be "snapshot".
				sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket $TARGET_BUCKET --number $BUILD_ID --pipeline $BRANCH_NAME'

				// Also, some runs have special maps
				// to buckets...
				if( env.BRANCH_NAME == 'release' ){

				    // "release" -> dated path for
				    // indexing (clobbering
				    // "current"'s index.
				    sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/$BRANCH_NAME --prefix http://release.geneontology.org/$START_DATE -x -u'
				    // "release" -> dated path for S3.
				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket go-data-product-release/$START_DATE --number $BUILD_ID --pipeline $BRANCH_NAME'

				    // Build the capper index.html...
				    sh 'python3 ./scripts/bucket-indexer.py --credentials $S3_PUSH_JSON --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html'
				    // ...and push it up to S3.
				    sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html'

				}else if( env.BRANCH_NAME == 'snapshot' ){

				    // Currently, the "daily"
				    // debugging buckets are intended
				    // to be RO directly in S3 for
				    // debugging.
				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/$BRANCH_NAME/ --bucket go-data-product-daily/$START_DAY --number $BUILD_ID --pipeline $BRANCH_NAME'

				}else if( env.BRANCH_NAME == 'master' ){
				    // Pass.
				}

				// Invalidate the CDN now that the new
				// files are up.
				sh 'echo "[preview]" > ./awscli_config.txt && echo "cloudfront=true" >> ./awscli_config.txt'
				sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_DISTRIBUTION_ID --paths "/*"'
				// The release branch also needs to
				// deal with the second location.
				if( env.BRANCH_NAME == 'release' ){
				    sh 'AWS_CONFIG_FILE=./awscli_config.txt python3 ./mypyenv/bin/aws cloudfront create-invalidation --distribution-id $AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID --paths "/*"'
				}
			    }
			}
		    }
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
		always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
		}
	    }
	}
	// Big things to do on major branches.
	stage('Deploy') {
	    // For exploration of #204, we'll hold back attempts to push out to AmiGO for master and snapshot
	    // so we don't keep clobbering #204 trials out.
	    //when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    when { anyOf { branch 'release' } }
	    steps {
		parallel(
		    "AmiGO": {

			// Ninja in our file credentials from Jenkins.
			withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY'), file(credentialsId: 'go-svn-private-key', variable: 'GO_SVN_IDENTITY'), file(credentialsId: 'ansible-bbop-local-slave', variable: 'DEPLOY_LOCAL_IDENTITY'), file(credentialsId: 'go-aws-ec2-ansible-slave', variable: 'DEPLOY_REMOTE_IDENTITY')]) {

			    // Get our operations code and decend into ansible
			    // working directory.
			    dir('./operations') {

				git([branch: 'master',
				     credentialsId: 'bbop-agent-github-user-pass',
				     url: 'https://github.com/geneontology/operations.git'])
				dir('./ansible') {
				    ///
				    /// Push out to an AmiGO.
				    ///
				    script {
					if( env.BRANCH_NAME == 'release' ){

					    echo 'No current public push on release to Blazegraph.'
					    // retry(3){
					    //	sh 'ansible-playbook update-endpoint.yaml --inventory=hosts.local-rdf-endpoint --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_user=bbop --extra-vars="pipeline=current build=production endpoint=production"'
					    // }

					    echo 'No current public push on release to GOlr.'
					    // retry(3){
					    //	sh 'ansible-playbook ./update-golr.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_host=amigo-golr-aux -e target_user=bbop'
					    // }
					    // retry(3){
					    //	sh 'ansible-playbook ./update-golr.yaml --inventory=hosts.amigo --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_host=amigo-golr-production -e target_user=bbop'
					    // }

					}else if( env.BRANCH_NAME == 'snapshot' ){

					    echo 'Push snapshot out internal Blazegraph'
					    retry(3){
						sh 'ansible-playbook update-endpoint.yaml --inventory=hosts.local-rdf-endpoint --private-key="$DEPLOY_LOCAL_IDENTITY" -e target_user=bbop --extra-vars="pipeline=current build=internal endpoint=internal"'
					    }

					    echo 'Push snapshot out to experimental AmiGO'
					    retry(3){
						sh 'ansible-playbook ./update-golr-w-snap.yaml --inventory=hosts.amigo --private-key="$DEPLOY_REMOTE_IDENTITY" -e target_host=amigo-golr-exp -e target_user=ubuntu'
					    }

					}else if( env.BRANCH_NAME == 'master' ){

					    echo 'Push master out to experimental AmiGO'
					    retry(3){
						sh 'ansible-playbook ./update-golr-w-exp.yaml --inventory=hosts.amigo --private-key="$DEPLOY_REMOTE_IDENTITY" -e target_host=amigo-golr-exp -e target_user=ubuntu'
					    }

					}
				    }
				}
			    }
			}
		    }
		)
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
		always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/ || true'
		}
	    }
	}
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
