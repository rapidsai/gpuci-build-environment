# gpuCI Script Templates

## Overview

These templates provide a guide for developers to assist them in adding the needed integration scripts to work with the gpuCI. Every script here is required for full integration into the gpuCI infrastructure.

## Usage

The templates have been marked to show developers where to make changes on the files. These markers are made to be easily found using your preferred file search function. All comments with *exactly* two hashtags should be removed before being finalized.

Marker | Meaning
--- | ---
`##` | Generally represents useful information for guiding the user
`##*` | Represents the *start* or *end* of an area in a script that is expected to be edited
`## EDIT:` | A short description of what should be edited in the codeblock encapsulated by `##*`
`|<` or `>|` | Represents a specific area in the code that should be edited. Also encapsulates a short description of what should replace it


## Description

* `rootbuild.sh` - Located at repository root `/`, this script is the main build script that builds your package from source. This script should be also be useable by users as a simplistic way to build the project. Rename this script to `build.sh` when committing to the repository.

* `cpubuild.sh` - Located in the ci folder `ci/cpu/`, this script is the build script that tests each of your `conda build` recipes to verify the stability of your `meta.yaml`. Rename to `build.sh` when committing to the repository.

* `buildpackage.sh` - Located in the ci folder `ci/cpu/<package>`, this script calls a specific package's `conda build` command. Rename to `build_<package>.sh` when committing to the repository.

* `condabuild.sh` - Located in the conda folder `conda/recipes/<package>`, this script is the default script used by `conda build` and executes a source build of a specific package. Rename to `build.sh` when committing to the repository.

* `meta.yaml` - Located in the conda folder `conda/recipes/<package>`, this script describes various information of a specific package and contains dependency information to build the package with `conda build`.

* `prebuild.sh` - Located in the ci folder `ci/cpu/`, this script defines which packages get uploaded in configuration builds. If you have a python/cuda independent package, then this will handle limiting the number of package uploads. Can also be used for other prebuild actions.

* `upload_anaconda.sh` - Located in the ci folder `ci/cpu/`, this script determines if the package will be uploaded to conda based on the type of build being performed.

* `gpubuild.sh` - Located in the ci folder `ci/gpu/`, this script performs a full source build of every package in the repository, and performs unit tests afterward. Rename to `build.sh` when committing to the repository.

* `changelog.sh` - Located in the ci folder `ci/checks/`, this script checks the changelog for a syntactically correct changelog entry into `CHANGELOG.md`.

* `style.sh` - Located in the ci folder `ci/checks/`, this script performs a python style check and outputs all style inconsistencies to its output.

* `update-version.sh` - Located in the ci folder `ci/release/`, this script performs inline edits to specific files based on release version numbers. This build triggers during releases to update all instances of a version number in the repository that need updating.

