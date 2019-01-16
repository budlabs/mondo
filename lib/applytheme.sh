#!/bin/env bash

applytheme(){
  local template gdir preop g

  setwt "$1"
  echo "${__wt}" > "$MONDO_DIR/themes/.current"

  [[ -x "$MONDO_DIR/pre-apply" ]] \
    && preop="$("$MONDO_DIR"/pre-apply)"

  for g in $(mondolist generator); do
    themetogenerator "$g"
    gdir="$MONDO_DIR/generator/$g"
    (
      target=""
      ext=""
      dependencies=()
      inject=""

      [[ -f "$gdir/_mondo-settings" ]] \
        && . "$gdir/_mondo-settings"

      [[ -n $ext ]] \
        && template="$gdir/${__wt_name}.$ext" \
        || template="$gdir/$__wt_name"

      target="${target/'~'/$HOME}"

      if [[ -f $target ]] && [[ ${inject,,} = true ]]; then
        trgtop="$(awk '{print;if(/MONDO-BEGIN$/) exit}' "$target")"
        trgbot="$(awk '/MONDO-END$/{ss=1};ss==1{print}' "$target")"
        cat <(echo "${trgtop}") "$template" <(echo "${trgbot}") > "$target"
      elif [[ -n $target ]]; then
        mkdir -p "${target%/*}"
        cp -f "$template" "${target}"
      fi

      [[ -f "$gdir/_mondo-apply" ]] \
        && "$gdir/_mondo-apply" "$template"
    )
  done

  [[ -f "$MONDO_DIR/post-apply" ]] \
    && "$MONDO_DIR/post-apply" "${preop}"
}
