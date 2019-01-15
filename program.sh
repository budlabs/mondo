#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
mondo - version: 0.11
updated: 2019-01-15 by budRich
EOB
}


# environment variables
: "${MONDO_DIR:=$XDG_CONFIG_HOME/mondo}"


main(){
  local arg

  # add get here for fastest getting (~16ms)
  [[ $1 = get ]] && {
    sed -n 's/^'"$2"'\b[[:space:]]*//p' \
    "$MONDO_DIR/themes/.current"
    exit
  }

  # global variables
  __action=""
  __dateformat='+%Y-%m-%d'
  __wt=""      # theme in memory
  __wt_name="" # name of theme in memory

  if [[ ${__o[new]} ]]; then
    __action=newtheme
    arg="${__o[new]}"
  elif [[ ${__o[template]} ]]; then
    __action=newgenerator
    arg="${__o[template]}"
  elif [[ ${__o[generate]} ]]; then
    __action=generatetheme
    arg="${__o[generate]}"
  elif [[ ${__o[apply]} ]]; then
    __action=applytheme
    arg="${__o[apply]}"
  elif [[ ${__o[list]} ]]; then
    __action=mondolist
    arg="${__o[list]}"
  elif [[ ${__o[update]} ]]; then
    __action=updategenerator
    arg="${__o[update]}"
  else
    ___printhelp
    exit
  fi

  "$__action" "${arg:-}"
  
}

___printhelp(){
  
cat << 'EOB' >&2
mondo - a theme template manager and generator


SYNOPSIS
--------
mondo --help|-h  
mondo --version|-v  
mondo get VARIABLE   
mondo --new|-n NAME  
mondo --apply|-a THEME  
mondo [--force|-f] --generate|-g THEME|all  
mondo [--force|-f] --update|-u GENERATOR [THEME]
mondo --list|-l theme|var|icon|gtk|cursor   
mondo --template|-t FILE|[NAME FILE]  

OPTIONS
-------

--help|-h  
Show help and exit.


--version|-v  
Show version and exit.


--new|-n NAME  

--apply|-a THEME  
Apply THEME.


--force|-f  

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


--template|-t  
Create a new generator. If the last argument is a
path to an existing file, that file will be used
to create the template (it will copy the file to
_mondo-template, and add the path to the target
variable in _mondo-settings). If a path is the
only argument, the filename without extension and
leading dot will be used as the name for the
generator.

EOB
}


applytheme(){
  local template gdir preop g

  setwt "$1"
  echo "${__wt}" > "$MONDO_DIR/themes/.current"

  [[ -x "$MONDO_DIR/pre-apply" ]] \
    && preop="$("$MONDO_DIR"/pre-apply)"

  for g in $(mondolist generator); do
    echo "$g"
    themetogenerator "$g"
    gdir="$MONDO_DIR/generator/$g"
    (
      target=""
      ext=""
      dependencies=()
      inject=

      [[ -f "$gdir/_mondo-settings" ]] \
        && . "$gdir/_mondo-settings"

      [[ -n $ext ]] \
        && template="$gdir/${__wt_name}.$ext" \
        || template="$gdir/$__wt_name"

      target="${target/'~'/$HOME}"

      if [[ -f $target ]] && [[ -n $inject ]]; then
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

ERM(){ >&2 echo "$*"; }
ERR(){ >&2 echo "[WARNING]" "$*"; }
ERX(){ >&2 echo "[ERROR]" "$*" && exit 1 ; }

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

mondolist(){
  local f

  case "$1" in

    theme* ) 
      ls "$MONDO_DIR/themes" \
      | grep -v '^_' | sort ;;

    generator* ) \
      ls "$MONDO_DIR/generator" | sort ;;

    var* )
      vf="$MONDO_DIR/themes/$__lastarg"
      [[ -f "$vf" ]] \
        && setwt "$__lastarg" \
        || __wt="$(cat "$MONDO_DIR/themes/.current")"
        # wt="$(cat "$MONDO_DIR/themes/.current")"
      echo "${__wt}" | awk '{printf "%-19s%s\n", "%%"$1"%%", $2}'

      # printf '%%%%%s%%%%%15s\n' 
    ;;

    icon*   )   
      for f in /usr/share/icons/*; do

        [[ -d "$f/cursors" ]] && continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.icons/*; do

        [[ -d "$f/cursors" ]] && continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 
    ;;

    gtk    ) 
      for f in /usr/share/themes/*; do
        [[ -d "$f/gtk-2.0" ]] || continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.themes/*; do
        [[ -d "$f/gtk-2.0" ]] || continue
        echo "${f##*/}"
      done 
    ;;

    resource*  ) 
      xrdb -query \
        | awk '$1~/mondo/ {printf "%-22s%s\n",$1,$2}' ;;

    cursor* ) 
      for f in /usr/share/icons/*; do
        [[ -d "$f/cursors" ]] || continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done 

      for f in "$HOME"/.icons/*; do
        [[ -d "$f/cursors" ]] || continue
        [[ ${f##*/} = default ]] && continue
        echo "${f##*/}"
      done  
    ;;
  esac
}

