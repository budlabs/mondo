#!/bin/env bash

newfile_generatorsettings(){
local fil="${1}"

echo '# The content of this file is sourced by mondo.
# The syntax is bash. But it is not recommended to
# add any script functions other then variable declaration
# in this file.

# whenever this generator is used to generate a theme
# all items in the dependcie array are checked to see
# if such command (`command -v`) exist, if not, pacmans
# local package database is searched.
# dependencies=()

# If ext is set, it will be appended as an extension
# when files are generated.
# ext=""

# If inject is set, only replace content between 
# MONDO-BEGIN and MONDO-END in target.
# inject=True

# target can be an (absolute) file path to where
# the file will be copied when a theme is applied.'\
> "$fil"

if [[ -n $filex ]]; then
  fildir=$(dirname "$filex")
  [[ $fildir = '.' ]] && fildir=$(pwd)
  echo "target=\"${fildir/$HOME/'~'}/${filex##*/}\"" 
else
  echo "target=\"\""
fi >> "$fil"
}
