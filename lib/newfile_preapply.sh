#!/bin/env bash

newfile_preapply(){
local fil="$MONDO_DIR/pre-apply"
[[ -f "$fil" ]] || {
echo '#!/bin/bash

# This script is executed before anything else, 
# when mondo is executed with the apply option (-a).

# The intension of this script is to let you prepare
# your environment before applying a new theme.

# For instance one might want to kill certain processes
# before applying, since some programs might overwrite
# the new settings with the old. 

# the output from this script will get passed to
# post-apply, which is executed after a theme has
# been applied.
' > "$fil"
chmod +x "$fil" ;}
}

newfile_postapply(){
local fil="$MONDO_DIR/post-apply"
[[ -f "$fil" ]] || {
echo '#!/bin/bash

# This script is executed AFTER all other applying
# actions and scripts are finished, when mondo is 
# executed with the apply option (-a).

# The intension of this script is to let you adjust
# your environment after applying a new theme.

# For instance one might want to reload certain processes
# like windowmanagers and statusbars. 

# $1 in this script contains the output from
# `pre-apply`. By using eval you can pass multiple
# variables and stuff between the scripts.

# eval "${1}"
' > "$fil"
chmod +x "$fil" ;}
}
