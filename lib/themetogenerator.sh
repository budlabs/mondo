#!/bin/env bash

themetogenerator(){
  local this_generator dir ext dep themename

  # generates a file (MONDO_DIR/generator/$1/THEME)
  # from a generator ($1) template

  this_generator="$1"
  dir="$MONDO_DIR/generator/$this_generator"

  [[ -d "$dir" ]] \
    || ERX "generator $this_generator doen't exist."

  if [[ -f "$dir/$__wt_name" ]] && ((__o[force]!=1)); then
    [[ $__action = generatetheme ]] \
      && ERR "theme $__wt_name is already in $this_generator."
    :
  else
    ext=""
    dependencies=()
    colorformat="default"

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
    } | awk -i <(awklib) -v colorformat="${colorformat}" '

      start!=1 && $0!="__TEMPLATE" && match($0,/(\w+)\s+(.+)/,ma) {
        vars[ma[1]]=ma[2]
      }

      start==1 {
        split($0,apa,"%%")
        for (l in apa) {
          if (l%2==0) {
            toreplace=apa[l]
            toexpand=expand(apa[l])
            sub("%%"toreplace"%%",toexpand)
          }
        }
        
        print
      }

      $0=="__TEMPLATE" {start=1}

    ' > "$dir/$themename"

    [[ -f "$dir/_mondo-generate" ]] \
      && "$dir/_mondo-generate" "$dir/$themename"

  fi
}
