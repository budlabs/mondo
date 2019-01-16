#!/usr/bin/env bash

callfunc() {
  local func vf

  func="$1"
  vf="$MONDO_DIR/themes/$__lastarg"
  [[ -f "$vf" ]] \
    && setwt "$__lastarg" \
    || __wt="$(cat "$MONDO_DIR/themes/.current")"

  echo "${__wt}" | awk -i <(awklib) \
                     -v colorformat="default" \
                     -v funkis="$func" '
    match($0,/(\w+)\s+(.+)/,ma) {vars[ma[1]]=ma[2]}
    END {print expand(funkis)}
  '
}
