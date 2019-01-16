#!/usr/bin/env bash

main(){
  local arg

  # get VARIABLE
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

  # --new|-n NAME 
  if [[ ${__o[new]} ]]; then
    __action=newtheme
    arg="${__o[new]}"


  # --template|-t FILE|[NAME FILE]
  elif [[ ${__o[template]} ]]; then
    __action=newgenerator
    arg="${__o[template]}"
    
  # [--force|-f] --generate|-g THEME|all 
  elif [[ ${__o[generate]} ]]; then
    __action=generatetheme
    arg="${__o[generate]}"

  # --apply|-a THEME 
  elif [[ ${__o[apply]} ]]; then
    __action=applytheme
    arg="${__o[apply]}"

  # --list|-l theme|var|icon|gtk|cursor 
  elif [[ ${__o[list]} ]]; then
    __action=mondolist
    arg="${__o[list]}"

  # --call|-c FUNCTION [THEME]
  elif [[ ${__o[call]} ]]; then
    __action=callfunc
    arg="${__o[call]}"

  # [--force|-f] --update|-u GENERATOR [THEME]
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
