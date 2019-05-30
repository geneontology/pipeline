pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    triggers {
	// Master never runs--Feb 31st.
	cron('0 0 31 2 *')
	// Nightly @12am, for "snapshot", skip "release" night.
	//cron('0 0 2-31 * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
    }
    environment {
	// Pin dates and day to beginning of run.
	START_DATE = sh (
	    script: 'date +%Y-%m-%d',
	    returnStdout: true
	).trim()

	START_DAY = sh (
	    script: 'date +%A',
	    returnStdout: true
	).trim()
	// The branch of geneontology/go-site to use.
	TARGET_GO_SITE_BRANCH = 'master'
	// The people to call when things go bad. It is a comma-space
	// "separated" string.
	TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov'
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'no'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'no'
	// This variable should typically be 'TRUE', which will cause
	// some additional basic checks to be made. There are some
	// very exotic cases where these check may need to be skipped
	// for a run, in that case this variable is set to 'FALSE'.
	WE_ARE_BEING_SAFE_P = 'TRUE'
	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
	ZENODO_REFERENCE_CONCEPT = '0'
	ZENODO_ARCHIVE_CONCEPT = '0'
	// Control make to get through our loads faster if
	// possible. Assuming we're cpu bound for some of these...
	// wok has 48 "processors" over 12 "cores", so I have no idea;
	// let's go with conservative and see if we get an
	// improvement.
	//MAKECMD = 'make --jobs 3 --max-load 10.0'
	MAKECMD = 'make'
	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://purl.obolibrary.org/obo/go/snapshot/extensions/go-lego.owl",
	    "http://purl.obolibrary.org/obo/eco.owl",
	    "http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl",
	    "http://purl.obolibrary.org/obo/cl/cl-basic.owl",
	    "http://purl.obolibrary.org/obo/go/extensions/gorel.owl",
	    "http://purl.obolibrary.org/obo/pato.owl",
	    "http://purl.obolibrary.org/obo/po.owl",
	    "http://purl.obolibrary.org/obo/chebi.owl",
	    "http://purl.obolibrary.org/obo/uberon/basic.owl",
	    "http://purl.obolibrary.org/obo/wbbt.owl",
	    "http://purl.obolibrary.org/obo/go/extensions/go-modules-annotations.owl",
	    "http://purl.obolibrary.org/obo/go/extensions/go-taxon-subsets.owl"
	].join(" ")
    }
    options{
	timestamps()
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
		cleanWs()
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
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/metadata || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/annotations || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/ontology || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/reports || true'
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
	    }
	}
	// See https://github.com/geneontology/go-ontology for details
	// on the ontology release pipeline. This ticket runs
	// daily(TODO?) and creates all the files normally included in
	// a release, and deploys to S3.
	stage('Produce ontology') {
	    steps {
		// Create a relative working directory and setup our
		// data environment.
		dir('./neo') {
		    git 'https://github.com/geneontology/neo.git'

		    // Default namespace.
		    sh 'OBO=http://purl.obolibrary.org/obo'

		    // Make all software products available in bin/.
		    sh 'mkdir -p bin/'
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
		    }
		    sh 'chmod +x bin/*'

		    //
		    withEnv(['PATH+EXTRA=:bin:./bin', 'JAVA_OPTS=-Xmx128G', 'OWLTOOLS_MEMORY=128G', 'BGMEM=128G']){
			retry(3){
			    sh 'make clean all'
			}
		    }

		    // Make sure that we copy any files there,
		    // including the core dump of produced.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY neo.obo neo.owl skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/'
		    }

		    // TODO: Future deplyment like?
		    // s3cmd -c ~/.s3cfg.go-push --acl-public --reduced-redundancy --mime-type=application/rdf+xml put neo.obo neo.owl s3://go-build/$JOB_BASE_NAME/latest/
		}
	    }
	}
	//..
	stage('Produce derivatives') {
            agent {
                docker {
		    image 'geneontology/golr-autoindex-ontology:0aeeb57b6e20a4b41d677a8ae934fdf9ecd4b0cd_2019-01-24T124316'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root --mount type=tmpfs,destination=/srv/solr/data'
		}
            }
            steps {
                // sh 'ls /srv'
                // sh 'ls /tmp'

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
            }
	}
	// //...
	// stage('Sanity II') {
	//     steps {
	// 	echo 'TODO: Sanity II'
	//     }
	// }
	// stage('TODO: Final status') {
	//     steps {
	// 	echo 'TODO: final'
	//     }
	// }
	// stage('Flush') {
	//     steps {
	// 	echo 'TODO: Flush/invalidate CDN'
	//     }
	// }
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
