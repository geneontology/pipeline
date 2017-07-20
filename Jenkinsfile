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
		    	    }
		    	}
		    },
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
			sh 'make clean'
			// Technically, a meaningless line as we will
			// simulate that with withEnv.
			sh 'python3 -m venv target/env'
			// Gunna need some memory.
			// In addition to the memory, try and simulate
			// the environment changes for pyenv activate.
			// Note the complex assignment of VIRTUAL_ENV and PATH.
			// https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-withenv-code-set-environment-variables
			withEnv(['MINERVA_CLI_MEMORY=32G', 'OWLTOOLS_MEMORY=128G', "PATH+EXTRA=${WORKSPACE}/go-site/bin:${WORKSPACE}/go-site/pipeline/target/env/bin", 'PYTHONHOME=', "VIRTUAL_ENV=${WORKSPACE}/go-site/pipeline/target/env"]){
			    sh 'env > env.txt'
			    sh 'cat env.txt'
			    sh 'which python'
			    sh 'which python3'
			    sh 'echo $VIRTUAL_ENV'
			    // TODO: For the time being, let's just
			    // try to get through this with pombase.
			    
			    //sh 'source environment.sh'
			    // 
			    // or
			    // 
			    // sh '. target/env/bin/activate'
			    sh 'pip3 install -r requirements.txt'
			    sh 'pip3 install ../graphstore/rule-runner'
			    // 
			    // or
			    // 
			    // VIRTUAL_ENV="/home/sjcarbon/local/src/git/go-site/pipeline/target/env"
			    // PATH="$VIRTUAL_ENV/bin:$PATH"
			    // if [ -n "$PYTHONHOME" ] ; then
			    //   unset PYTHONHOME
			    // fi

			    // TODO: 
			    // make all
			    sh 'make extra_files'
			    sh 'make all_pombase'
			}
		    }
		}
	    }
	}
	// stage('TODO: Sanity I') {
	//     steps {
	// 	echo 'TODO: sanity'
	//     }
	// }
	// stage('Produce derivatives') {
	//     steps {
	// 	parallel(
	// 	    "Produce index": {
	// 		echo 'TODO: index'
			
	// 	    },
	// 	    "Produce graphstore": {
	// 		echo 'TODO: graphstore'
			
	// 	    }
	// 	)
	//     }
	// }
	// stage('TODO: Sanity II') {
	//     steps {
	// 	echo 'TODO: sanity'
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
	stage('Publish') {
	    // when { expression { BRANCH_NAME ==~ /(snapshot|release)/ } }
	    when { anyOf { branch 'release'; branch 'snapshot' } }
	    steps {
		parallel(
		    "Ontology publish": {
			// Legacy: build 'ontology-publish'
			// Experimental stanza to support mounting
			// the sshfs using the "hidden" skyhook
			// identity.
			sh 'mkdir -p $WORKSPACE/mnt/ || true'
			withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			    sh 'sshfs -oStrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
			}
			// Copy the product to the right location.
			// cp ./pipeline/target/* $WORKSPACE/mnt/annotations/
			withCredentials([file(credentialsId: 's3cmd_go_push_configuration', variable: 'S3_PUSH_CONFIG')]) {
			    // TODO/BUG: This should be going to
			    // the $BRANCH_NAME instead of the
			    // hardcoded "snapshot".

			    // Well, we need to do a couple of things
			    // here in a structured way, so we'll go
			    // ahead and drop into the scripting mode.
			    script {
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
		    }//,
		    // 	    "GAF publish": {
		    // 		build 'gaf-publish'
			// 	    }
		)
	    }
	}
	// stage('Deploy') {
	//     steps {
	// 	echo 'TODO: deploy AmiGO'
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
    // TODO: Let's make an announcement if things go badly.
    post { 
        changed { 
            echo 'There has been a change in the pipeline.'
        }
    }
}
