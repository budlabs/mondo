`mondo` - Theme manager and generator

SYNOPSIS
--------
`mondo` `-v`|`-h`  
`mondo` `-a` THEME  
`mondo` [`-f`] `-g` THEME  
`mondo` `-n` *FILE*|NAME [*FILE*]  
`mondo` `-t` *FILE*|NAME [*FILE*]  

DESCRIPTION
-----------

`mondo` uses `xrdb` to apply colors and other settings
from a theme to templates created by the user. The
themes are `.Xresources` files.

Themes are stored in *MONDO_DIR/themes*. Templates 
(*mondo-template*) is one file that makes up a *generator*.
Each generator directory is located in *MONDO_DIR/generator*.

By defining special *mondo* resources in the themes,
the values stored in those resources can be used in
the templates.

Example excerpt from a theme file:  
`mondo.colors.yellow: #FFE000`

To use the value when generating a file from a template,
one could use this format:  
`YellowSubmarine="%%colors.yellow%%"`  

This would result in the following when the theme is generated:  
`YellowSubmarine="#FFE000"`  

THEMES
------

A new theme is created with the command: 
`mondo -n FILE|NAME [FILE]`

If FILE is the only argument the name of the theme will
be the file name. If NAME is the only argument the predefined
variables of the theme will be taken from Xresources. If FILE
contains Xresources colors resources those will be set as predefined
variables. Themes are stored in *MONDO_DIR/themes*  

Example of colors resources:  
``` text
*foreground:  #e9e9f4
*background:  #282936
*color0:      #282936
*color1:      #ea51b2
*color2:      #ebff87
```

The mandatory content of a theme file is the following
variables (the values can not be empty and needs to be 
in hexadecimal format):  
``` text
#define fg #73675F
#define bg #ebdbb2

#define base00 #fbf1c7
#define base01 #A69881
#define base02 #ebdbb2
#define base03 #d5c4a1

#define base0 #282828
#define base1 #73675F
#define base2 #504945
#define base3 #3c3836

#define red #9d0006
#define ora #af3a03
#define grn #79740e
#define ylw #b57614
#define blu #076678
#define mag #8f3f71
#define vio #d65d0e
#define cyn #427b58
```

The values of fg and bg must exist as values in the base groups.
They can not exist in the same group. It is strongly suggested
to keep similar colors (foreground/background) in each group.  

The xresources colors resources will be auto generated and appended
to the theme file when it is applied (mondo -a THEME). Therefor
the color resources should be removed from `~/.Xresources`.

These resources are managed by `mondo`:  
``` text
*.foreground:     fg
*.background:     bg 
*.cursorColor:    fg
*.cursorColor2:   bg
*.border:         bg

*.color0:         bg
*.color8:         base0
*.color1:         red
*.color9:         ora
*.color2:         grn
*.color10:        base1
*.color3:         ylw
*.color11:        base3
*.color4:         blu
*.color12:        vio
*.color5:         mag
*.color13:        base01
*.color6:         cyn
*.color14:        base02
*.color7:         fg
*.color15:        base03
```

The two files *mondo-base* and *mondo-init* that is found in
*MONDO_DIR* are also appended to the theme file when a theme
is applied (`mondo -a THEME`). The content of these files are not
mandatory but holds common and more or less static variable
and resource definitions.

GENERATORS  
----------  
A new generator directory is created with the command:  
`mondo -t FILE|NAME [FILE]`  

If FILE is the only argument, the name of the generator will
be the file name. If NAME is the only argument a generator without
a template (*mondo-template*) file will get created. If FILE exist,
it will be copied to the generator directory as *mondo-template*.
The path to the file will also be entered as `target` in 
*mondo-settings*. The target variable is however commented 
out by default.  

The command: `mondo -l resources` lists all resources that can
be used in a *mondo-template* file. All valid resources within 
double percentage signs (%%class.type%%) will be replaced with 
the value of that resource when a theme is generated 
(`mondo -[f]g THEME`).

