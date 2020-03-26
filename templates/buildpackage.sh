#!/bin/bash

set -e

##*
## EDIT: Call the conda build recipe
echo "Building |<package>|"
conda build conda/recipes/|<package>| --python=$PYTHON
##*

