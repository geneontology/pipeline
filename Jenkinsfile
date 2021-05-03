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
	// Runs daily at 4pm PT
	cron('0 16 * * *')
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
	// The branch of go-ontology to use.
	TARGET_GO_ONTOLOGY_BRANCH = 'master'
	// The branch of minerva to use.
	TARGET_MINERVA_BRANCH = 'master'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu'
	TARGET_GO_SUMMARY_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu'
	TARGET_RELEASE_HOLD_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,pascale.gaudet@sib.swiss'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'null'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'http://localhost'
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
	VALIDATION_ONTOLOGY_URL="http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/go.json"

	///
	/// Minerva input.
	///

	// Minerva operating profile.
	MINERVA_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/extensions/go-lego.owl"
	].join(" ")

	///
	/// GOlr/AmiGO input.
	///

	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/extensions/go-gaf.owl",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/extensions/gorel.owl",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/extensions/go-modules-annotations.owl",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/ontology/extensions/go-taxon-subsets.owl",
	    "http://purl.obolibrary.org/obo/eco/eco-basic.owl",
	    "http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl",
	    "http://purl.obolibrary.org/obo/cl/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/pato.owl",
	    "http://purl.obolibrary.org/obo/po.owl",
	    "http://purl.obolibrary.org/obo/chebi.owl",
	    "http://purl.obolibrary.org/obo/uberon/basic.owl",
	    "http://purl.obolibrary.org/obo/wbbt.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/products/annotations/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/aspgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/mgi.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/pombase.gaf.gz",
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/issue-go-site-1530-summary-emails/products/panther/arbre.tgz"
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
	RESOURCE_GROUPS="aspgd goa mgi paint wb pseudocap wb"
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
		//sleep time: 1, unit: 'MINUTES'
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
	stage('Make summary emails') {
	    steps {
		script {

		    dir('./go-site') {
			git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

			// Create summaries.
			sh 'python3 scripts/github_issue_summary.py geneontology/go-ontology 1 > ontology-summary.html'
			sh 'python3 scripts/github_issue_summary.py geneontology/go-annotation 1 > annotation-summary.html'

			// Store on skyhook for examination.
			withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ontology-summary.html skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY annotation-summary.html skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
			}

			// Email to interested parties.
			echo "Emailing..."
			def ontsum = readFile "ontology-summary.html"
			def annsum = readFile "annotation-summary.html"
			mail bcc: '', body: "${ontsum}", cc: '', from: '', replyTo: '', subject: "GO Ontology Summary", to: "${TARGET_GO_SUMMARY_EMAILS}"
			echo "...completed."
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
	// Let's let our internal people know if things change.
	changed {
	    echo "There has been a change in the ${env.BRANCH_NAME} pipeline."
	    mail bcc: '', body: "There has been a pipeline status change in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline change for ${env.BRANCH_NAME}", to: "${TARGET_ADMIN_EMAILS}"
	}
	// Let's let our internal people know if things go badly.
	failure {
	    echo "There has been a failure in the ${env.BRANCH_NAME} pipeline."
	    mail bcc: '', body: "There has been a pipeline failure in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline FAIL for ${env.BRANCH_NAME}", to: "${TARGET_ADMIN_EMAILS}"
	}
    }
}
