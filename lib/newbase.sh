#!/bin/env bash

newbase(){
  mkdir -p "$MONDO_DIR/themes"

  newfile_postapply 
  newfile_preapply  
  newfile_defaulttheme
  newfile_themetemplate
}
