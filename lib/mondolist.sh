#!/bin/env bash

mondolist(){
  local f

  case "$1" in

    theme* ) 
      ls "$MONDO_DIR/themes" \
      | grep -v '^_' | sort ;;

    generator* ) \
      ls "$MONDO_DIR/generator" | sort ;;

    var* )
      vf="$MONDO_DIR/themes/$__lastarg"
      [[ -f "$vf" ]] \
        && setwt "$__lastarg" \
        || __wt="$(cat "$MONDO_DIR/themes/.current")"
        # wt="$(cat "$MONDO_DIR/themes/.current")"
      echo "${__wt}" | awk '{printf "%-19s%s\n", "%%"$1"%%", $2}'

      # printf '%%%%%s%%%%%15s\n' 
    ;;

    icon*   )   
      for f in /usr/share/icons/*; do

        [[ -d "$f/cursors" ]] && continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.icons/*; do

        [[ -d "$f/cursors" ]] && continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 
    ;;

    gtk    ) 
      for f in /usr/share/themes/*; do
        [[ -d "$f/gtk-2.0" ]] || continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.themes/*; do
        [[ -d "$f/gtk-2.0" ]] || continue
        echo "${f##*/}"
      done 
    ;;

    resource*  ) 
      xrdb -query \
        | awk '$1~/mondo/ {printf "%-22s%s\n",$1,$2}' ;;

    cursor* ) 
      for f in /usr/share/icons/*; do
        [[ -d "$f/cursors" ]] || continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.icons/*; do
        [[ -d "$f/cursors" ]] || continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done  
    ;;
  esac
}
