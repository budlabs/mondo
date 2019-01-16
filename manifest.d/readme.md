# readme_banner

**mondo** is a great tool to manage and create themes and other settings for programs that uses configuration files.

[![Sparkline](https://stars.medv.io/budlabs/mondo.svg)](https://stars.medv.io/budlabs/mondo)


# examples

With **mondo** you can have several small theme files that might look something like this:  

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

It is really easy to create custom templates and actions (scripts) that will use the theme files.  

An example of how the theme above could be:  
* apply values to polybar, i3, xresources
* execute a script in which polybar, i3, and xrdb is reloaded

See the [wiki] for a more details on how to use **mondo**.

# readme_install

If you are using **Arch linux**, you can install the **mondo-generator** package from [AUR].  

Or follow the instructions below to install from source:  

(*configure the installation destination in the Makefile, if needed*)

``` text
$ git clone https://github.com/budlabs/mondo.git
$ cd mondo
# make install
$ mondo -v
mondo - version: 0.121
updated: 2019-01-16 by budRich
```

# readme_issues

Mondo makes ricing so fun and easy, that it might cause addiction.

