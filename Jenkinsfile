pipeline {
    agent any
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
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/share || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/owltools || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/owltools/reporting || true'
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/owltools/contrib || true'
			//sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/robot || true'
			// Tag the top to let the world know I was at least
			// here.
			sh 'date > $WORKSPACE/mnt/$BRANCH_NAME/timestamp.txt'
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
			    // Attempt to rsync produced bin.
			    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-Runner/target/owltools skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools/'
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-Oort/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools/'
				sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" OWLTools-NCBI/bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools/'
				sh 'rsync -vhac -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" --exclude ".git" OWLTools-Oort/reporting/ skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools/reporting'
				sh 'rsync -vhac -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" --exclude ".git" OWLTools-Runner/contrib/ skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools/contrib'
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
		    	    // Attempt to rsync produced bin.
		    	    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
		    		sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" bin/* skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/bin/'
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
		    // TODO: explanation
		    withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
			sh 'rsync -avz -e "ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY" skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/owltools ./'
		    }
		    sh 'chmod 755 owltools/ontology-release-runner'
		    sh 'chmod 755 owltools/reporting/compare-obo-files.pl'
		    sh 'chmod 755 owltools/reporting/compare-defs.pl'
		    sh 'chmod 755 owltools/owltools'
		    // TODO: explanation
		    sh 'mkdir -p bin'
		    sh 'wget http://skyhook.berkeleybop.org/$BRANCH_NAME/bin/robot -O bin/robot'
		    sh 'wget http://skyhook.berkeleybop.org/$BRANCH_NAME/bin/robot.jar -O bin/robot.jar'
		    sh 'chmod +x bin/*'
		    // add owltools to path, required for scripts
		    // sh 'export PATH=$PATH:`pwd`/owltools'
		    // sh 'export PATH=$PATH:`pwd`/owltools/reporting'
		    // sh 'export PATH=$PATH:`pwd`/oboedit'
		    // sh 'export PATH=$PATH:`pwd`/bin'
		    // builds
		    dir('./src/ontology') {
			withEnv(['PATH=$PATH:../../owltools:../../owltools/reporting:../../oboedit:../../bin']){
			    sh 'make all'
			    sh 'make prepare_release'
			}
		    }
		}
	    }
	}
	// stage('Produce GAFs') {
	//     steps {
	// 	build 'gaf-production'
	//     }
	// }
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
	// stage('Publish') {
	//     steps {
	// 	parallel(
	// 	    "Ontology publish": {
	// 		build 'ontology-publish'
			
	// 	    },
	// 	    "GAF publish": {
	// 		build 'gaf-publish'
			
	// 	    }
	// 	)
	//     }
	// }
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
    }
}
