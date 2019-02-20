---
description: >
  a theme template manager and generator
updated:       2019-02-20
version:       2019.02.20.3
author:        budRich
repo:          https://github.com/budlabs/mondo
created:       2018-01-25
dependencies:  [bash, gawk, sed]
see-also:      [bash(1), awk(1), sed(1)]
license:       mit
environ:
    XDG_CONFIG_HOME: $HOME/.config
    MONDO_DIR: $XDG_CONFIG_HOME/mondo
synopsis: |
    get VARIABLE   
    --new|-n NAME  
    --apply|-a THEME  
    [--force|-f] --generate|-g THEME|all  
    [--force|-f] --update|-u GENERATOR [THEME]
    --list|-l theme|var|icon|gtk|cursor   
    --template|-t FILE|[NAME FILE] 
    --call|-c FUNCTION [THEME]
    --help|-h  
    --version|-v  
...



# long_description

`mondo` applies variables defined in themefiles to templates defined in generators. `mondo` executes userdefined scripts before any theme is applied, after each theme is applies and after all themes are applied. It can also execute a script after each theme is *generated*.  
