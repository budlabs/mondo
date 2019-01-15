# additional_info

get VAR  
Prints the value of VAR from the last applied theme (*MONDO_DIR/themes/.current*).

FILES
-----

*MONDO_DIR/pre-apply*  
This file get executed BEFORE any other action when a THEME is applied (`-a`).

*MONDO_DIR/post-apply*  
This file get executed AFTER all other actions are executed when a THEME is applied (`-a`).

*_mondo-apply*  
This file is auto generated with each generator. It will get executed when a THEME is applied (`-a`).

*_mondo-generate*  
This file is auto generated with each generator. It will get executed when a THEME is generated (`-g`).

*_mondo-settings*  
This file is auto generated with each generator. It contains settings that will affect the generator.

*_mondo-template*  
This file is auto generated with each generator. This is the template file for the generator.

*themes/_default*  
All user created themes will inherit the content of this file, it can be used to set common variables.
