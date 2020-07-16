# Contributing to gpuci-build-environment

If you are interested in contributing to gpuci-build-environment, your contributions will fall
into three categories:
1. You want to report a bug, feature request, or documentation issue
    - File an [issue](https://github.com/rapidsai/gpuci-build-environment/issues/new)
    describing what you encountered or what you want to see changed.
    - The RAPIDS team will evaluate the issues and triage them, scheduling
    them for a release. If you believe the issue needs priority attention
    comment on the issue to notify the team.
2. You want to propose a new Feature and implement it
    - Post about your intended feature, and we shall discuss the design and
    implementation.
    - Once we agree that the plan looks good, go ahead and implement it, using
    the [code contributions](#code-contributions) guide below.
3. You want to implement a feature or bug-fix for an outstanding issue
    - Follow the [code contributions](#code-contributions) guide below.
    - If you need more context on a particular issue, please ask and we shall
    provide.

## Code contributions

### Your first issue

1. Read the project's [README.md](https://github.com/rapidsai/gpuci-build-environment/blob/main/README.md)
    to learn how to setup the development environment
2. Find an issue to work on. The best way is to look for the [good first issue](https://github.com/rapidsai/gpuci-build-environment/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
    or [help wanted](https://github.com/rapidsai/gpuci-build-environment/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) labels
3. Comment on the issue saying you are going to work on it
4. Code! Make sure to update unit tests!
5. When done, [create your pull request](https://github.com/rapidsai/gpuci-build-environment/compare)
6. Verify that CI passes all [status checks](https://help.github.com/articles/about-status-checks/). Fix if needed
7. Wait for other developers to review your code and update code as needed
8. Once reviewed and approved, a RAPIDS developer will merge your pull request

Remember, if you are unsure about anything, don't hesitate to comment on issues
and ask for clarifications!

### Attribution
Portions adopted from https://github.com/pytorch/pytorch/blob/master/CONTRIBUTING.md

# Development and Repo Details

## Folder Structure

Root folders in this repo correspond to the image name hosted on
[Docker Hub](https://hub.docker.com/u/gpuci). These should be descriptive for
the image or matching the name of the GH organization that uses the image for
gpuCI.

There is one current exception `/legacy` which hosts legacy images.

## Extending Containers

More information to come...

## gpuCI Integration

More information to come...
