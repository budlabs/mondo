#!/usr/bin/env bash

# bg           #F2DAAE
# bg2          %%more bg 0.15%%
# vars[cvar]=cval

readtheme(){
  awk -i <(awklib) -v colorformat="default" '
    match($0,/^\s*([^!]\w+)\s+(%%)?(.+)(%%)?\s*$/,ma) {
      cvar=ma[1]
      if (ma[2] == "%%")
        cval = expand(ma[3])
      else
        cval=ma[3]
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
