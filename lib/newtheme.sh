#!/bin/env bash

newtheme(){
  [[ -f "$MONDO_DIR/themes/$1" ]] && ((__force!=1)) \
    && ERX "theme $1 already exist"

  [[ -f "$MONDO_DIR/themes/_default" ]] \
    || newbase

  { 
    printf '!! %-10s%s\n' \
      "Theme:" "$1" \
      "Author:" "$USER" \
      "Created:" "$(date "$__dateformat")"

    cat "$MONDO_DIR/themes/_template"
  } > "$MONDO_DIR/themes/$1"
}
