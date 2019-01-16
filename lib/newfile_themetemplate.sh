#!/bin/env bash

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
