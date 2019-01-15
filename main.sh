#!/usr/bin/env bash

main(){
  local arg

  # add get here for fastest getting (~16ms)
  [[ $1 = get ]] && {
    sed -n 's/^'"$2"'\b[[:space:]]*//p' \
    "$MONDO_DIR/themes/.current"
    exit
  }

  # global variables
  __action=""
  __dateformat='+%Y-%m-%d'
  __wt=""      # theme in memory
  __wt_name="" # name of theme in memory

  if [[ ${__o[new]} ]]; then
    __action=newtheme
    arg="${__o[new]}"
  elif [[ ${__o[template]} ]]; then
    __action=newgenerator
    arg="${__o[template]}"
  elif [[ ${__o[generate]} ]]; then
    __action=generatetheme
    arg="${__o[generate]}"
  elif [[ ${__o[apply]} ]]; then
    __action=applytheme
    arg="${__o[apply]}"
  elif [[ ${__o[list]} ]]; then
    __action=mondolist
    arg="${__o[list]}"
  elif [[ ${__o[update]} ]]; then
    __action=updategenerator
    arg="${__o[update]}"
  else
    ___printhelp
    exit
  fi

  "$__action" "${arg:-}"
  
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud
