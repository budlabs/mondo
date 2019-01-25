#!/bin/env bash

newgenerator(){
  local src nmn dir filex

  src="$1"
  nmn="${src##*/}" nmn=${nmn//'.'/}
  dir="$MONDO_DIR/generator/$nmn"

  [[ -d "$dir" ]] \
    && ERX "generator $nmn already exist" \
    || mkdir -p "$dir"

  [[ -f "${filex:=${__lastarg/'~'/$HOME}}" ]] \
    || filex=""

  newfile_generatorapply "$dir/_mondo-apply"
  newfile_generatorgenerate "$dir/_mondo-generate"
  newfile_generatorsettings "$dir/_mondo-settings"

  [[ -f "$filex" ]] \
    && cp -f "$filex" "$dir/_mondo-template" \
    || touch "$dir/_mondo-template"

  echo "$dir/_mondo-template"
}