newbase(){
  mkdir -p "$MONDO_DIR/themes"

  newfile_postapply 
  newfile_preapply  
  newfile_defaulttheme
  newfile_themetemplate
}

newfile_defaulttheme(){
local fil="$MONDO_DIR/themes/_default"
[[ -f "$fil" ]] || {
echo '
bg           #222222
bg2          #333333

fg           #DDDDDD
comment      #AAAAAA

red          #FF0000
green        #00FF00
blue         #0000FF
yellow       #FFFF00
cyan         #00FFFF
magenta      #FF00FF

dark         #000000
light        #FFFFFF

activebg     cyan
activefg     light
activehl     dark

inactivebg   blue
inactivefg   fg

selectedbg   magenta
selectedfg   light

fontface1    monospace
fontsize1    16

fontface2    fontface1
fontsize2    fontsize1

fg2          comment

redb         red
greenb       green
blueb        blue
yellowb      yellow
cyanb        cyan
magentab     magenta

gtktheme
icontheme
cursortheme
' > "$fil" ;}
}

newfile_generatorapply(){
local fil="${1}"

echo '#!/bin/bash
# This script is executed every time a theme is applied.
# Each generator can have it'"'"'s own _mondo-apply script.

# The default syntax is bash, but by changing the shebang,
# one could use another language (f.i. perl or python).

# $1 is equal to: $MONOD_DIR/generator/TYPE/THEME[.extensions]

# If this script is not needed, this file can safely be removed.
# (removing the file, will improve execution speed)

# MONDO_DIR="${1%%/generator*}"
# THIS_DIR="${1%/*}"
# THIS_GENERATOR="${THIS_DIR##*/}"
# THIS_FILE="${1##*/}"
# THIS_THEME="${THIS_FILE%.*}"

# To source the settings file one could use this:
# source "${THIS_DIR}/_mondo-settings"
' > "$fil"
chmod +x "$fil"
}

newfile_generatorgenerate(){
local fil="${1}"

echo '#!/bin/bash
# This script is executed every time a theme is generated.
# Each generator can have it'"'"'s own _mondo-generate script.

# The default syntax is bash, but by changing the shebang,
# one could use another language (f.i. perl or python).

# $1 is equal to: $MONDO_DIR/generator/TYPE/THEME[.extensions]

# If this script is not needed, this file can safely be removed.
# (removing the file, will improve executioni speed)

# MONDO_DIR="${1%%/generator*}"
# THIS_DIR="${1%/*}"
# THIS_GENERATOR="${THIS_DIR##*/}"
# THIS_FILE="${1##*/}"
# THIS_THEME="${THIS_FILE%.*}"

# To source the settings file one could use this:
# source "${THIS_DIR}/_mondo-settings"
' > "$fil"
chmod +x "$fil"
}

newfile_generatorsettings(){
local fil="${1}"

echo '# The content of this file is sourced by mondo.
# The syntax is bash. But it is not recommended to
# add any script functions other then variable declaration
# in this file.

# whenever this generator is used to generate a theme
# all items in the dependcie array are checked to see
# if such command (`command -v`) exist, if not, pacmans
# local package database is searched.
# dependencies=()

# If ext is set, it will be appended as an extension
# when files are generated.
# ext=""

# If inject is set, only replace content between 
# MONDO-BEGIN and MONDO-END in target.
# inject=True

# target can be an (absolute) file path to where
# the file will be copied when a theme is applied.'\
> "$fil"

if [[ -n $filex ]]; then
  fildir=$(dirname "$filex")
  [[ $fildir = '.' ]] && fildir=$(pwd)
  echo "target=\"${fildir/$HOME/'~'}/${filex##*/}\"" 
else
  echo "target=\"\""
fi >> "$fil"
}

newfile_preapply(){
local fil="$MONDO_DIR/pre-apply"
[[ -f "$fil" ]] || {
echo '#!/bin/bash

# This script is executed before anything else, 
# when mondo is executed with the apply option (-a).

# The intension of this script is to let you prepare
# your environment before applying a new theme.

# For instance one might want to kill certain processes
# before applying, since some programs might overwrite
# the new settings with the old. 

# the output from this script will get passed to
# post-apply, which is executed after a theme has
# been applied.
' > "$fil"
chmod +x "$fil" ;}
}

newfile_postapply(){
local fil="$MONDO_DIR/post-apply"
[[ -f "$fil" ]] || {
echo '#!/bin/bash

# This script is executed AFTER all other applying
# actions and scripts are finished, when mondo is 
# executed with the apply option (-a).

# The intension of this script is to let you adjust
# your environment after applying a new theme.

# For instance one might want to reload certain processes
# like windowmanagers and statusbars. 

# $1 in this script contains the output from
# `pre-apply`. By using eval you can pass multiple
# variables and stuff between the scripts.

# eval "${1}"
' > "$fil"
chmod +x "$fil" ;}
}

newfile_themetemplate(){
local fil="$MONDO_DIR/themes/_template"
[[ -f "$fil" ]] || {
echo '
bg           #222222
bg2          #333333

fg           #DDDDDD
comment      #AAAAAA

red          #FF0000
green        #00FF00
blue         #0000FF
yellow       #FFFF00
cyan         #00FFFF
magenta      #FF00FF

dark         #000000
light        #FFFFFF

activebg     cyan
activefg     light
activehl     dark

inactivebg   blue
inactivefg   fg

selectedbg   magenta
selectedfg   light
' > "$fil" ;}
}

newgenerator(){
  local src nmn dir filex

  src="$1"
  nmn="${src##*/}" nmn=${nmn//'.'/}
  dir="$MONDO_DIR/generator/$nmn"

  [[ -d "$dir" ]] \
    && ERX "generator $nmn already exist" \
    || mkdir -p "$dir"

  [[ -f "$__lastarg" ]] && filex="$__lastarg"

  newfile_generatorapply "$dir/_mondo-apply"
  newfile_generatorgenerate "$dir/_mondo-generate"
  newfile_generatorsettings "$dir/_mondo-settings"

  [[ -n "$filex" ]] \
    && cp -f "$__lastarg" "$dir/_mondo-template" \
    || touch "$dir/_mondo-template"

  echo "$dir/_mondo-template"
}

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

themetogenerator(){
  local this_generator dir ext dep themename

  # generates a file (MONDO_DIR/generator/$1/THEME)
  # from a generator ($1) template

  this_generator="$1"
  dir="$MONDO_DIR/generator/$this_generator"

  [[ -d "$dir" ]] \
    || ERX "generator $this_generator doen't exist."

  if [[ -f "$dir/$__wt_name" ]] && ((__force!=1)); then
    [[ $__action = generatetheme ]] \
      && ERR "theme $__wt_name is already in $this_generator."
    :
  else
    ext=""
    dependencies=()

    [[ -f "$dir/_mondo-settings" ]] \
      && . "$dir/_mondo-settings"
  

    # check dependencies (defined in _mondo-settings)
    for dep in "${dependencies[@]}"; do
      command -v > /dev/null 2>&1 "$dep" \
      || pacman -Ql "$dep" > /dev/null 2>&1 || {
        ERR "$dep is needed to use the " \
            "$this_generator generator"
        return
      }
    done

    [[ -n $ext ]] \
      && themename="$__wt_name.$ext" \
      || themename="$__wt_name"
      
    {
      echo "${__wt}"
      echo "__TEMPLATE"
      cat "$dir/_mondo-template"
    } | awk '

      start!=1 && $0!="__TEMPLATE" {
        cvar=$1
        $1=""
        sub(/[[:space:]]*/,"",$0)
        cval=$0
        vars[cvar]=cval
      }

      start==1 {
        for (k in vars){
          gsub("%%"k"%%",vars[k],$0)
        }
        print
      }

      $0=="__TEMPLATE" {start=1}
    ' > "$dir/$themename"

    [[ -f "$dir/_mondo-generate" ]] \
      && "$dir/_mondo-generate" "$dir/$themename"

  fi
}

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
declare -A __o
eval set -- "$(getopt --name "mondo" \
  --options "hvn:a:fg:u:l:t" \
  --longoptions "help,version,new:,apply:,force,generate:,update:,list:,template," \
  -- "$@"
)"

while true; do
  case "$1" in
    --help       | -h ) __o[help]=1 ;; 
    --version    | -v ) __o[version]=1 ;; 
    --new        | -n ) __o[new]="${2:-}" ; shift ;;
    --apply      | -a ) __o[apply]="${2:-}" ; shift ;;
    --force      | -f ) __o[force]=1 ;; 
    --generate   | -g ) __o[generate]="${2:-}" ; shift ;;
    --update     | -u ) __o[update]="${2:-}" ; shift ;;
    --list       | -l ) __o[list]="${2:-}" ; shift ;;
    --template   | -t ) __o[template]=1 ;; 
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


main "${@:-}"


