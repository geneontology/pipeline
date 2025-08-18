pipeline {
    agent any
    // triggers {
    //     // No triggers - pipeline will only run manually
    // }
    environment {
        // Basic environment variables for GO-CAM translation
        TARGET_GO_SITE_BRANCH = 'master'
        TARGET_GOCAM_PY_BRANCH = 'v0.5.3-rc2'
        TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,smoxon@lbl.gov'

        // GO-CAM translation parameters
        GOCAM_MAX_WORKERS = '20'
        GOCAM_OUTPUT_DIR = '/opt/gocam-py'
        GOCAM_BATCH_SIZE = '100'
    }
    options{
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '14'))
    }
    stages {
        stage('Initialize') {
            steps {
                // Pin dates to beginning of run
                script {
                    env.START_DATE = sh (
                        script: 'date +%Y-%m-%d',
                        returnStdout: true
                    ).trim()

                    env.START_DAY = sh (
                        script: 'date +%A',
                        returnStdout: true
                    ).trim()
                }

                sh 'echo "Pipeline started on: $START_DATE ($START_DAY)"'
                sh 'echo "Branch: $BRANCH_NAME"'
            }
        }

        stage('GO-CAM Translation') {
            agent {
                docker {
                    image 'geneontology/dev-base:ea32b54c822f7a3d9bf20c78208aca452af7ee80_2023-08-28T125255'
                    args "-u root:root --tmpfs /opt:exec -w /opt"
                }
            }
            steps {
		// Prep.
                sh "apt-get update && apt-get install -y graphviz graphviz-dev"
		// Run.
                sh "mkdir -p /opt/go-site"
                sh "cd /opt/ && git clone -b $TARGET_GOCAM_PY_BRANCH https://github.com/geneontology/gocam-py.git"
                sh "cd /opt/gocam-py && pwd"
                sh "cd /opt/gocam-py && ls -lrt"
                sh "cd /opt/gocam-py && pip3 install poetry"
                sh "cd /opt/gocam-py && poetry install --all-extras"
                sh "cd /opt/gocam-py && poetry run gocam translate-collection --max-workers $GOCAM_MAX_WORKERS --output $GOCAM_OUTPUT_DIR --batch-size $GOCAM_BATCH_SIZE"

                // Find and copy the generated tar.gz files to skyhook
                withCredentials([file(credentialsId: 'skyhook-private-key', variable: 'SKYHOOK_IDENTITY')]) {
                    sh 'find /opt/gocam-py/networkx -name "*.tar.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/json/ \\;'
                    sh 'find /opt/gocam-py/cx2 -name "*.tar.gz" -exec scp -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=$SKYHOOK_IDENTITY {} skyhook@skyhook.berkeleybop.org:/home/skyhook/$BRANCH_NAME/products/json/ \\;'
                }
            }
        }
    }
    post {
        // Let's let our internal people know if things change
        changed {
            echo "There has been a change in the ${env.BRANCH_NAME} pipeline."
            emailext to: "${TARGET_ADMIN_EMAILS}",
                subject: "GO Pipeline change for ${env.BRANCH_NAME}",
                body: "There has been a pipeline status change in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
        }
        // Let's let our internal people know if things go badly
        failure {
            echo "There has been a failure in the ${env.BRANCH_NAME} pipeline."
            emailext to: "${TARGET_ADMIN_EMAILS}",
                subject: "GO Pipeline FAIL for ${env.BRANCH_NAME}",
                body: "There has been a pipeline failure in ${env.BRANCH_NAME}. Please see: https://build.geneontology.org/job/geneontology/job/pipeline/job/${env.BRANCH_NAME}"
        }
    }
}
