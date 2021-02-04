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
              job: 'gpuci/gpuci-build-environment-jobs/miniconda-cuda',
              wait: true,
              propagate: true,
              parameters: [
                string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
                string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
              ]
            )
          }
        }
        stage('gpuCI/build/miniforge-cuda') {
          steps {
            build(
              job: 'gpuci/gpuci-build-environment-jobs/miniforge-cuda',
              wait: true,
              propagate: true,
              parameters: [
                string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
                string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
              ]
            )
          }
        }
      }
    }
    stage('gpuCI/build/miniconda-cuda-driver') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment-jobs/miniconda-cuda-driver',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
            string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
          ]
        )
      }
    }
    stage('gpuCI/build/rapidsai') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment-jobs/rapidsai',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
            string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
          ]
        )
      }
    }
    stage('gpuCI/build/rapidsai-driver') {
      steps {
        build(
          job: 'gpuci/gpuci-build-environment-jobs/rapidsai-driver',
          wait: true,
          propagate: true,
          parameters: [
            string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
            string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
          ]
        )
      }
    }
  }
}
