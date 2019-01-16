#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
mondo - version: 2019.01.16.0
updated: 2019-01-16 by budRich
EOB
}


# environment variables
: "${MONDO_DIR:=$XDG_CONFIG_HOME/mondo}"


main(){
  local arg

  # get VARIABLE
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

  # --new|-n NAME 
  if [[ ${__o[new]} ]]; then
    __action=newtheme
    arg="${__o[new]}"


  # --template|-t FILE|[NAME FILE]
  elif [[ ${__o[template]} ]]; then
    __action=newgenerator
    arg="${__o[template]}"
    
  # [--force|-f] --generate|-g THEME|all 
  elif [[ ${__o[generate]} ]]; then
    __action=generatetheme
    arg="${__o[generate]}"

  # --apply|-a THEME 
  elif [[ ${__o[apply]} ]]; then
    __action=applytheme
    arg="${__o[apply]}"

  # --list|-l theme|var|icon|gtk|cursor 
  elif [[ ${__o[list]} ]]; then
    __action=mondolist
    arg="${__o[list]}"

  # --call|-c FUNCTION [THEME]
  elif [[ ${__o[call]} ]]; then
    __action=callfunc
    arg="${__o[call]}"

  # [--force|-f] --update|-u GENERATOR [THEME]
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

awklib() {
cat << 'EOB'
function addcolor(hex) {

  if (match(hex,/^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})?/,ma)) {
    ac[hex]["RGB"]["R"]=strtonum("0x"ma[1])
    ac[hex]["RGB"]["G"]=strtonum("0x"ma[2])
    ac[hex]["RGB"]["B"]=strtonum("0x"ma[3])
    ac[hex]["HEX"]["R"]=ma[1]
    ac[hex]["HEX"]["G"]=ma[2]
    ac[hex]["HEX"]["B"]=ma[3]

    if (ma[4] ~ /./) {
      ac[hex]["RGB"]["A"]=strtonum("0x"ma[4])
      ac[hex]["HEX"]["A"]=ma[4]
    } else {
      ac[hex]["RGB"]["A"]="255"
      ac[hex]["HEX"]["A"]="FF"
    }

    return 0
  } else {
    return 1
  }
}

function isdark(c, darkness) {
  darkness = (1-(0.299*ac[c]["RGB"]["R"] + 0.587*ac[c]["RGB"]["G"] + 0.114*ac[c]["RGB"]["B"])/255)
  if(darkness<0.5){
    return 0
    } else {
    return 1
  }
}

function mix(c1, c2, ratio, iRatio,r,g,b,a,hex) {
  if (ac[c1]["HEX"]["R"] !~ /./) {addcolor(c1)}
  if (ac[c2]["HEX"]["R"] !~ /./) {addcolor(c2)}
  if ( ratio > 1 ) ratio = 1
  else if ( ratio < 0 ) ratio = 0
  iRatio = 1.0 - ratio

  r = ((ac[c1]["RGB"]["R"] * iRatio) + (ac[c2]["RGB"]["R"] * ratio))
  g = ((ac[c1]["RGB"]["G"] * iRatio) + (ac[c2]["RGB"]["G"] * ratio))
  b = ((ac[c1]["RGB"]["B"] * iRatio) + (ac[c2]["RGB"]["B"] * ratio))

  hex = sprintf("#%02X%02X%02X",r,g,b)

  if ((length(c1)>7) || (length(c2)>7)) {

    if ((length(c1)>7) && (length(c2)>7)) {
      a = ((ac[c1]["RGB"]["A"] * iRatio) + (ac[c2]["RGB"]["A"] * ratio))
    }
    else if (length(c1)>7) {
      a = ac[c1]["RGB"]["A"]
    }
    else
      a = ac[c2]["RGB"]["A"]

    hex = hex sprintf("%02X",a)
  }

  addcolor(hex)
  return hex
}

function more(c, ratio) {
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}
  if (isdark(c)) {
    return darker(c,ratio)
  } else {
    return lighter(c,ratio)
  }
}

function less(c, ratio) {
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}
  if (isdark(c)) {
    return lighter(c,ratio)
  } else {
    return darker(c,ratio)
  }
}

function darker(c,ratio) {
  return mix(c,"#000000",ratio)
}

function lighter(c,ratio) {
  return mix(c,"#FFFFFF",ratio)
}

function expand(e,ea,r) {
  
  split(e,ea," ")

  if (length(ea) == 1) {
    r = vars[e]
  } 

  else {
    if (ea[2] !~ /^#/) {ea[2] = vars[ea[2]]}
    switch (ea[1]) {

      case "darker":
        r = darker(ea[2],ea[3])
      break

      case "lighter":
        r = lighter(ea[2],ea[3])
      break

      case "more":
        r = more(ea[2],ea[3])
      break

      case "less":
        r = less(ea[2],ea[3])
      break

      case "mix":
        if (ea[3] !~ /^#/) {ea[3] = vars[ea[3]]}
        r = mix(ea[2],ea[3],ea[4])
      break

    }
  }

  if (colorformat != "default") {
    r = printc(r,colorformat)
  }

  return r
}

function printc(c,f,r) {
  # if not a color just return back
  if (c !~ /^#/) {return c}
  r = f
  # if color not in ac array, add it
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}

  gsub(/%R/,ac[c]["HEX"]["R"],r)
  gsub(/%G/,ac[c]["HEX"]["G"],r)
  gsub(/%B/,ac[c]["HEX"]["B"],r)
  gsub(/%A/,ac[c]["HEX"]["A"],r)
  gsub(/%r/,ac[c]["RGB"]["R"],r)
  gsub(/%g/,ac[c]["RGB"]["G"],r)
  gsub(/%b/,ac[c]["RGB"]["B"],r)
  gsub(/%a/,ac[c]["RGB"]["A"],r)

  return r
}
EOB
}

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

      echo "${__wt}" | awk '{printf "%-19s%s\n", "%%"$1"%%", gensub("^"$1"\\s*","",1,$0)}'
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

# uncomment the colorformat below to use HEX (00-FF)
# This is how fully opaque "white" would look like
# with this format: #FFFFFFFF
# colorformat="#%R%G%B%A"

# uncomment the colorformat below to use RGB (0-255)
# This is how fully opaque "white" would look like
# with this format: 255,255,255,255
# colorformat="%r,%g,%b,%a"

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

  if [[ -f "$dir/$__wt_name" ]] && ((__o[force]!=1)); then
    [[ $__action = generatetheme ]] \
      && ERR "theme $__wt_name is already in $this_generator."
    :
  else
    ext=""
    dependencies=()
    colorformat="default"

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
    } | awk -i <(awklib) -v colorformat="${colorformat}" '

      start!=1 && $0!="__TEMPLATE" && match($0,/(\w+)\s+(.+)/,ma) {
        vars[ma[1]]=ma[2]
      }

      start==1 {
        split($0,apa,"%%")
        for (l in apa) {
          if (l%2==0) {
            toreplace=apa[l]
            toexpand=expand(apa[l])
            sub("%%"toreplace"%%",toexpand)
          }
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


main "${@:-}"


