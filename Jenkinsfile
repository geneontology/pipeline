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
	TARGET_SUCCESS_EMAILS = 'sjcarbon@lbl.gov,suzia@stanford.edu'
	// The file bucket(/folder) combination to use.
	TARGET_BUCKET = 'go-data-product-experimental'
	// The URL prefix to use when creating site indices.
	TARGET_INDEXER_PREFIX = 'http://experimental.geneontology.io'
	// This variable should typically be 'TRUE', which will cause
	// some additional basic checks to be made. There are some
	// very exotic cases where these check may need to be skipped
	// for a run, in that case this variable is set to 'FALSE'.
	WE_ARE_BEING_SAFE_P = 'TRUE'
	// The Zenodo concept ID to use for releases (and occasionally
	// master testing).
	ZENODO_REFERENCE_CONCEPT = '199441'
	ZENODO_ARCHIVE_CONCEPT = '212052'
	// Control make to get through our loads faster if
	// possible. Assuming we're cpu bound for some of these...
	// wok has 48 "processors" over 12 "cores", so I have no idea;
	// let's go with conservative and see if we get an
	// improvement.
	//MAKECMD = 'make --jobs --max-load 12.0'
	MAKECMD = 'make'
	// GOlr load profile.
	GOLR_SOLR_MEMORY = "128G"
	GOLR_LOADER_MEMORY = "192G"
	GOLR_INPUT_ONTOLOGIES = [
	    "http://skyhook.berkeleybop.org/master/ontology/extensions/go-gaf.owl"
	].join(" ")
	GOLR_INPUT_GAFS = [
	    //"http://skyhook.berkeleybop.org/master/products/annotations/paint_other.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/aspgd.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_chicken.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_chicken_complex.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/goa_uniprot_all_noiea.gaf.gz",
	    "http://skyhook.berkeleybop.org/master/annotations/wb.gaf.gz"
	].join(" ")
	GOLR_INPUT_PANTHER_TREES = [
	    "http://skyhook.berkeleybop.org/master/products/panther/arbre.tgz"
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
		    "Ready robot": {
		    	// Legacy: build 'robot-build'
		    	dir('./robot') {
		    	    git 'https://github.com/ontodev/robot.git'
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
    	                    sh 'wget -N https://github.com/balhoff/blazegraph-runner/releases/download/v1.3/blazegraph-runner-1.3.tgz'
    	                    sh 'tar -xvf blazegraph-runner-1.3.tgz'
    	                    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    		// Attempt to rsync bin into bin/.
    	                        sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" blazegraph-runner-1.3/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				// Attempt to rsync libs into lib/.
    	    		    	sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" blazegraph-runner-1.3/lib/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/'
    	                    }
    	                }
		    }
		)
	    }
	}
	// See https://github.com/geneontology/go-ontology for details
	// on the ontology release pipeline. This ticket runs
	// daily(TODO?) and creates all the files normally included in
	// a a release, and deploys to S3
	stage('Produce ontology') {
	    steps {
		// Legacy: build 'ontology-production'
		dir('./go-ontology') {
		    git 'https://github.com/geneontology/go-ontology.git'
		    // Default namespace
		    sh 'OBO=http://purl.obolibrary.org/obo'

		    // Make all software products available in bin/.
		    sh 'mkdir -p bin/'
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
		    }
		    sh 'chmod +x bin/*'

		    // Make ontology products and get them into
		    // skyhook.
		    dir('./src/ontology') {
			retry(3){
			    // Add owltools to path, required for scripts.
			    // Note weird pipeline syntax to change the
			    // PATH var--O was unable to the "correct"
			    // `pwd` thing, so here we are.
			    withEnv(['PATH+EXTRA=../../bin']){
				sh '$MAKECMD all'
				sh '$MAKECMD prepare_release'
			    }
			}
		    }
		    // Make sure that we copy any files there,
		    // including the core dump of produced.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology'
		    }
		    // Now that the files are safely away onto skyhook
		    // for debugging, test for the core dump.
		    script {
			if( WE_ARE_BEING_SAFE_P == 'TRUE' ){

			    def found_core_dump_p = fileExists './target/core_dump.owl'
			    if( found_core_dump_p ){
				error 'ROBOT core dump detected--bailing out.'
			    }
			}
		    }
		}
	    }
	}
	stage('Produce GAFs, TTLs, and journal (mega-step)') {
	    steps {
		// Legacy: build 'gaf-production'
		dir('./go-site') {
		    git branch: TARGET_GO_SITE_BRANCH, url: 'https://github.com/geneontology/go-site.git'

		    // Make all software products available in bin/
		    // (and lib/).
		    sh 'mkdir -p bin/'
		    sh 'mkdir -p lib/'
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
			// WARNING/BUG: needed for blazegraph-runner
			// to run at this point.
            		sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/* ./lib/'
		    }
		    sh 'chmod +x bin/*'

		    // Make minimal GAF products.
		    dir('./pipeline') {
			// Technically, a meaningless line as we will
			// simulate this with entirely withEnv
			// anyways.
			sh 'python3 -m venv mypyenv'
			// Gunna need some memory.
			// In addition to the memory, try and simulate
			// the environment changes for python venv activate.
			// Note the complex assignment of VIRTUAL_ENV and PATH.
			// https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-withenv-code-set-environment-variables
			withEnv(['JAVA_OPTS=-Xmx128G', 'OWLTOOLS_MEMORY=128G', 'BGMEM=128G', "PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/pipeline/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/pipeline/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin', 'GROUPS=aspgd goa wb', 'TEST_EXCLUDES=goa_uniprot_gcrp goa_pdb goa_chicken_isoform goa_chicken_rna goa_cow goa_cow_complex goa_cow_isoform goa_cow_rna goa_dog goa_dog_complex goa_dog_isoform goa_dog_rna goa_human goa_human goa_human_complex goa_human_rna']){
			    // Note environment for future debugging.
			    sh 'env > env.txt'
			    sh 'cat env.txt'
			    // WARNING: Okay, this is our current
			    // workaround for the shebang line limits
			    // and long workspace names in Jenkins
			    // declarative
			    // (https://github.com/pypa/pip/issues/1773).
			    // There are other tacks we might take
			    sh 'python3 ./mypyenv/bin/pip3 install -r requirements.txt'
			    sh 'python3 ./mypyenv/bin/pip3 install ../graphstore/rule-runner'
			    // Ready, set...
			    sh '$MAKECMD clean'

			    // Do this thing, but the watchdog sits
			    // waiting.
			    timeout(time: 20, unit: 'HOURS') {
				script {
				    /// All branches now try to produce all
				    /// targets in the go-site Makefile.

				    // // For GAF joy, plus "extras".
				    // sh 'make all'
				    // Shaking the magic beads for "extras".
                		    // sh '$MAKECMD -e extra_files'
				    // Make basic (non-enriched/reasoned) TTLs.
				    //sh '$MAKECMD -e all_targets_ttl'

				    // // Make journals with what we have
				    // // on the filesystem, for
				    // // convenience at this point.
				    // // -internal" is /everything/.
				    // sh 'make target/blazegraph-internal.jnl'
				    // // "-production" is just GAFs+"production"
				    // // models.
				    // sh 'make target/blazegraph-production.jnl'

				    // As long as we're here and have
				    // everything handy: this is
				    // SPARTA!
				    sh '$MAKECMD -e target/sparta-report.json'
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
			    sh 'find ./target/groups -type f -regex "^.*\\(\\-src.gaf\\|\\_noiea.gaf\\|\\_valid.gaf\\|paint\\_.*\\).gz$" -not -regex "^.*goa_uniprot_all.*$" -not -regex "^.*.ttl.gz$" -not -regex "^.*goa_uniprot_all_noiea.gaf.gz$" -not -regex "^.*.ttl.gz$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations \\;'
			    // Now copy over the (single) uniprot non-core.
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ./target/groups/goa/goa_uniprot_all-src.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations'
			    // Finally, the non-zipped prediction files.
			    sh 'find ./target/groups -type f -regex "^.*\\-prediction.gaf$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/annotations \\;'
			    // Flatten all GAFs and GAF-like products
			    // onto skyhook. Basically:
			    //  - all product-y files
			    //  - but not uniprot_all anything (elsewhere)
			    //  - and not anything "irregular"
			    sh 'find ./target/groups -type f -regex "^.*.\\(gaf\\|gpad\\|gpi\\).gz$" -not -regex "^.*\\(\\-src.gaf\\|\\_noiea.gaf\\|\\_valid.gaf\\|paint_.*\\).gz$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations \\;'
			    // Now copy over the four uniprot core.
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ./target/groups/goa/goa_uniprot_all.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ./target/groups/goa/goa_uniprot_all_noiea.gaf.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ./target/groups/goa/goa_uniprot_all_noiea.gpi.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY ./target/groups/goa/goa_uniprot_all_noiea.gpad.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations'
			    // Flatten the TTLs into products/ttl/.
			    sh 'find ./target/groups -type f -name "*.ttl.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/ttl \\;'
			    // Compress the journals.
                	    sh 'pigz target/blazegraph-internal.jnl'
                	    sh 'pigz target/blazegraph-production.jnl'
			    // Copy the journals directly to products.
                	    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/blazegraph-production.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
                	    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/blazegraph-internal.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/'
			    // Copy the reports into reports.
                            sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/sparta-report.json skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'
			    // Plus: flatten product reports in json,
			    // md reports, text files, etc.
			    sh 'find ./target/groups -type f -regex "^.*\\.\\(json\\|txt\\|md\\)$" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports \\;'
			}
		    }
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
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/products/annotations/paint_* $WORKSPACE/copyover/'

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
		    sh 'wget -N http://data.pantherdb.org/current/globals/tree_files.tar.gz'
		    sh 'wget -N http://data.pantherdb.org/current/globals/names.tab'
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

			// "External" packages required to run this
			// single, isolated, script.
			sh 'python3 ./mypyenv/bin/pip3 install click'
			sh 'python3 ./mypyenv/bin/pip3 install pystache'
			sh 'python3 ./mypyenv/bin/pip3 install yamldown'

			// Generate the static overall gorule report
			// page
			sh 'python3 ./scripts/reports-page-gen.py --report ./combined.report.json --template ./scripts/reports-page-template.html --date $START_DATE > gorule-report.html'
		    }

		    // Get the date into the metadata, in a similar format
		    // to what is produced by the Zenodo sections.
		    sh 'echo \'{\' > ./metadata/release-date.json'
		    sh 'echo -n \'    "date": "\' >> ./metadata/release-date.json'
		    sh 'echo -n "$START_DATE" >> ./metadata/release-date.json'
		    sh 'echo \'"\' >> ./metadata/release-date.json'
		    sh 'echo \'}\' >> ./metadata/release-date.json'

		    // Generate the TTL from users.yaml and
		    // groups.yaml.  This is meant to be an unwinding
		    // of the somewhat too hard-coded
		    // go-site/scripts/yaml2turtle.sh from Jim.
		    withEnv(['PATH+EXTRA=../bin:node_modules/.bin']){
			sh 'npm install'
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
		    sh 'python3 ./scripts/sanity-check-ann-report.py -v -d $WORKSPACE/copyover/'
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
		    image 'geneontology/golr-autoindex:da64c3224c4f7dbf495977f77fda23c0e84c3b90_2018-10-04T122653'
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
	//...
	stage('Sanity II') {
	    steps {
		echo 'TODO: Sanity II'
	    }
	}
	stage('Archive') {
	    when { anyOf { branch 'release'; branch 'master' } }
	    steps {
		// Experimental stanza to support mounting the sshfs
		// using the "hidden" skyhook identity.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy the product to the right location. As well,
		// archive.
		withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'zenodo_go_sandbox_token', variable: 'ZENODO_TOKEN')]) {
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
			    sh 'python3 ./mypyenv/bin/pip3 install pystache'

			    // Correct for (possibly) bad boto3,
			    // as mentioned above.
			    sh 'python3 ./mypyenv/bin/pip3 install boto3'

			    // Extra package for the uploader.
			    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

			    // Grab BDBag.
			    sh 'python3 ./mypyenv/bin/pip3 install bdbag'

			    // Need for large uploads in requests.
			    sh 'python3 ./mypyenv/bin/pip3 install requests-toolbelt'

			    // Need as replacement for awful requests lib.
			    sh 'python3 ./mypyenv/bin/pip3 install pycurl'

			    // Well, we need to do a couple of things here in
			    // a structured way, so we'll go ahead and drop
			    // into the scripting mode.
			    script {

				// Build either a release or testing
				// version of a generic BDBag/DOI
				// workflow, keeping special bucket
				// mappings in mind.
				if( env.BRANCH_NAME == 'release' || env.BRANCH_NAME == 'master' ){

				    if( env.BRANCH_NAME == 'release' ){
					sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/$BRANCH_NAME/ --remote http://release.geneontology.org/$START_DATE --output manifest.json'
				    }else if( env.BRANCH_NAME == 'master' ){
					sh 'python3 ./scripts/create-bdbag-remote-file-manifest.py -v --walk $WORKSPACE/mnt/$BRANCH_NAME/ --remote $TARGET_INDEXER_PREFIX --output manifest.json'
				    }

				    // Make holey BDBag in fixed directory.
				    sh 'mkdir go-release-reference'
				    sh 'python3 ./mypyenv/bin/bdbag ./go-release-reference --remote-file-manifest manifest.json --archive tgz'

				    // To make a full BDBag, we first
				    // need a copy of the data as
				    // BDBags change directory layout
				    // (e.g. data/).
				    sh 'mkdir -p $WORKSPACE/copyover/ || true'
				    sh 'cp -r $WORKSPACE/mnt/$BRANCH_NAME/* $WORKSPACE/copyover/'
				    // Make the BDBag in the copyover/
				    // (unarchived, as we want to
				    // leave it to pigz).
				    sh 'python3 ./mypyenv/bin/bdbag $WORKSPACE/copyover'
				    // Tarball the whole directory for
				    // "deep" archive (handmade BDBag).
				    sh 'tar --use-compress-program=pigz -cvf go-release-archive.tgz -C $WORKSPACE/copyover .'

				    // We have the archives, now let's
				    // try and get them into
				    // position--this is fail-y, so we
				    // are going to try and buffer
				    // failure here for the time being
				    // until we work it all out.
				    try {
					// Archive the holey bdbag for
					// this run.
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_TOKEN --concept $ZENODO_REFERENCE_CONCEPT --file go-release-reference.tgz --output ./release-reference-doi.json --revision $START_DATE'
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
					mail bcc: '', body: "There has been a failure in the reference upload to Zenodo, in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline Zenodo reference upload fail for ${env.BRANCH_NAME}", to: "${TARGET_ADMIN_EMAILS}"
				    }
				    try {
					// Archive full archive too.
					sh 'python3 ./scripts/zenodo-version-update.py --verbose --sandbox --key $ZENODO_TOKEN --concept $ZENODO_ARCHIVE_CONCEPT --file go-release-archive.tgz --output ./release-archive-doi.json --revision $START_DATE'
					// Get the DOI to skyhook for
					// publishing, but don't
					// bother with the full
					// thing--too much space and
					// already in Zenodo.
					sh 'cp release-archive-doi.json $WORKSPACE/mnt/$BRANCH_NAME/metadata/release-archive-doi.json'
				    } catch (exception) {
					// Something went bad with the
					// Zenodo archive upload.
					echo "There has been a failure in the archive upload to Zenodo."
					mail bcc: '', body: "There has been a failure in the archive upload to Zenodo, in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}", cc: '', from: '', replyTo: '', subject: "GO Pipeline Zenodo archive upload fail for ${env.BRANCH_NAME}", to: "${TARGET_ADMIN_EMAILS}"
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
		withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON')]) {
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
			    sh 'python3 ./mypyenv/bin/pip3 install pystache'

			    // Correct for (possibly) bad boto3,
			    // as mentioned above.
			    sh 'python3 ./mypyenv/bin/pip3 install boto3'

			    // Extra package for the uploader.
			    sh 'python3 ./mypyenv/bin/pip3 install filechunkio'

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
	// Big things to do on release.
	stage('Deploy') {
	    when { anyOf { branch 'release' } }
	    steps {
		///
		/// First, legacy SVN backport.
		///
		echo 'Backport to legacy SVN'

		// Get a mount point ready
		sh 'mkdir -p $WORKSPACE/mnt || true'
		// Ninja in our file credentials from Jenkins.
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY'), file(credentialsId: 'go-svn-private-key', variable: 'GO_SVN_IDENTITY')]) {
		    // Setup our svn+ssh to have the right credentials.
		    withEnv(["SVN_SSH=ssh -l jenkins -i ${GO_SVN_IDENTITY}"]){

			// // Try and debug connection issues on next run.
			// sh 'echo $GO_SVN_IDENTITY > deploy-ident.txt'
			// sh 'echo $SVN_SSH > deploy-svn-ssh.txt'
			// sh 'cat deploy-ident.txt'
			// sh 'cat deploy-svn-ssh.txt'

			// Attach sshfs.
			sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'

			// Checkout the SVN for just the top-level
			// gene-associations.
			sh 'svn --non-interactive --ignore-externals --depth files checkout svn+ssh://ext.geneontology.org/share/go/svn/trunk/gene-associations $WORKSPACE/goannsvn'

			// Copy the files over to the right spot.
			// 45 items.
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/aspgd.gaf.gz $WORKSPACE/goannsvn/gene_association.aspgd.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/cgd.gaf.gz $WORKSPACE/goannsvn/gene_association.cgd.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/dictybase.gaf.gz $WORKSPACE/goannsvn/gene_association.dictyBase.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/ecocyc.gaf.gz $WORKSPACE/goannsvn/gene_association.ecocyc.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/fb.gaf.gz $WORKSPACE/goannsvn/gene_association.fb.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/gramene_oryza.gaf.gz $WORKSPACE/goannsvn/gene_association.gramene_oryza.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/jcvi.gaf.gz $WORKSPACE/goannsvn/gene_association.jcvi.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/mgi.gaf.gz $WORKSPACE/goannsvn/gene_association.mgi.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pombase.gaf.gz $WORKSPACE/goannsvn/gene_association.pombase.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pseudocap.gaf.gz $WORKSPACE/goannsvn/gene_association.pseudocap.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/reactome.gaf.gz $WORKSPACE/goannsvn/gene_association.reactome.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/rgd.gaf.gz $WORKSPACE/goannsvn/gene_association.rgd.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/sgd.gaf.gz $WORKSPACE/goannsvn/gene_association.sgd.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/sgn.gaf.gz $WORKSPACE/goannsvn/gene_association.sgn.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/tair.gaf.gz $WORKSPACE/goannsvn/gene_association.tair.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/wb.gaf.gz $WORKSPACE/goannsvn/gene_association.wb.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/zfin.gaf.gz $WORKSPACE/goannsvn/gene_association.zfin.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/genedb_lmajor.gaf.gz $WORKSPACE/goannsvn/gene_association.GeneDB_Lmajor.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/genedb_pfalciparum.gaf.gz $WORKSPACE/goannsvn/gene_association.GeneDB_Pfalciparum.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/genedb_tbrucei.gaf.gz $WORKSPACE/goannsvn/gene_association.GeneDB_Tbrucei.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pamgo_atumefaciens.gaf.gz $WORKSPACE/goannsvn/gene_association.PAMGO_Atumefaciens.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pamgo_ddadantii.gaf.gz $WORKSPACE/goannsvn/gene_association.PAMGO_Ddadantii.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pamgo_mgrisea.gaf.gz $WORKSPACE/goannsvn/gene_association.PAMGO_Mgrisea.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/pamgo_oomycetes.gaf.gz $WORKSPACE/goannsvn/gene_association.PAMGO_Oomycetes.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_chicken_complex.gaf.gz $WORKSPACE/goannsvn/goa_chicken_complex.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_chicken.gaf.gz $WORKSPACE/goannsvn/goa_chicken.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_chicken_isoform.gaf.gz $WORKSPACE/goannsvn/goa_chicken_isoform.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_chicken_rna.gaf.gz $WORKSPACE/goannsvn/goa_chicken_rna.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_cow_complex.gaf.gz $WORKSPACE/goannsvn/goa_cow_complex.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_cow.gaf.gz $WORKSPACE/goannsvn/goa_cow.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_cow_isoform.gaf.gz $WORKSPACE/goannsvn/goa_cow_isoform.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_cow_rna.gaf.gz $WORKSPACE/goannsvn/goa_cow_rna.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_dog_complex.gaf.gz $WORKSPACE/goannsvn/goa_dog_complex.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_dog.gaf.gz $WORKSPACE/goannsvn/goa_dog.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_dog_isoform.gaf.gz $WORKSPACE/goannsvn/goa_dog_isoform.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_dog_rna.gaf.gz $WORKSPACE/goannsvn/goa_dog_rna.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_human_complex.gaf.gz $WORKSPACE/goannsvn/goa_human_complex.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_human.gaf.gz $WORKSPACE/goannsvn/goa_human.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_human_isoform.gaf.gz $WORKSPACE/goannsvn/goa_human_isoform.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_human_rna.gaf.gz $WORKSPACE/goannsvn/goa_human_rna.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_pig_complex.gaf.gz $WORKSPACE/goannsvn/goa_pig_complex.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_pig.gaf.gz $WORKSPACE/goannsvn/goa_pig.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_pig_isoform.gaf.gz $WORKSPACE/goannsvn/goa_pig_isoform.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_pig_rna.gaf.gz $WORKSPACE/goannsvn/goa_pig_rna.gaf.gz'
			sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/goa_uniprot_all_noiea.gaf.gz $WORKSPACE/goannsvn/goa_uniprot_all_noiea.gaf.gz'

			// Descend and commit (all files).
			dir('./goannsvn') {
			    sh 'svn commit -m "Jenkins pipeline backport from $BRANCH_NAME"'
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
