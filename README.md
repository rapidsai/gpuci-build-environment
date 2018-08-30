# gpuci-build-environment

[![Build Status](http://18.191.94.64/buildStatus/icon?job=goai-docker-container-builder)](http://18.191.94.64/job/goai-docker-container-builder/)

Common build environment used by gpuCI for building libgdf/pygdf

## Usage

### Build Environment Dockerfile

Updates pushed to `master` will trigger
[builds](http://18.191.94.64/job/goai-docker-container-builder/) of the Docker
containers used for the [gpuCI service](http://18.191.94.64/)

### Build Scripts

1. Add or modify scripts to `build-scripts/` folder saving file with the name of
the job appended with `.sh`
2. Change the **Execute Shell** step in the Jenkins job to the following:
```
echo -e "\n\n>>>> Cloning build scripts...\n\n"
git clone https://github.com/gpuopenanalytics/gpuci-build-environment.git
bash gpuci-build-environment/build-scripts/${JOB_BASE_NAME}.sh
```
3. Trigger new build after changes are pushed to master to use new scripts
