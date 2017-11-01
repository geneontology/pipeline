pipeline {
    agent any
    // In additional to manual runs, trigger somewhere at midnight to
    // give us the max time in a day to get things right.
    //triggers {
	// Nightly @12am, for "snapshot".
	//cron('0 0 * * *')
	// First of the month @12am, for "release" (also "current").
	//cron('0 0 1 * *')
    //}
    stages {
	stage('Initialize') {
	    steps {
		parallel(
		    "Report": {
			sh 'env > env.txt'
			sh 'echo $BRANCH_NAME > branch.txt'
			sh 'echo "$BRANCH_NAME"'
			sh 'cat env.txt'
			sh 'cat branch.txt'
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
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/product || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/metadata || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/annotations || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/ontology || true'
			// Tag the top to let the world know I was at least
			// here.
			sh 'echo "TODO: Note software versions." > $WORKSPACE/mnt/$BRANCH_NAME/manifest.txt'
			sh 'date >> $WORKSPACE/mnt/$BRANCH_NAME/manifest.txt'
			// TODO: This should be wrapped in exception
			// handling. In fact, this whole thing should be.
			sh 'fusermount -u $WORKSPACE/mnt/'
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
		    	    sh 'mvn -U clean install'
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
		    // // Do we need this anymore?
		    // "Ready RDFox": {
		    // // Legacy: build 'rdfox-cli-build'
		    // 	dir('./rdfox-cli') {
		    // 	    // Remember that git lays out into CWD.
		    // 	    git 'https://github.com/balhoff/rdfox-cli.git'
		    // 	    // "Build".
		    // 	    sh 'wget http://www.cs.ox.ac.uk/isg/tools/RDFox/release/RDFox-linux.zip -O RDFox.zip'
		    // 	    sh 'unzip -u RDFox.zip'
		    // 	    sh 'cp RDFox/lib/JRDFox.jar lib/'
		    // 	    sh 'sbt universal:packageZipTarball'
		    // 	    // Attempt to rsync produced into bin/.
		    // 	    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    // 		sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" ./target/universal/rdfox-cli.tgz skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
		    // 	    }
		    // 	}
		    // },
		    "Ready minerva": {
			dir('./minerva') {
			    // Remember that git lays out into CWD.
			    git 'https://github.com/geneontology/minerva.git'
			    // Needs to have owltools available.
			    withEnv(['PATH+EXTRA=../../bin', 'CLASSPATH+EXTRA=../../bin']){
				// TODO: Skip tests until figure out
				// pathing issues.
				//sh 'mvn -U clean install'
				sh 'mvn -U clean install -DskipTests -Dmaven.javadoc.skip=true -Dsource.skip=true'
			    }
			    // Attempt to rsync produced into bin/.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" minerva-server/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" minerva-cli/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
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
			// Add owltools to path, required for scripts.
			// Note weird pipeline syntax to change the
			// PATH var--O was unable to the "correct"
			// `pwd` thing, so here we are.
			withEnv(['PATH+EXTRA=../../bin']){
			    sh 'make all'
			    sh 'make prepare_release'
			}
		    }
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/ontology'
		    }
		}
	    }
	}
	stage('Produce GAFs') {
	    steps {
		// Legacy: build 'gaf-production'
		dir('./go-site') {
		    git 'https://github.com/geneontology/go-site.git'
		    
		    // Make all software products available in bin/.
		    sh 'mkdir -p bin/'
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
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
			withEnv(['MINERVA_CLI_MEMORY=32G', 'JAVA_OPTS=-Xmx32G', 'OWLTOOLS_MEMORY=128G', "PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/pipeline/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/pipeline/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){
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
			    sh 'make clean'

			    // Do this thing.
			    script {
				// WARNING: In non-dev cases, try and
				// do the whole shebang.
				if( env.BRANCH_NAME != 'master' ){
				    sh 'make all'
				}
				if( env.BRANCH_NAME == 'master' ){
				    sh 'make all'
				    // // Do this thing for testing.
				    // // Needed temporarily to create
				    // // "all_pombase" target.
				    // sh 'make extra_files'
				    // // TODO: For the time being, let's just
				    // // try to get through this with pombase.
				    // sh 'make all_pombase'
				}
			    }
			}
			// Flatten onto skyhook.
			withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			    sh 'find ./target/groups -type f -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/annotations \\;'
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
		// Copy over the files that we want to work on.
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/* $WORKSPACE/copyover/'

		// Prepare a working directory based around go-site.
		dir('./go-site') {
		    git 'https://github.com/geneontology/go-site.git'

		    // Generate combined annotation report for driving
		    // annotation download pages and drop it into
		    // metadata/ for copyover.
		    sh 'python3 ./scripts/aggregate-json-reports.py -v --directory $WORKSPACE/copyover --metadata ./metadata/datasets --output ./metadata/datasets/combined.report.json'

		    // Copy all upstream metadata into metadata folder.
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" metadata/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/metadata'
		    }
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
                always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/'
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
		// Copy over the files that we want to work on.
		sh 'cp $WORKSPACE/mnt/$BRANCH_NAME/annotations/* $WORKSPACE/copyover/'
		// Ready...
		dir('./go-site') {
		    git 'https://github.com/geneontology/go-site.git'

		    // Run sanity checks.
		    sh 'python3 ./scripts/sanity-check-ann-report.py -v -d $WORKSPACE/copyover/'
		}
	    }
	    // WARNING: Extra safety as I expect this to sometimes fail.
	    post {
                always {
		    // Bail on the remote filesystem.
		    sh 'fusermount -u $WORKSPACE/mnt/'
		    // Purge the copyover point.
		    sh 'rm -r -f $WORKSPACE/copyover || true'
                }
            }
	}
	// Note: this is only for experimentation on master at this
	// point.
	stage('Produce derivatives') {
	    when { anyOf { branch 'master' } }
	    steps {
		parallel(
		    "GOlr index (TODO)": {
			echo 'TODO: index'
		    },
		    "Blazegraph journal": {
			dir('./go-site') {
			    git 'https://github.com/geneontology/go-site.git'

			    // Make all software products available in bin/.
			    sh 'mkdir -p bin/'
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/* ./bin/'
				// WARNING/BUG: needed for arachne to
				// run at this point.
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/lib/* ./lib/'
			    }
			    sh 'chmod +x bin/*'

			    // Make Blazegraph journal.
			    dir('./pipeline') {
				sh 'python3 -m venv mypyenv'
				withEnv(['MINERVA_CLI_MEMORY=32G', 'JAVA_OPTS=-Xmx32G', 'OWLTOOLS_MEMORY=128G', "PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/pipeline/mypyenv/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/pipeline/mypyenv", 'PY_ENV=mypyenv', 'PY_BIN=mypyenv/bin']){
				    // Note environment for future debugging.
				    sh 'env > env.txt'
				    sh 'cat env.txt'
				    sh 'python3 ./mypyenv/bin/pip3 install -r requirements.txt'
				    sh 'python3 ./mypyenv/bin/pip3 install ../graphstore/rule-runner'
				    // Ready, set...
				    sh 'make clean'
				    // // Make basic and inferred TTL targets .
				    // script {
				    // 	// WARNING: In non-dev cases, try and
				    // 	// do the whole shebang.
				    // 	if( env.BRANCH_NAME != 'master' ){
				    // 	    sh 'make all'
				    // 	    // Also, the _inferred.ttl files.
				    // 	    sh 'make all_targets_ttl'
				    // 	}
				    // 	if( env.BRANCH_NAME == 'master' ){
				    // 	    sh 'make all'
				    // 	    // Also, the _inferred.ttl files.
				    // 	    sh 'make all_targets_ttl'
				    // 	    // // ...do this thing for generating
				    // 	    // // the target/Makefile...
				    // 	    // sh 'make extra_files'
				    // 	    // // ...wait for it--get the
				    // 	    // // inferred ttl files produced.
				    // 	    // // WARNING/BUG: Unfortunately,
				    // 	    // // as we need the GAFs done
				    // 	    // // and done, we have to do
				    // 	    // // this again--cannot let this
				    // 	    // // get ouf of master.
				    // 	    // sh 'make all_pombase'
				    // 	    // //sh 'make all_targets_ttl'
				    // 	    // sh 'make ttl_all_pombase'
				    // 	}
				    // }
				    // Build blazegraph.
				    sh 'make target/blazegraph.jnl'
				}
				// Get the journal onto skyhook.
				withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				    sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" target/blazegraph.jnl skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/product/'
				}
			    }
			}
		    }
		)
	    }
	}
	// stage('Sanity II (TODO)') {
	//     steps {
	// 	echo 'TODO: Sanity II'
	//     }
	// }
	// TODO: Do we really want this?
	// stage('Silent end') {
	//     // when { expression { ! (BRANCH_NAME ==~ /(snapshot|release)/) } }
	//     when { not { anyOf { branch 'release'; branch 'snapshot' } } }
	//     steps {
	// 	echo "No public exposure of $BRANCH_NAME."
	//     }
	// }
	stage('Publish ontology') {
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Legacy: build 'ontology-publish'
		// Experimental stanza to support mounting
		// the sshfs using the "hidden" skyhook
		// identity.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy the product to the right location.
		withCredentials([file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3_PUSH_CONFIG')]) {
		    // Well, we need to do a couple of things
		    // here in a structured way, so we'll go
		    // ahead and drop into the scripting mode.
		    script {			
			if( env.BRANCH_NAME == 'master' ){
			    // Simple case: master -> experimental.
			    // Note no CloudFront invalidate.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml sync mnt/master/ontology/ s3://go-data-product-experimental/ontology/'
			}
			if( env.BRANCH_NAME == 'snapshot' ){
			    // Simple case: snapshot -> snapshot.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/snapshot/ontology/ s3://go-data-product-snapshot/ontology/'
			}
			if( env.BRANCH_NAME == 'release' ){
			    // Simple case: release -> current.
			    // Same as above.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/ontology/ s3://go-data-product-current/ontology/'
			    // Hard case case: release -> dated path.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/ontology/ s3://go-data-product-release/ontology/`date +%Y-%m-%d`/'
			}
		    }
		}
		// Bail on the filesystem.
		sh 'fusermount -u $WORKSPACE/mnt/'
	    }
	}
	// Publish metadata next--less likely to fail than
	// GAF, less important than ontologies.
	stage('Publish metadata') {
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Setup fuse for transfer.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy the product to the right location.
		withCredentials([file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3_PUSH_CONFIG')]) {
		    // Well, we need to do a couple of things
		    // here in a structured way, so we'll go
		    // ahead and drop into the scripting mode.
		    script {
			if( env.BRANCH_NAME == 'master' ){
			    // Simple case: master -> experimental.
			    // Note no CloudFront invalidate.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml sync mnt/master/metadata/ s3://go-data-product-experimental/metadata/'
			}
			if( env.BRANCH_NAME == 'snapshot' ){
			    // Simple case: snapshot -> snapshot.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/snapshot/metadata/ s3://go-data-product-snapshot/metadata/'
			}
			if( env.BRANCH_NAME == 'release' ){
			    // Simple case: release -> current.
			    // Same as above.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/metadata/ s3://go-data-product-current/metadata/'
			    // Hard case case: release -> dated path.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/metadata/ s3://go-data-product-release/metadata/`date +%Y-%m-%d`/'
			}
		    }
		}
		// Bail on the filesystem.
		sh 'fusermount -u $WORKSPACE/mnt/'
	    }	    
	}
	// Get the GAF/annotation data out separately--at
	// least we got the ontologies out.
	// TODO: Make a function to capture the repetition
	// between this and the ontology publishing.
	stage('Publish GAFs') {
	    when { anyOf { branch 'release'; branch 'snapshot'; branch 'master' } }
	    steps {
		// Legacy: build 'gaf-publish'
		// Setup fuse for transfer.
		sh 'mkdir -p $WORKSPACE/mnt/ || true'
		withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Copy the product to the right location.
		withCredentials([file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3_PUSH_CONFIG')]) {
		    // Well, we need to do a couple of things
		    // here in a structured way, so we'll go
		    // ahead and drop into the scripting mode.
		    script {
			if( env.BRANCH_NAME == 'master' ){
			    // Simple case: master -> experimental.
			    // Note no CloudFront invalidate.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml sync mnt/master/annotations/ s3://go-data-product-experimental/annotations/'
			}
			if( env.BRANCH_NAME == 'snapshot' ){
			    // Simple case: snapshot -> snapshot.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/snapshot/annotations/ s3://go-data-product-snapshot/annotations/'
			}
			if( env.BRANCH_NAME == 'release' ){
			    // Simple case: release -> current.
			    // Same as above.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/annotations/ s3://go-data-product-current/annotations/'
			    // Hard case case: release -> dated path.
			    sh 's3cmd -c $S3_PUSH_CONFIG --acl-public --mime-type=application/rdf+xml --cf-invalidate sync mnt/release/annotations/ s3://go-data-product-release/annotations/`date +%Y-%m-%d`/'
			}
		    }
		}
		// Bail on the filesystem.
		sh 'fusermount -u $WORKSPACE/mnt/'
	    }
	}
	stage('Deploy (TODO)') {
	    steps {
		parallel(
		    "AmiGO": {
			echo 'TODO: (re)deploy AmiGO'
		    },
		    "Blazegraph": {
			echo 'TODO: (re)deploy Blazegraph'
		    }
		)
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
    // TODO: Let's make an announcement if things go badly.
    post { 
        changed { 
            echo 'There has been a change in the pipeline.'
        }
    }
}
