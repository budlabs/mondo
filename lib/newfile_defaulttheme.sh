#!/bin/env bash

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
