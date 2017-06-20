pipeline {
  agent any
  stages {
    stage('Reset') {
      steps {
        sh 'env > env.txt'
        sh 'echo $BRANCH_NAME > branch.txt'
        sh 'echo "$BRANCH_NAME"'
      }
    }
  }
}