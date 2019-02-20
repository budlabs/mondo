`mondo` - a theme template manager and generator

SYNOPSIS
--------
```text
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
```

DESCRIPTION
-----------
`mondo` applies variables defined in themefiles
to templates defined in generators. `mondo`
executes userdefined scripts before any theme is
applied, after each theme is applies and after all
themes are applied. It can also execute a script
after each theme is *generated*.  


OPTIONS
-------

`--new`|`-n` NAME  
Creates a new theme named **NAME** inside
**MONDO_DIR/themes**.

`--apply`|`-a` THEME  
Apply THEME.

`--force`|`-f`  
When this flag is set,  the `--update` and
`--generate` options will overwrite any existing
files when processing themes.

`--generate`|`-g` all  
Generate THEME. If `-f` is used, any existing
generated files will get overwritten. If all is
the argument, all themes will get generated.  

`--update`|`-u` GENERATOR  
Update GENERATOR. This will update all themes,
but only for the given GENERATOR. If `-f` is used,
any existing generated files will get overwritten.
If the last argument is the name of an existing
theme, only that theme will get generated.  

`--list`|`-l` cursor  
Prints a list about the argument to stdout.

`--template`|`-t` FILE  
Create a new generator. If the last argument is a
path to an existing file, that file will be used
to create the template (it will copy the file to
*_mondo-template*, and add the path to the target
variable in *_mondo-settings*). If a path is the
only argument, the filename without extension and
leading dot will be used as the name for the
generator.

`--call`|`-c` FUNCTION  
Can be used to test the **color functions**,
(*mix,lighter,darker,more,less*) from the
commandline.  

```text
$ mondo --call "mix #FFFFFF #000000 0.6"
#666666
```


If the last argument is the name of an existing
**theme**, the variables of that theme will be
available, otherwise the variables of  the last
applied theme is available.  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.


EXAMPLES
--------
With **mondo** you can have several small theme
files that might look something like this:  

**MONDO_DIR/themes/example**
```
! example theme

background          #FFFFD8
background-alt      %%more background 0.12%%

foreground          #988d6d
comment             %%mix background foreground 0.524%%

red                 #CD5C5C
green               #8EAE71
blue                #0287c8
yellow              #CDFFCC
cyan                #8FCCCC
magenta             #8888CC

highlight           magenta
font                Hack 12
```


It is really easy to create custom templates and
actions (scripts) that will use the theme files.  

An example of how the theme above could be:  
* apply values to polybar, i3, xresources
* execute a script in which polybar, i3, and xrdb is reloaded


See the [wiki] for a more details on how to use
**mondo**.

ENVIRONMENT
-----------

`XDG_CONFIG_HOME`  
amani[environ][0][XDG_CONFIG_HOME][description]
defaults to: $HOME/.config

`MONDO_DIR`  
The path to a directory where all mondo files
are.
defaults to: $XDG_CONFIG_HOME/mondo

DEPENDENCIES
------------
`bash`
`gawk`
`sed`



