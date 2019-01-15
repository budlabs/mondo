#!/bin/env bash

themetogenerator(){
  local this_generator dir ext dep themename

  # generates a file (MONDO_DIR/generator/$1/THEME)
  # from a generator ($1) template

  this_generator="$1"
  dir="$MONDO_DIR/generator/$this_generator"

  [[ -d "$dir" ]] \
    || ERX "generator $this_generator doen't exist."

  if [[ -f "$dir/$__wt_name" ]] && ((__force!=1)); then
    [[ $__action = generatetheme ]] \
      && ERR "theme $__wt_name is already in $this_generator."
    :
  else
    ext=""
    dependencies=()

    [[ -f "$dir/_mondo-settings" ]] \
      && . "$dir/_mondo-settings"
  

    # check dependencies (defined in _mondo-settings)
    for dep in "${dependencies[@]}"; do
      command -v > /dev/null 2>&1 "$dep" \
      || pacman -Ql "$dep" > /dev/null 2>&1 || {
        ERR "$dep is needed to use the " \
            "$this_generator generator"
        return
      }
    done

    [[ -n $ext ]] \
      && themename="$__wt_name.$ext" \
      || themename="$__wt_name"
      
    {
      echo "${__wt}"
      echo "__TEMPLATE"
      cat "$dir/_mondo-template"
    } | awk '

      start!=1 && $0!="__TEMPLATE" {
        cvar=$1
        $1=""
        sub(/[[:space:]]*/,"",$0)
        cval=$0
        vars[cvar]=cval
      }

      start==1 {
        for (k in vars){
          gsub("%%"k"%%",vars[k],$0)
        }
        print
      }

      $0=="__TEMPLATE" {start=1}
    ' > "$dir/$themename"

    [[ -f "$dir/_mondo-generate" ]] \
      && "$dir/_mondo-generate" "$dir/$themename"

  fi
}
