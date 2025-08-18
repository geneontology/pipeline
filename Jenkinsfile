pipeline {
    agent any
    triggers {
        // No triggers - pipeline will only run manually
    }
    environment {
        // Basic environment variables
        TARGET_GO_SITE_BRANCH = 'master'
        TARGET_ADMIN_EMAILS = 'sjcarbon@lbl.gov,debert@usc.edu,smoxon@lbl.gov'
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
        
        stage('Run Script') {
            steps {
                // TODO: Add your script execution here
                // Example:
                // sh 'python3 your_script.py'
                // or
                // sh './your_script.sh'
                
                echo 'Script execution stage - replace this with your actual script'
                sh 'echo "This is where your script will run"'
                sh 'echo "Current directory: $(pwd)"'
                sh 'ls -la'
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