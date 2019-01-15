---
description: >
  a theme template manager and generator
updated:       2019-01-15
version:       0.11
author:        budRich
repo:          https://github.com/budlabs/mondo
created:       2018-01-25
dependencies:  [bash, gawk, sed]
see-also:      [bash(1), awk(1), sed(1)]
environ:
    MONDO_DIR: $XDG_CONFIG_HOME/mondo
synopsis: |
    --help|-h  
    --version|-v  
    get VARIABLE   
    --new|-n NAME  
    --apply|-a THEME  
    [--force|-f] --generate|-g THEME|all  
    [--force|-f] --update|-u GENERATOR [THEME]
    --list|-l theme|var|icon|gtk|cursor   
    --template|-t **FILE**|[NAME *FILE*]  
...
