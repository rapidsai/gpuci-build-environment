pipeline {
  agent {
    node {
      label 'runner'
    }
  }
  stages {
    stage('gpuCI/parallel/miniconda-miniforge') {
      parallel {
        stage('gpuCI/build/miniconda-cuda') {
          steps {
            retry(1) {
              build(
                job: 'gpuci/gpuci-build-environment-jobs/miniconda-cuda',
                wait: true,
                propagate: true,
                parameters: [
                  string(name: 'GIT_URL', value: env.GIT_URL),
                  string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
                  string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
                ]
              )
            }
          }
        }
        stage('gpuCI/build/miniforge-cuda') {
          steps {
            retry(1) {
              build(
                job: 'gpuci/gpuci-build-environment-jobs/miniforge-cuda',
                wait: true,
                propagate: true,
                parameters: [
                  string(name: 'GIT_URL', value: env.GIT_URL),
                  string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
                  string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
                ]
              )
            }
          }
        }
        stage('gpuCI/build/miniforge-cuda-l4t') {
          steps {
            retry(1) {
              build(
                job: 'gpuci/gpuci-build-environment-jobs/miniforge-cuda-l4t',
                wait: true,
                propagate: true,
                parameters: [
                  string(name: 'GIT_URL', value: env.GIT_URL),
                  string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
                  string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
                ]
              )
            }
          }
        }
      }
    }
    stage('gpuCI/build/miniconda-cuda-driver') {
      steps {
        retry(1) {
          build(
            job: 'gpuci/gpuci-build-environment-jobs/miniconda-cuda-driver',
            wait: true,
            propagate: true,
            parameters: [
              string(name: 'GIT_URL', value: env.GIT_URL),
              string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
              string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
            ]
          )
        }
      }
    }
    stage('gpuCI/build/rapidsai') {
      steps {
        retry(1) {
          build(
            job: 'gpuci/gpuci-build-environment-jobs/rapidsai',
            wait: true,
            propagate: true,
            parameters: [
              string(name: 'GIT_URL', value: env.GIT_URL),
              string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
              string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
            ]
          )
        }
      }
    }
    stage('gpuCI/build/rapidsai-l4t') {
      steps {
        retry(1) {
          build(
            job: 'gpuci/gpuci-build-environment-jobs/rapidsai-l4t',
            wait: true,
            propagate: true,
            parameters: [
              string(name: 'GIT_URL', value: env.GIT_URL),
              string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
              string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
            ]
          )
        }
      }
    }
    stage('gpuCI/build/rapidsai-driver') {
      steps {
        retry(1) {
          build(
            job: 'gpuci/gpuci-build-environment-jobs/rapidsai-driver',
            wait: true,
            propagate: true,
            parameters: [
              string(name: 'GIT_URL', value: env.GIT_URL),
              string(name: 'PR_ID', value: (env.CHANGE_ID == null) ? 'BRANCH' : env.CHANGE_ID),
              string(name: 'COMMIT_HASH', value: (env.CHANGE_ID == null) ? env.GIT_BRANCH : 'origin/pr/'+env.CHANGE_ID+'/merge')
            ]
          )
        }
      }
    }
  }
}
