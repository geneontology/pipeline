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
		    }
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
			sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/robot || true'
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
	// stage('Ready production software') {
	//     steps {
	// 	parallel(
	// 	    "Ready owltools": {
	// 		build 'owltools-build'
			
	// 	    },
	// 	    "Ready robot": {
	// 		build 'robot-build'
			
	// 	    }
	// 	)
	//     }
	// }
	// stage('Produce ontology') {
	//     steps {
	// 	build 'ontology-production'
	//     }
	// }
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
