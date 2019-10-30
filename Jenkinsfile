#!groovy

pipeline {
  agent none

  post {
    always {
      node("master") {
        step([$class: 'ClaimPublisher'])
      }
    }
    failure {
      emailext (
          subject: "docker-base-images build failed:  '${env.BUILD_NUMBER}'",
          body: "${currentBuild.rawBuild.getLog(100).join("\n")}",
          to: "team@control-plane.io",
          from: "jenkins@control-plane.io"
          )
    }
  }

  stages {
    stage('Test') {
      agent {
        docker {
          image 'docker.io/controlplane/gcloud-sdk:latest'
          args '-v /var/run/docker.sock:/var/run/docker.sock ' +
            '--user=root ' +
            '--cap-drop=ALL ' +
            '--cap-add=DAC_OVERRIDE'
        }
      }

      steps {
        ansiColor('xterm') {
          sh 'make pull build'
          sh 'make test'
        }
      }
    }
  }
}
