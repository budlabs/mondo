#!/bin/env bash

updategenerator(){

  local trgtheme dir t

  dir="$MONDO_DIR/generator/$1"

  # comment
  [[ -d "$dir" ]] \
    || ERX "generator $1 doesn't exist."

  if [[ $1 != "${__lastarg:-}" ]]; then
    trgtheme="$MONDO_DIR/themes/$__lastarg"
    [[ -f "$trgtheme" ]] \
      || ERX "$MONDO_DIR/themes/$__lastarg doesn't exist"
    setwt "$__lastarg" && themetogenerator "$1"
  else
    for t in $(mondolist themes); do
      setwt "$t"
      themetogenerator "$1"
    done
  fi
}
