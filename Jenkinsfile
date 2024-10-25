pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    triggers {
	// Master never runs--Feb 31st.
	//cron('0 0 31 2 *')
	// Nightly @12am, for "snapshot", skip "release" night.
	//cron('0 0 2-31 * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
	// Every week on Wednesday, 8am.
	cron('0 8 * * 3')
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
        // The branch of geneontology/go-stats to use.
        TARGET_GO_STATS_BRANCH = 'master'
        // The branch of go-ontology to use.
        TARGET_GO_NEO_BRANCH = 'master'
        // The branch of go-ontology to use.
        TARGET_GO_ONTOLOGY_BRANCH = 'master'
        // The branch of minerva to use.
        TARGET_MINERVA_BRANCH = 'master'
        // The branch of noctua-models to use.
        TARGET_NOCTUA_MODELS_BRANCH = 'master'
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
	// Sanity check for solr inde being built.
	SANITY_SOLR_DOC_COUNT_MIN = 3500000
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
	//GOLR_SOLR_MEMORY = "128G"
	GOLR_SOLR_MEMORY = "192G"
	//GOLR_LOADER_MEMORY = "192G"
	//GOLR_LOADER_MEMORY = "320G"
	GOLR_LOADER_MEMORY = "384G"
	GOLR_INPUT_ONTOLOGIES = [
	    //"http://purl.obolibrary.org/obo/go/snapshot/extensions/go-lego.owl",
	    //"http://purl.obolibrary.org/obo/eco.owl",
	    //"http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl",
	    //"http://purl.obolibrary.org/obo/cl/cl-basic.owl",
	    //"http://purl.obolibrary.org/obo/go/extensions/gorel.owl",
	    //"http://purl.obolibrary.org/obo/pato.owl",
	    //"http://purl.obolibrary.org/obo/po.owl",
	    //"http://purl.obolibrary.org/obo/chebi.owl",
	    //"http://purl.obolibrary.org/obo/uberon/basic.owl",
	    //"http://purl.obolibrary.org/obo/wbbt.owl",
	    //"http://purl.obolibrary.org/obo/go/extensions/go-modules-annotations.owl",
	    //"http://purl.obolibrary.org/obo/go/extensions/go-taxon-subsets.owl"
            //"http://skyhook.berkeleybop.org/issue-35-neo-test/ontology/neo.owl"
            "http://skyhook.berkeleybop.org/issue-35-neo-test/ontology/extensions/go-lego.owl",
            "http://skyhook.berkeleybop.org/issue-35-neo-test/ontology/neo.owl"
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
	// We need some metadata to make the current NEO build work.
	stage('Produce metadata') {
	    steps {
		// Create a relative working directory and setup our
		// data environment.
		dir('./go-site') {
		    git 'https://github.com/geneontology/go-site.git'

		    sh './scripts/combine-datasets-metadata.py metadata/datasets/*.yaml > metadata/datasets.json'

		    // Deploy to S3 location for pickup in next stage.
		    withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
			sh 's3cmd -c $S3CMD_JSON --acl-public --reduced-redundancy --mime-type=application/json put metadata/datasets.json s3://go-build/metadata/'
		    }
		}
	    }
	}
	// See https://github.com/geneontology/go-ontology for details
	// on the ontology release pipeline. This ticket runs
	// daily(TODO?) and creates all the files normally included in
	// a release, and deploys to S3.
	stage('Produce NEO') {
	    agent {
		docker {
    		    image 'obolibrary/odkfull:v1.5.2'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root'
		}
	    }
	    steps {
		// Create a relative working directory and setup our
		// data environment.
		dir('./neo') {
		    git branch: TARGET_GO_NEO_BRANCH, url: 'https://github.com/geneontology/neo'

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
			    sh 'make clean'
			    sh 'make ROBOT_ENV="ROBOT_JAVA_ARGS=-Xmx48G" all'
			    // TODO: need non-zero return on runoak/oaklib CLI
			    // https://github.com/geneontology/neo/issues/89
			    //sh 'make test'
			}
		    }

		    // Make sure that we copy any files there,
		    // including the core dump of produced.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY neo.obo neo.owl skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/'
		    }

		    // WARNING/BUG: This occurs "early" as we need NEO
		    // in the proper location before building GO (for
		    // testing, solr loading, etc.). Once we have
		    // ubiquitous ontology catalogs, publishing can
		    // occur properly at the end and after testing.
		    // See commented out section below.
		    //
		    // Deploy to S3 location for pickup by PURL via CF.
		    withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
			sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=application/rdf+xml --cf-invalidate put neo.owl s3://go-build/build-noctua-entity-ontology/latest/'
			sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=application/rdf+xml --cf-invalidate put neo.obo s3://go-build/build-noctua-entity-ontology/latest/'
		    }
		}
	    }
	}
	// Produce the standard GO package.
	stage('Produce GO') {
	    agent {
		docker {
		    // Upgrade test for: geneontology/go-ontology#25019, from v1.2.32
    		    image 'obolibrary/odkfull:v1.4'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root'
		}
	    }
	    steps {
		// Create a relative working directory and setup our
		// data environment.
		dir('./go-ontology') {
		    // Attempt fix for #248, by reducing go-ontology
		    // checkout size.
		    //git 'https://github.com/geneontology/go-ontology.git'
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
		///
		/// Produce Solr index.
		///

                // sh 'ls /srv'
                // sh 'ls /tmp'

		// Build index into tmpfs.
		sh 'bash /tmp/run-indexer.sh'

		// Copy tmpfs Solr contents onto skyhook. Moving this
		// earlier so we can use the index to identify
		// problems.
		// https://github.com/geneontology/neo/issues/118
		sh 'tar --use-compress-program=pigz -cvf /tmp/golr-index-contents.tgz -C /srv/solr/data/index .'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // Copy over index.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr-index-contents.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/solr/'
		    // Copy over log.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/golr_timestamp.log skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/solr/'
		}

		// Immediately check to see if it looks like we have
		// enough docs. SANITY_SOLR_DOC_COUNT_MIN must be
		// greater than what we seen in the index.
		echo "SANITY_SOLR_DOC_COUNT_MIN:${env.SANITY_SOLR_DOC_COUNT_MIN}"
		sh 'curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json"'
		sh 'if [ $SANITY_SOLR_DOC_COUNT_MIN -gt $(curl "http://localhost:8080/solr/select?q=*:*&rows=0&wt=json" | grep -oh \'"numFound":[[:digit:]]*\' | grep -oh [[:digit:]]*) ]; then exit 1; else echo "We seem to be clear wrt doc count"; fi'

		///
		/// Produce various blazegraphs.
		///

		// DEBUG: confirm for the moment.
		sh 'ls -AlF /tmp/*'

		// An awkward download and protective cleanup dance.
		sh 'rm blazegraph.jnl || true'
		sh 'curl -L -o /tmp/blazegraph.jar https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_2_1_6_RC/blazegraph.jar'
		//sh 'curl -L -o /tmp/blazegraph.jar https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_2_1_5/blazegraph.jar'
		sh 'curl -L -o /tmp/blazegraph.properties https://raw.githubusercontent.com/geneontology/minerva/master/minerva-core/src/main/resources/org/geneontology/minerva/blazegraph.properties'
		sh 'curl -L -o /tmp/go-lego.owl http://skyhook.berkeleybop.org/$BRANCH_NAME/ontology/extensions/go-lego.owl'
		sh 'curl -L -o /tmp/neo.owl http://skyhook.berkeleybop.org/$BRANCH_NAME/ontology/neo.owl'
		// BUG/TODO: This will need to point inward at some point.
		// Attempt to pull "locally" from skyhook--it should now be built as part of the go makefile release target.
		//sh 'curl -L -o /tmp/reacto.owl http://snapshot.geneontology.org/ontology/extensions/reacto.owl'
		sh 'curl -L -o /tmp/reacto.owl http://skyhook.berkeleybop.org/$BRANCH_NAME/ontology/extensions/reacto.owl'
		// DEBUG: confirm for the moment.
		sh 'ls -AlF /tmp/*'
		sh 'head -100 /tmp/go-lego.owl'
		sh 'head -100 /tmp/neo.owl'
		sh 'head -100 /tmp/reacto.owl'
		sh 'head -100 /tmp/blazegraph.properties'
		sh 'java -version'
		// WARNING: Having trouble getting the journal to the
		// right location. Theoretically, if the pipeline
		// choked at the wrong time, a hard-to-erase file
		// could be left on the system. See "rm" above.
		sh 'java -cp /tmp/blazegraph.jar com.bigdata.rdf.store.DataLoader -defaultGraph http://example.org /tmp/blazegraph.properties /tmp/go-lego.owl'
		sh 'java -cp /tmp/blazegraph.jar com.bigdata.rdf.store.DataLoader -defaultGraph http://example.org /tmp/blazegraph.properties /tmp/reacto.owl'
		sh 'java -cp /tmp/blazegraph.jar com.bigdata.rdf.store.DataLoader -defaultGraph http://example.org /tmp/blazegraph.properties /tmp/neo.owl'
		sh 'mv blazegraph.jnl /tmp/blazegraph-go-lego-reacto-neo.jnl'
		sh 'pigz /tmp/blazegraph-go-lego-reacto-neo.jnl'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // Copy over journal.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/blazegraph-go-lego-reacto-neo.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/blazegraph/blazegraph-go-lego-reacto-neo.jnl.gz'
		    // DANGEROUS! WARNING/TODO: Copy over to temporary
		    // holding location for ShEx and stable Noctua
		    // deployment. Pseudo-publish.
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/blazegraph-go-lego-reacto-neo.jnl.gz skyhook@skyhook.berkeleybop.org:/home/skyhook/blazegraph-go-lego-reacto-neo.jnl.gz'
		    sh 'curl -L -o /tmp/go-lego-reacto.owl http://skyhook.berkeleybop.org/$BRANCH_NAME/ontology/extensions/go-lego-reacto.owl'
		    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" /tmp/go-lego-reacto.owl skyhook@skyhook.berkeleybop.org:/home/skyhook/go-lego-reacto.owl'
		}
	    }
	}
	//...
	stage('Sanity 0') {
	    agent {
		docker {
		    image 'obolibrary/odkfull:v1.2.22'
		    // Reset Jenkins Docker agent default to original
		    // root.
		    args '-u root:root'
		}
	    }
	    steps {
		// Get files back to local.
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/neo.owl /tmp/neo.owl'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/neo.obo /tmp/neo.obo'
		    sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/extensions/go-lego.owl /tmp/go-lego.owl'
		}


		echo "WARNING: this is a sanity test placeholder (old tests never passed)."
		// TODO: reactivate once there is a chance of passing.
		// sh 'ROBOT_JAVA_ARGS=-Xmx48G robot report --input /tmp/go-lego.owl --tdb true --tdb-directory /tmp/tdb/ -k true -p go-ontology/src/sparql/neo/profile.txt -o neo-violations.report.txt --print 50 -v'
		// withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		//     sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY neo-violations.report.txt skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/reports/'		// }

		// // TODO: here. Files available /tmp/go-lego.owl /tmp/neo.owl /tmp/go-lego.obo.
		// sh 'make RELEASEDATE=$START_DATE OBO=http://purl.obolibrary.org/obo ROBOT_ENV="ROBOT_JAVA_ARGS=-Xmx48G" all'
	    }
	}
	// // WARNING/BUG: This can only occur in its proper location here, as opposed to above,
	// // once ontology catalogs are produced in the proper
	// // locations.
	// // Currently only the NEO files.
	// stage('Publish') {
	//     // Get files back to local.
	//     withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
	// 	sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/neo.owl neo.owl'
	// 	sh 'scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology/neo.obo neo.obo'
	//     }
	//     // Deploy to S3 location for pickup by PURL via CF.
	//     withCredentials([file(credentialsId: 'aws_go_push_json', variable: 'S3_PUSH_JSON'), file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3CMD_JSON'), string(credentialsId: 'aws_go_access_key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws_go_secret_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
	// 	sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=application/rdf+xml --cf-invalidate put neo.owl s3://go-build/build-noctua-entity-ontology/latest/'
	// 	sh 's3cmd -c $S3CMD_JSON --acl-public --mime-type=application/rdf+xml --cf-invalidate put neo.obo s3://go-build/build-noctua-entity-ontology/latest/'
	//     }
	// }
    }
    post {
	// Let's let our people know if things go well.
	success {
	    echo "There has been a successful run of the ${env.BRANCH_NAME} pipeline."
	    emailext to: "${TARGET_SUCCESS_EMAILS}",
		subject: "GO Pipeline success for ${env.BRANCH_NAME}",
		body: "There has been successful run of the ${env.BRANCH_NAME} pipeline. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
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
