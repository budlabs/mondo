# mondo - a theme template manager and generator 

**mondo** is a great tool to manage and create themes and
other settings for programs that uses configuration files.


[![Sparkline](https://stars.medv.io/budlabs/mondo.svg)](https://stars.medv.io/budlabs/mondo)


## installation

If you are using **Arch linux**, you can install the
**mondo-generator** package from [AUR].  

Or follow the instructions below to install from source:  

(*configure the installation destination in the Makefile,
if needed*)

``` text
$ git clone https://github.com/budlabs/mondo.git
$ cd mondo
# make install
$ mondo -v
mondo - version: 0.121
updated: 2019-01-16 by budRich
```


### usage

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

`mondo` applies variables defined in themefiles to
templates defined in generators. `mondo` executes
userdefined scripts before any theme is applied, after each
theme is applies and after all themes are applied. It can
also execute a script after each theme is *generated*.  


OPTIONS
-------

`--new`|`-n` NAME  
Creates a new theme named **NAME** inside
**MONDO_DIR/themes**.

`--apply`|`-a` THEME  
Apply THEME.

`--force`|`-f`  
When this flag is set,  the `--update` and `--generate`
options will overwrite any existing files when processing
themes.

`--generate`|`-g` all  
Generate THEME. If `-f` is used, any existing generated
files will get overwritten. If all is the argument, all
themes will get generated.  

`--update`|`-u` GENERATOR  
Update GENERATOR. This will update all themes, but only for
the given GENERATOR. If `-f` is used, any existing generated
files will get overwritten. If the last argument is the name
of an existing theme, only that theme will get generated.  

`--list`|`-l` cursor  
Prints a list about the argument to stdout.

`--template`|`-t` FILE  
Create a new generator. If the last argument is a path to
an existing file, that file will be used to create the
template (it will copy the file to *_mondo-template*, and
add the path to the target variable in *_mondo-settings*).
If a path is the only argument, the filename without
extension and leading dot will be used as the name for the
generator.

`--call`|`-c` FUNCTION  
Can be used to test the **color functions**,
(*mix,lighter,darker,more,less*) from the commandline.  

```text
$ mondo --call "mix #FFFFFF #000000 0.6"
#666666
```


If the last argument is the name of an existing **theme**,
the variables of that theme will be available, otherwise the
variables of  the last applied theme is available.  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

EXAMPLES
--------
With **mondo** you can have several small theme files that
might look something like this:  

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


It is really easy to create custom templates and actions
(scripts) that will use the theme files.  

An example of how the theme above could be:  
* apply values to polybar, i3, xresources
* execute a script in which polybar, i3, and xrdb is reloaded


See the [wiki] for a more details on how to use **mondo**.

## updates

### 2019.02.20.5

Added default to **$XDG_CONFIG_DIR**, fixes issue [#14].

### 2019.01.16.0


Major refactoring to make use of the [bashbud] framework.  
[bashbud]: https://github.com/budlabs/bashbud



#### color functions


Added some color manipulation functions that can be used
both in themes and templates and the commandline:

**MONDO_DIR/themes/muh-theme**  
```text
bg          #FFFFFF
fg          #000000
red         #FF0000

comment     %%mix bg fg 0.6%%
darkred     %%darker red 0.465%%
bg2         %%less bg 0.33%%
green       %%more #00FF00 0.3%%
```


**less** and **more** works like this:  
First **mondo** determines whether target color is *dark*
or *light*. If the color is *light* and the command is
**more**,  the result will be **more light**  (same results
as if the command was **lighter**). If the color is *dark*
and the command is **more**,  the result will be **more
dark**  (same results as if the command was **darker**).

It is also possible to use the functions on the
commandline:  
`mondo --call|-c FUNCTION [THEME]`  

```text
$ mondo --call "mix #FFFFFF #000000 0.6"
#666666
```


If the last argument is the name of an existing **theme**,
the variables of that theme will be available:  

```text
$ mondo --call "mix #FFFFFF darkred 0.123" muh-theme
#F0DFDF
```



#### colorformat


A new setting is now available in **template-setting**
files: `colorformat`. If set, all expanded variables in
affected template will have that format.

**MONDO_DIR/generator/muh-generator/_mondo-settings**  
```text
# uncomment the colorformat below to use HEX (00-FF)
# This is how fully opaque "white" would look like
# with this format: #FFFFFFFF
# colorformat="#%R%G%B%A"

# uncomment the colorformat below to use RGB (0-255)
# This is how fully opaque "white" would look like
# with this format: 255,255,255,255
# colorformat="%r,%g,%b,%a"
```


#### fixes


Various small bugfixes, f.i. to use the `Inject` template
setting, it's value must be either `True` or `true` .  

When using the `--list` command, variables with values
containing whitespace, now gets printed properly.


## known issues

Mondo makes ricing so fun and easy, that it might cause
addiction.

[wiki]: https://github.com/budlabs/mondo/wiki
[AUR]: https://aur.archlinux.org/packages/mondo-generator/
[bashbud]: https://github.com/budlabs/bashbud


## license

**mondo** is licensed with the **MIT license**


