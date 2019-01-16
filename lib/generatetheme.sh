#!/bin/env bash

generatetheme(){
  local t g

  if [[ $1 = all ]]; then
    for t in $(mondolist themes); do 
      generatetheme "$t"
    done
  else
    setwt "$1"

    for g in $(mondolist generator); do
      themetogenerator "$g"
    done
  fi
}
