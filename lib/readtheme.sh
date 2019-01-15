#!/bin/env bash

readtheme(){
  awk '
    /./ && $1 !~ /^!/ {
      cvar=$1
      $1=""
      sub(/[[:space:]]*/,"",$0)
      cval=$0
      for (v in vars) {
        if (v==cvar || cval==v) {cval=vars[v]}
      }
      vars[cvar]=cval
    }

    END {
      for (v in vars) {
        printf "%-20s%s\n", v, vars[v]
      }
    }
  ' "$1"
}
