#!/usr/bin/env bash

##*
## EDIT: If your packages are CUDA or Python version independent, use these 
##       blocks to only upload them only once per CUDA/Python version

#Upload |<package>| once per PYTHON
if [[ "$CUDA" == "10.0" ]]; then
    export UPLOAD_|<package>|=1
else
    export UPLOAD_|<package>|=0
fi

#Upload |<package>| once per CUDA
if [[ "$PYTHON" == "3.6" ]]; then
    export UPLOAD_|<package>|=1
else
    export UPLOAD_|<package>|=0
fi
##*

