# options-force-description
When this flag is set, 
the `--update` and `--generate` options will overwrite any existing files when processing themes.

# options-new-description
Creates a new theme named **NAME** inside **MONDO_DIR/themes**.

# options-call-description
Can be used to test the **color functions**,
(*mix,lighter,darker,more,less*) from the commandline.  

```text
$ mondo --call "mix #FFFFFF #000000 0.6"
#666666
```

If the last argument is the name of an existing **theme**,
the variables of that theme will be available, otherwise the variables of 
the last applied theme is available.  

# options-apply-description
Apply THEME. 

# options-generate-description
Generate THEME. If `-f` is used, any existing generated files will get overwritten. If all is the argument, all themes will get generated.  

# options-update-description
Update GENERATOR. This will update all themes, but only for the given GENERATOR. If `-f` is used, any existing generated files will get overwritten. If the last argument is the name of an existing theme, only that theme will get generated.  

# options-name-description
Create a new theme.  

# options-template-description
Create a new generator. If the last argument is a path to an existing file, that file will be used to create the template (it will copy the file to *_mondo-template*, and add the path to the target variable in *_mondo-settings*). If a path is the only argument, the filename without extension and leading dot will be used as the name for the generator.

# options-list-description
Prints a list about the argument to stdout.

# options-version-description
Show version and exit.

# options-help-description
Show help and exit.
