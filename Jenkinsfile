pipeline {
    agent any
    stages {
	stage('Reset') {
	    steps {
		sh 'env > env.txt'
		sh 'echo $BRANCH_NAME > branch.txt'
		sh 'echo "$BRANCH_NAME"'
		sh 'cat env.txt'
		sh 'cat branch.txt'
		// Ninja in our file credentials from Jenkins.
		withCredentials([usernameColonPassword(credentialsId: 'id_rsa_nopass.skyhook', variable: 'SKYHOOK_IDENTITY')]) {
		    // Try and ssh fuse skyhook onto our local system.
		    sh 'sshfs -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY -o idmap=user skyhook@skyhook.berkeleybop.org:/home/skyhook $WORKSPACE/mnt/'
		}
		// Remove anything we might have left around from
		// times past.
		sh 'rm -r -f $WORKSPACE/mnt/$BRANCH_NAME || true'
		// Rebuild directory structure.
		sh 'mkdir -p $WORKSPACE/mnt/$BRANCH_NAME/bin || true'
		// Tag the top to let the world know I was at least
		// here.
		sh 'date > $WORKSPACE/mnt/$BRANCH_NAME/timestamp.txt'
		// TODO: This should be wrapped in exception handling.
		sh 'fusermount -u $WORKSPACE/mnt/'
	    }
	}
    }
}
