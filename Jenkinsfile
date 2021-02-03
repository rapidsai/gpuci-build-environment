pipeline {
  agent {
    node {
      label 'runner'
    }
  }
  stages {
    stage('gpuCI/env-check') {
      steps {
        sh 'env'
      }
    }
    stage('gpuCI/parallel/miniconda-miniforge') {
      parallel {
        stage('gpuCI/build/miniconda-cuda') {
          steps {
            build(
              job: 'gpuci/gpuci-build-environment/miniconda-cuda-test-build',
              wait: true,
              propagate: true,
              parameters: [
                string(name: 'PR_ID', value: env.CHANGE_ID),
                string(name: 'REPORT_HASH', value: env.GIT_COMMIT),
                string(name: 'COMMIT_HASH', value: env.GIT_COMMIT),
                string(name: 'SOURCE_BRANCH', value: env.CHANGE_BRANCH),
                string(name: 'TARGET_BRANCH', value: env.CHANGE_TARGET)
              ]
            )
          }
        }
        stage('gpuCI/build/miniforge-cuda') {
          steps {
            build(
              job: 'gpuci/gpuci-build-environment/miniforge-cuda-test-build',
              wait: true,
              propagate: true,
              parameters: [
                string(name: 'PR_ID', value: env.CHANGE_ID),
                string(name: 'REPORT_HASH', value: env.GIT_COMMIT),
                string(name: 'COMMIT_HASH', value: env.GIT_COMMIT),
                string(name: 'SOURCE_BRANCH', value: env.CHANGE_BRANCH),
                string(name: 'TARGET_BRANCH', value: env.CHANGE_TARGET)
              ]
            )
          }
        }
      }
    }
    stage('gpuCI/build/miniconda-cuda-driver') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment/miniconda-cuda-driver-test-build',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: env.CHANGE_ID),
            string(name: 'REPORT_HASH', value: env.GIT_COMMIT),
            string(name: 'COMMIT_HASH', value: env.GIT_COMMIT),
            string(name: 'SOURCE_BRANCH', value: env.CHANGE_BRANCH),
            string(name: 'TARGET_BRANCH', value: env.CHANGE_TARGET)
          ]
        )
      }
    }
    stage('gpuCI/build/rapidsai') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment/rapidsai-test-build',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: env.CHANGE_ID),
            string(name: 'REPORT_HASH', value: env.GIT_COMMIT),
            string(name: 'COMMIT_HASH', value: env.GIT_COMMIT),
            string(name: 'SOURCE_BRANCH', value: env.CHANGE_BRANCH),
            string(name: 'TARGET_BRANCH', value: env.CHANGE_TARGET)
          ]
        )
      }
    }
    stage('gpuCI/build/rapidsai-driver') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment/rapidsai-driver-test-build',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: env.CHANGE_ID),
            string(name: 'REPORT_HASH', value: env.GIT_COMMIT),
            string(name: 'COMMIT_HASH', value: env.GIT_COMMIT),
            string(name: 'SOURCE_BRANCH', value: env.CHANGE_BRANCH),
            string(name: 'TARGET_BRANCH', value: env.CHANGE_TARGET)
          ]
        )
      }
    }
  }
}
