pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    triggers {
	// Master never runs--Feb 31st.
	//cron('0 0 31 2 *')
	// Nightly @12am, for "snapshot", skip "release" night.
	//cron('0 0 2-31/2 * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
	// Every sixth hour, at the top--enough time to do reports if
	// necessary.
	cron('0 */6 * * *')
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
	TARGET_MINERVA_BRANCH = 'master'
	// The branch of ROBOT to use in one silly section.
	// Necessary due to java version jump.
	// https://github.com/ontodev/robot/issues/997
	TARGET_ROBOT_BRANCH = 'master'
	// The branch of noctua-models to use.
	TARGET_NOCTUA_MODELS_BRANCH = 'master'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	TARGET_CHANGE_EMAILS = 'balhoff@renci.org,cjmungall@lbl.gov,sjcarbon@lbl.gov,debert@usc.edu'
	//TARGET_CHANGE_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_FAIL_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'null'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'null'
	// This variable should typically be 'TRUE', which will cause
	// some additional basic checks to be made. There are some
	// very exotic cases where these check may need to be skipped
	// for a run, in that case this variable is set to 'FALSE'.
	WE_ARE_BEING_SAFE_P = 'TRUE'
	ONTOLOGY_ERROR_BUILD_P = 'FALSE'
	ONTOLOGY_ERROR_FULL_P = 'FALSE'
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
	ZENODO_REFERENCE_CONCEPT = 'null'
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
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/go-ontology-dev/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/go-ontology-dev/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/go-ontology-dev/ontology/extensions/go-gaf.owl",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/ontology/extensions/gorel.owl",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/ontology/extensions/go-modules-annotations.owl",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/ontology/extensions/go-taxon-subsets.owl",
	    "http://purl.obolibrary.org/obo/eco/eco-basic.owl",
	    "http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl",
	    // BUG: Temporarily lock in CL version; see:
	    // https://github.com/geneontology/go-ontology/issues/23510
	    //"http://purl.obolibrary.org/obo/cl/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/cl/releases/2022-02-16/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/pato.owl",
	    "http://purl.obolibrary.org/obo/po.owl",
	    "http://purl.obolibrary.org/obo/chebi.owl",
	    // BUG: Temporarily lock in uberon version; see:
	    // https://github.com/geneontology/go-ontology/issues/23468
	    //"http://purl.obolibrary.org/obo/uberon/basic.owl",
	    "http://purl.obolibrary.org/obo/uberon/releases/2022-05-17/uberon-basic.owl",
	    "http://purl.obolibrary.org/obo/wbbt.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/go-ontology-dev/products/annotations/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/aspgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/go-ontology-dev/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/go-ontology-dev/products/panther/arbre.tgz"
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
	RESOURCE_GROUPS="aspgd goa mgi paint pombase pseudocap wb"
	// Optional. Datasets to skip within the resources that we
	// will run (defined in the line above).
	DATASET_EXCLUDES="goa_uniprot_gcrp goa_pdb goa_chicken_isoform goa_chicken_rna goa_cow goa_cow_complex goa_cow_isoform goa_cow_rna goa_dog goa_dog_complex goa_dog_isoform goa_dog_rna goa_human goa_human goa_human_complex goa_human_rna paint_cgd paint_dictybase paint_ecocyc paint_fb paint_goa_chicken paint_goa_human paint_other paint_rgd paint_sgd paint_tair paint_zfin"
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
			script {
			    try {
				retry(1){
				    sh 'make RELEASEDATE=$START_DATE OBO=http://purl.obolibrary.org/obo ROBOT_ENV="ROBOT_JAVA_ARGS=-Xmx48G" all'
				}
				retry(1){
				    sh 'make prepare_release'
				}
			    } catch (exception) {
				ONTOLOGY_ERROR_BUILD_P = 'TRUE'
				echo "Exception: ONTOLOGY_ERROR_BUILD_P is now TRUE"
				sh 'robot --catalog ./catalog-v001.xml explain -i ./extensions/go-lego-edit.ofn -M unsatisfiability --unsatisfiable all --explanation ./unsatisfiable_explanations.md'
				sh 'echo $BUILD_ID | cat - ./unsatisfiable_explanations.md > ./unsatisfiable_explanations.md.tmp && mv -f ./unsatisfiable_explanations.md.tmp ./unsatisfiable_explanations.md'
				sh 'echo `date` | cat - ./unsatisfiable_explanations.md > ./unsatisfiable_explanations.md.tmp && mv -f ./unsatisfiable_explanations.md.tmp ./unsatisfiable_explanations.md'
			    }

			    // Only continue with the "deep" check if
			    // there was not a surface issue.
			    if( ONTOLOGY_ERROR_BUILD_P == 'FALSE' ){
				// Try and run robot no matter what, as
				// sometimes the ontology can build but
				// there are still errors.
				sh 'rm -f eco-basic.owl || true'
				sh 'rm -f taxslim.owl || true'
				sh 'rm -f cl-basic.owl || true'
				sh 'rm -f pato.owl || true'
				sh 'rm -f po.owl || true'
				sh 'rm -f chebi.owl || true'
				sh 'rm -f basic.owl || true'
				sh 'rm -f wbbt.owl || true'
				sh 'wget http://purl.obolibrary.org/obo/eco/eco-basic.owl'
				sh 'wget http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl'
				sh 'wget http://purl.obolibrary.org/obo/cl/cl-basic.owl'
				sh 'wget http://purl.obolibrary.org/obo/pato.owl'
				sh 'wget http://purl.obolibrary.org/obo/po.owl'
				sh 'wget http://purl.obolibrary.org/obo/chebi.owl'
				sh 'wget http://purl.obolibrary.org/obo/uberon/basic.owl'
				sh 'wget http://purl.obolibrary.org/obo/wbbt.owl'
				sh 'rm -f merged.owl || true'
				sh 'robot merge -i eco-basic.owl -i taxslim.owl -i cl-basic.owl -i pato.owl -i po.owl -i chebi.owl -i basic.owl -i wbbt.owl -i ./extensions/go-gaf.owl -i ./extensions/gorel.owl -i ./extensions/go-modules-annotations.owl -i ./extensions/go-taxon-subsets.owl -o merged.owl'
				sh 'robot explain -i ./merged.owl -M unsatisfiability --unsatisfiable all --explanation ./unsatisfiable_explanations_full.md'
				sh 'echo $BUILD_ID | cat - ./unsatisfiable_explanations_full.md > ./unsatisfiable_explanations_full.md.tmp && mv -f ./unsatisfiable_explanations_full.md.tmp ./unsatisfiable_explanations_full.md'
				sh 'echo `date` | cat - ./unsatisfiable_explanations_full.md > ./unsatisfiable_explanations_full.md.tmp && mv -f ./unsatisfiable_explanations_full.md.tmp ./unsatisfiable_explanations_full.md'

				// Check explanations.
				try {
				    sh 'grep "No explanations found" ./unsatisfiable_explanations_full.md'
				} catch (exception) {
				    ONTOLOGY_ERROR_FULL_P = 'TRUE'
				    echo "Exception: ONTOLOGY_ERROR_FULL_P is now TRUE"
				}
			    }

			    if( ONTOLOGY_ERROR_BUILD_P == 'TRUE' || ONTOLOGY_ERROR_FULL_P == 'TRUE' ){

				// Copy out to usual reports location.
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {

				    if( ONTOLOGY_ERROR_BUILD_P == 'TRUE' ){
					sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY unsatisfiable_explanations.md skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
				    }
				    if( ONTOLOGY_ERROR_FULL_P == 'TRUE' ){
					sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY unsatisfiable_explanations_full.md skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
				    }
				}

				// Copy out to S3, so we can actually get at it.
				// Stolen from https://github.com/geneontology/pipeline/blob/15a94a077de9944474dad69e384f95b69fbbd52f/Jenkinsfile#L1223 .
				withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON')]) {

				    // Install s3cmd
				    sh 'apt-get update'
				    sh 'apt-get -y -f install s3cmd'

				    // Transfer to bucket.
				    if( ONTOLOGY_ERROR_BUILD_P == 'TRUE' ){
					sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/plain put unsatisfiable_explanations.md s3://go-dropbox/unsatisfiable_explanations.md'
					error "BUILD exception in ontology build: see report at http://skyhook.berkeleybop.org/go-ontology-dev/reports/"
				    }else if( ONTOLOGY_ERROR_FULL_P == 'TRUE' ){
					sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/plain put unsatisfiable_explanations_full.md s3://go-dropbox/unsatisfiable_explanations_full.md'
					error "FULL exception in ontology build: see report at http://skyhook.berkeleybop.org/go-ontology-dev/reports/"
				    }else{
					// Finally, make sure we don't complete.
					error "Unknown exception in ontology build: see report at http://skyhook.berkeleybop.org/go-ontology-dev/reports/"
				    }
				}
			    }
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
    }
    post {
	// Let's let our people know if things go well.
	success {
	    script {
		if( env.BRANCH_NAME == 'release' ){
		    echo "There has been a successful run of the ${env.BRANCH_NAME} pipeline."
		    mail bcc: '', body: "There has been successful run of the ${env.BRANCH_NAME} pipeline. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline success for ${env.BRANCH_NAME}", to: "${TARGET_SUCCESS_EMAILS}"
		}
	    }
	}
	// Let's let our ontology people know if things change.
	changed {
	    script {
		if( ONTOLOGY_ERROR_BUILD_P == 'TRUE' ){
		    echo "Problem! There has been a negative change in the ${env.BRANCH_NAME} pipeline."
		    mail bcc: '', body: "Problem! There has been a negative pipeline status change in ${env.BRANCH_NAME}. Please see:\nhttps://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}\nhttps://go-dropbox.s3.amazonaws.com/unsatisfiable_explanations.md", cc: '', from: '', replyTo: '', subject: "GO Pipeline change for ${env.BRANCH_NAME}", to: "${TARGET_CHANGE_EMAILS}"
		}else if( ONTOLOGY_ERROR_FULL_P == 'TRUE' ){
		    echo "Problem! There has been a negative change in the ${env.BRANCH_NAME} pipeline."
		    mail bcc: '', body: "Problem! There has been a negative pipeline status change in ${env.BRANCH_NAME}. Please see:\nhttps://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}\nhttps://go-dropbox.s3.amazonaws.com/unsatisfiable_explanations_full.md", cc: '', from: '', replyTo: '', subject: "GO Pipeline change for ${env.BRANCH_NAME}", to: "${TARGET_CHANGE_EMAILS}"
		}else{
		    echo "Fixed! There has been a positive change in the ${env.BRANCH_NAME} pipeline."
		    mail bcc: '', body: "Fixed! There has been a positive pipeline status change in ${env.BRANCH_NAME}. You can congratulate it at:\nhttps://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline change for ${env.BRANCH_NAME}", to: "${TARGET_CHANGE_EMAILS}"
		}
	    }
	}
	// Let's let our internal dev people know if things go badly
	// or are continuing badly.
	failure {
	    echo "There has been a failure in the ${env.BRANCH_NAME} pipeline."
	    mail bcc: '', body: "There has been a (continuing?) pipeline failure in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline FAIL for ${env.BRANCH_NAME}", to: "${TARGET_FAIL_EMAILS}"
	}
    }
}
