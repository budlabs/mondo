#!/bin/env bash

setwt(){
  # reads base theme
  # overwrite base theme with target theme ($1)

  [[ -f "$MONDO_DIR/themes/$1" ]] \
    || ERX "theme $1 doen't exist."

  __wt_name="$1"

  __wt="$(
    cd "$MONDO_DIR/themes"
    readtheme <(
      echo theme "$__wt_name"
      cat "$__wt_name" _default "$__wt_name")
  )"
}
