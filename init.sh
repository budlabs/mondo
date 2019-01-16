#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
mondo - version: 2019.01.16.1
updated: 2019-01-16 by budRich
EOB
}


# environment variables
: "${MONDO_DIR:=$XDG_CONFIG_HOME/mondo}"


___printhelp(){
  
cat << 'EOB' >&2
mondo - a theme template manager and generator


SYNOPSIS
--------
mondo get VARIABLE   
mondo --new|-n NAME  
mondo --apply|-a THEME  
mondo [--force|-f] --generate|-g THEME|all  
mondo [--force|-f] --update|-u GENERATOR [THEME]
mondo --list|-l theme|var|icon|gtk|cursor   
mondo --template|-t FILE|[NAME FILE] 
mondo --call|-c FUNCTION [THEME]
mondo --help|-h  
mondo --version|-v  

OPTIONS
-------

--new|-n NAME  
Creates a new theme named NAME inside
MONDO_DIR/themes.


--apply|-a THEME  
Apply THEME.


--force|-f  
When this flag is set,  the --update and
--generate options will overwrite any existing
files when processing themes.


--generate|-g all  
Generate THEME. If -f is used, any existing
generated files will get overwritten. If all is
the argument, all themes will get generated.  


--update|-u GENERATOR  
Update GENERATOR. This will update all themes,
but only for the given GENERATOR. If -f is used,
any existing generated files will get overwritten.
If the last argument is the name of an existing
theme, only that theme will get generated.  


--list|-l cursor  
Prints a list about the argument to stdout.


--template|-t FILE  
Create a new generator. If the last argument is a
path to an existing file, that file will be used
to create the template (it will copy the file to
_mondo-template, and add the path to the target
variable in _mondo-settings). If a path is the
only argument, the filename without extension and
leading dot will be used as the name for the
generator.


--call|-c FUNCTION  
Can be used to test the color functions,
(mix,lighter,darker,more,less) from the
commandline.  


   $ mondo --call "mix #FFFFFF #000000 0.6"
   #666666



If the last argument is the name of an existing
theme, the variables of that theme will be
available, otherwise the variables of  the last
applied theme is available.  


--help|-h  
Show help and exit.

--version|-v  
Show version and exit.

EOB
}


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

declare -A __o
eval set -- "$(getopt --name "mondo" \
  --options "n:a:fg:u:l:t:c:hv" \
  --longoptions "new:,apply:,force,generate:,update:,list:,template:,call:,help,version," \
  -- "$@"
)"

while true; do
  case "$1" in
    --new        | -n ) __o[new]="${2:-}" ; shift ;;
    --apply      | -a ) __o[apply]="${2:-}" ; shift ;;
    --force      | -f ) __o[force]=1 ;; 
    --generate   | -g ) __o[generate]="${2:-}" ; shift ;;
    --update     | -u ) __o[update]="${2:-}" ; shift ;;
    --list       | -l ) __o[list]="${2:-}" ; shift ;;
    --template   | -t ) __o[template]="${2:-}" ; shift ;;
    --call       | -c ) __o[call]="${2:-}" ; shift ;;
    --help       | -h ) __o[help]=1 ;; 
    --version    | -v ) __o[version]=1 ;; 
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

if [[ ${__o[help]:-} = 1 ]]; then
  ___printhelp
  exit
elif [[ ${__o[version]:-} = 1 ]]; then
  ___printversion
  exit
fi

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" \
  || true