When a generator is activated with an existing theme,
(`mondo -[f]g THEME`) a file is created in the generators 
directory, with the same name as the theme. If that file already
exist it will be kept untouched if not the force (`-f`) option
is set, then a new file will be generated.  

In the file, `mondo-settings`, it is possible to fine
tune the extension, and format (if format is set to *rgb*,
the color will be translated to rgb format) of the generated
file. There is also a setting called `target`, if this is set, 
the generated file will be copied (`cp -f`) to path specified  
when the theme is applied (`mondo -a THEME`).

To have other actions then copy to target being executed on the 
file one can write scripts in the files: *mondo-apply* 
(this script will get executed when the theme is applied) and 
*mondo-generate* (this will get executed AFTER the file is generated). 
These files are autocreated with each generator and are by default 
bash scripts, but if shebang is changed another interpreter could 
be used (such as perl, python, ruby or zsh).

Similarly the files *pre-apply* and *post-apply* in *MONDO_DIR* are
executed before and/or after a theme is applied and before and/or
after any generator is invoked. 

The only actions that is taken without any settings done and that
is mandatory when a theme is applied (`mondo -a THEME`) is the theme
being included in *~/.Xresources* and the command 
`xrdb -load ~/.Xresources` is executed.  

OPTIONS
-------

`-v`  
  Show version and exit.

`-h`  
  Show help and exit.
 
`-a` THEME  
  Apply THEME. The following will happen:  

    1. The file (script) MONDO_DIR/pre-apply will  
       get executed.  

    2. MONDO_DIR/mondo-theme will get created.  

    3. MONDO_DIR/mondo-theme will get included in  
       ~/.Xresources  

    4. The command `xrdb -load ~/.Xresources` will  
       get executed.  

    5. Generators will get applied and the file(s)  
       mondo-apply will get executed.  

    6. The file (script) MONDO_DIR/post-apply will  
       get executed.  


[`-f`] `-g` THEME   
  Generate THEME. The following will happen:

  1. A file named THEME will be generated based on 
     mondo-template in each generator directory if
     it doesn't already exist. If `-f` flag is set  
     it will always generate the file, even if it  
     already exist.

  2. If a file was generated the file (script)  
     *mondo-generate* will get executed.


`-n` *FILE*|NAME [*FILE*]   
  Create a new theme, see description above.  


`-t` *FILE*|NAME [*FILE*]   
    Create a new generator, see description above.


FILES
-----

*MONDO_DIR/mondo-theme*  
  This file will get generated, when a theme is  
  generated (`-g`) or applied (`-a`). The content  
  of this file is the selected  
  THEME + *MONDO_DIR/mondo-base* + *MONDO_DIR/mondo-init*  
  and some auto generated resources. This is file    
  will get included in *~/.Xresources*.  

*MONDO_DIR/mondo-base*  
  The content of this file will get appended to   
  mondo-theme, when a theme is generated (`-g`) or   
  applied (`-a`).    

*MONDO_DIR/mondo-init*  
  The content of this file will get appended to  
  mondo-theme, when a theme is generated (`-g`) or   
  applied (`-a`).    

*MONDO_DIR/pre-apply*  
  This file get executed BEFORE any other action  
  when a THEME is applied (`-a`).   

*MONDO_DIR/post-apply*  
  This file get executed AFTER all other actions are    
  executed when a THEME is applied (`-a`).  

*mondo-apply*  
  This file is auto generated with each generator.   
  It will get executed when a THEME is applied (`-a`).   

*mondo-generate*  
  This file is auto generated with each generator.   
  It will get executed when a THEME is generated (`-g`).   

*mondo-settings*  
  This file is auto generated with each generator.   
  It contains settings that will affect the generator.  

*mondo-template*  
  This file is auto generated with each generator.   
  This is the template file for the generator.  

ENVIRONMENT
-----------

`MONDO_DIR`  
  The path to a directory where all mondo files are   
  stored. Defaults to *~/.config/mondo*
