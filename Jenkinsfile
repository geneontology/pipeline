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
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,suzia@stanford.edu,smoxon@lbl.gov'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,pascale.gaudet@sib.swiss,pgaudet1@gmail.com,smoxon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'go-data-product-snapshot'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'http://snapshot.geneontology.org'
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

	PANTHER_VERSION = '17.0'

	///
	/// Application tokens.
	///

	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
	ZENODO_ARCHIVE_CONCEPT = '425666'
	// Distribution ID for the AWS CloudFront for this branch,
	// used soley for invalidations. Versioned release does not
	// need this as it is always a new location and the index
	// upload already has an invalidation on it. For current,
	// snapshot, and experimental.
	AWS_CLOUDFRONT_DISTRIBUTION_ID = 'E3UPPWY0HYLLL2'
	AWS_CLOUDFRONT_RELEASE_DISTRIBUTION_ID = 'E2HF1DWYYDLTQP'

	///
	/// Ontobio Validation
	///
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/snapshot/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/snapshot/ontology/extensions/go-lego.owl"
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
	GOLR_INPUT_GAFS = [
	    "http://skyhook.berkeleybop.org/snapshot/products/upstream_and_raw_data/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/cgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/dictybase.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/ecocyc.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/fb.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/genedb_lmajor.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/genedb_tbrucei.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/genedb_pfalciparum.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_chicken_rna.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_cow.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_cow_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_cow_rna.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_dog.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_dog_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_dog_rna.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_human.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_human_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_human_rna.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_pig.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_pig_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_pig_rna.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/japonicusdb.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/pseudocap.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/rgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/sgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/sgn.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/tair.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/wb.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/xenbase.gaf.gz",
	    "http://skyhook.berkeleybop.org/snapshot/annotations/zfin.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/snapshot/products/panther/arbre.tgz"
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
	// WARNING: This stage is a hack required to work around data damage described in https://github.com/geneontology/go-site/issues/1484 and
	// https://github.com/geneontology/pipeline/issues/220.
	// Redownload annotations and run ontobio-parse-assocs over them in various ways.
	stage('Temporary post filter') {
	    agent {
		docker {
		    image 'geneontology/dev-base:ea32b54c822f7a3d9bf20c78208aca452af7ee80_2023-08-28T125255'
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
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/annotations/* /opt/go-site/annotations/'
		    // Get rid of goa_uniprot_all_noiea-type products
		    // as they take too long to run.
		    sh 'rm -f /opt/go-site/annotations/*uniprot_all* || true'
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/gaferencer/all.gaferences.json.gz /opt/go-site/gaferencer-products/'

		    //sh "$MAKECMD -f /opt/go-site/scripts/Makefile-gaf-reprocess all"
		    sh "make -f /opt/go-site/scripts/Makefile-gaf-reprocess all"

		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/annotations_new/* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/annotations'
		    // sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/gaferencer-products/all.gaferences.json.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/gaferencer/gaferences.json.gz'

		    // From here, we are making corrections to the Noctua
		    // GPADs (https://github.com/geneontology/pipeline/issues/220) to fix errors that are
		    // apparent in the model upstream.
		    sh "mkdir -p /opt/go-site/noctua_sources /opt/go-site/noctua_target"

		    // Download source noctua files from skyhook
		    // Download noctua_*.gpad.gz from products/upstream_and_raw_data/ in skyhook
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/upstream_and_raw_data/noctua_*-src.gpad.gz /opt/go-site/noctua_sources/'
		    // Do we need GPI files for GO Rules? Maybe? Try and see if these are needed for GO Rules.

		    // Run the noctua gpad through ontobio
		    withEnv(["ONTOLOGY=${VALIDATION_ONTOLOGY_URL}"]){
			sh "make -f /opt/go-site/scripts/Makefile-gaf-reprocess noctua_gpad"
		    }

		    // Upload result files to skyhook
		    // Upload noctua valid to skyhook
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/noctua_target/noctua*.gpad.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/upstream_and_raw_data'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /opt/go-site/noctua_target/*.report.* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'
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
		sh 'cp $WORKSPACE/mnt/snapshot/annotations/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/snapshot/reports/* $WORKSPACE/copyover/'
		script {
		    try {
			sh 'cp $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/paint_* $WORKSPACE/copyover/'
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
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/bin/* $WORKSPACE/bin/'
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
		    sh 'mv arbre.tgz $WORKSPACE/mnt/snapshot/products/panther'

		    // Generate combined annotation and assigned-by combined report for driving
		    // annotation download pages and drop it into
		    // reports/ for copyover.
		    sh 'python3 ./scripts/aggregate-json-reports.py -v --directory $WORKSPACE/copyover --metadata ./metadata/datasets --output ./combined.report.json'
		    sh 'python3 ./scripts/combined_assigned_by.py -v --input ./combined.report.json --output ./assigned-by-combined-report.json'
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
				sh 'python3 ./scripts/reports-page-gen.py --report ./assigned-by-combined-report.json --template ./scripts/assigned-by-reports-page-template.html --date $START_DATE --suppress-rule-tag $GORULE_TAGS_TO_SUPPRESS > assigned-by-gorule-report.html'
			    }else{
				sh 'python3 ./scripts/reports-page-gen.py --report ./combined.report.json --template ./scripts/reports-page-template.html --date $START_DATE > gorule-report.html'
				sh 'python3 ./scripts/reports-page-gen.py --report ./assigned-by-combined-report.json --template ./scripts/assigned-by-reports-page-template.html --date $START_DATE > assigned-by-gorule-report.html'
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
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" metadata/* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/metadata'

			// Copy all of the reports to the reports
			// directory.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./combined.report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./aggregate-rule-violation-report.md skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./users-and-groups-report.txt skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'

			// Copy generated pages over to page output.
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./downloads.html skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/pages'
			// Copy gorule report page to the reports directory
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./gorule-report.html skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'
			// Copy overall assigned-by pages to the
			// reports directory
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./assigned-by-*.* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/reports'
		    }

		    // Produce the slightly improved combined reports
		    // inplace on remote.
		    sh 'python3 ./scripts/merge-all-reports.py --verbose --directory $WORKSPACE/mnt/snapshot/reports'
		}
		// Run and report shared annotation check.
		dir('./shared-annotation-check') {
		    git url: 'https://github.com/geneontology/shared-annotation-check.git'
		    // Setup.
		    withEnv(['PATH+EXTRA=../bin:node_modules/.bin']){
			sh 'npm install'
			// Run annotation checks.
			sh 'node ./check-runner.js -i ./rules.txt -o $WORKSPACE/mnt/snapshot/reports/shared-annotation-check.html'
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
		sh 'cp $WORKSPACE/mnt/snapshot/annotations/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/* $WORKSPACE/copyover/'
		sh 'cp $WORKSPACE/mnt/snapshot/reports/* $WORKSPACE/copyover/'
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
		START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/dow.txt', , returnStdout: true).trim()
		START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/date.txt', , returnStdout: true).trim()
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
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/solr/'
		    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/solr/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/solr/'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/products/solr/'
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
			sh 'python3 /tmp/go_reports.py -g http://localhost:8080/solr/ -s http://current.geneontology.org/release_stats/go-stats.json -n http://current.geneontology.org/release_stats/go-stats-no-pb.json -c http://skyhook.berkeleybop.org/snapshot/ontology/go.obo -p http://current.geneontology.org/ontology/go.obo -r http://current.geneontology.org/release_stats/go-references.tsv -o /tmp/stats/ -d $START_DATE'
		    }
		    retry(3) {
		    	sh 'wget -N http://current.geneontology.org/release_stats/aggregated-go-stats-summaries.json'
		    }

		    // Roll the stats forward.
		    sh 'python3 /tmp/aggregate-stats.py -a aggregated-go-stats-summaries.json -b /tmp/stats/go-stats-summary.json -o /tmp/stats/aggregated-go-stats-summaries.json'

		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    	retry(3) {
			    // Copy over stats files.
			    //sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/stats/* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/release_stats/'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY /tmp/stats/* skyhook@skyhook.berkeleybop.org:/home/skyhook/snapshot/release_stats/'
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

	stage('Archive (*)') {
	    // CHECKPOINT: Recover key environmental variables.
	    environment {
		START_DOW = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/dow.txt', , returnStdout: true).trim()
		START_DATE = sh(script: 'curl http://skyhook.berkeleybop.org/snapshot/metadata/date.txt', , returnStdout: true).trim()
	    }

	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Experimental stanza to support mounting the sshfs
		// using the "hidden" skyhook identity.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'

		    // Try to catch and prevent goa_uniprot_all-src
		    // from getting into zenodo archive, etc. Re:
		    // #207.
		    sh 'pwd'
		    sh 'ls -AlF $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/ || true'
		    sh 'rm -f $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/goa_uniprot_all-src.gaf.gz || true'
		    sh 'ls -AlF $WORKSPACE/mnt/snapshot/products/upstream_and_raw_data/ || true'

		    // Redo goa_uniprot_all names for publication. From:
		    // https://github.com/geneontology/go-site/issues/1984
		    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all.gaf.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all.gaf.gz || true'
		    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gaf.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gaf.gz || true'
		    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gpad.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gpad.gz || true'
		    sh 'mv $WORKSPACE/mnt/snapshot/annotations/goa_uniprot_all_noiea.gpi.gz $WORKSPACE/mnt/snapshot/annotations/filtered_goa_uniprot_all_noiea.gpi.gz || true'

		    // Get annotation download directory prepped. From:
		    // https://github.com/geneontology/go-site/issues/1971
		    sh 'rm -f README-annotation-downloads.txt || true'
		    sh 'wget -N https://raw.githubusercontent.com/geneontology/go-site/$TARGET_GO_SITE_BRANCH/static/pages/README-annotation-downloads.txt'
		    sh 'mv README-annotation-downloads.txt $WORKSPACE/mnt/snapshot/annotations/README.txt || true'

		    // Try and remove /lib and /bin from getting into
		    // the archives by removing them now that we're
		    // done using them for product builds. Re: #268.
		    sh 'ls -AlF $WORKSPACE/mnt/snapshot/'
		    sh 'rm -r -f $WORKSPACE/mnt/snapshot/bin || true'
		    sh 'rm -r -f $WORKSPACE/mnt/snapshot/lib || true'
		    sh 'ls -AlF $WORKSPACE/mnt/snapshot/'
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
				    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/snapshot/ --remote http://release.geneontology.org/$START_DATE --output manifest.json'
				}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'snapshot-post-fail' ){
				    sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/snapshot/ --remote $TARGET_INDEXER_PREFIX --output manifest.json'
				}

				// To make a full BDBag, we first need
				// a copy of the data as BDBags change
				// directory layout (e.g. data/).
				sh 'mkdir -p $WORKSPACE/copyover/ || true'
				sh 'cp -r $WORKSPACE/mnt/snapshot/* $WORKSPACE/copyover/'
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
				    }else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){
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
				    sh 'cp release-archive-doi.json $WORKSPACE/mnt/snapshot/metadata/release-archive-doi.json'

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
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'snapshot-post-fail'; branch 'master' } }
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
				sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/snapshot --prefix $TARGET_INDEXER_PREFIX -x'

				// Push into S3 buckets. Simple
				// overall case: copy tree directly
				// over. For "release", this will be
				// "current". For "snapshot", this
				// will be "snapshot".
				sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket $TARGET_BUCKET --number $BUILD_ID --pipeline snapshot'

				// Also, some runs have special maps
				// to buckets...
				if( env.BRANCH_NAME == 'release' ){

				    // "release" -> dated path for
				    // indexing (clobbering
				    // "current"'s index.
				    sh 'python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory $WORKSPACE/mnt/snapshot --prefix http://release.geneontology.org/$START_DATE -x -u'
				    // "release" -> dated path for S3.
				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket go-data-product-release/$START_DATE --number $BUILD_ID --pipeline snapshot'

				    // Build the capper index.html...
				    sh 'python3 ./scripts/bucket-indexer.py --credentials $S3_PUSH_JSON --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html'
				    // ...and push it up to S3.
				    sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html'

				}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){

				    // Currently, the "daily"
				    // debugging buckets are intended
				    // to be RO directly in S3 for
				    // debugging.
				    sh 'python3 ./scripts/s3-uploader.py -v --credentials $S3_PUSH_JSON --directory $WORKSPACE/mnt/snapshot/ --bucket go-data-product-daily/$START_DAY --number $BUILD_ID --pipeline snapshot'

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

					}else if( env.BRANCH_NAME == 'snapshot' || env.BRANCH_NAME == 'snapshot-post-fail' ){

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

// Check that we do not affect public targets on non-mainline runs.
void watchdog() {
    if( BRANCH_NAME != 'master' && TARGET_BUCKET == 'go-data-product-experimental'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'snapshot' && TARGET_BUCKET == 'go-data-product-snapshot'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'snapshot-post-fail' && TARGET_BUCKET == 'go-data-product-snapshot'){
	echo 'Only snashot* can touch that target.'
	sh '`exit -1`'
    }else if( BRANCH_NAME != 'release' && TARGET_BUCKET == 'go-data-product-release'){
	echo 'Only master can touch that target.'
	sh '`exit -1`'
    }
}
