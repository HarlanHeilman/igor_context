# Organizing Procedures

Chapter IV-2 — Programming Overview
IV-24
Overview
You can perform powerful data manipulation and analysis interactively using Igor’s dialogs and the 
command line. However, if you want to automate common tasks or create custom data analysis features, then 
you need to use procedures.
You can write procedures yourself, use procedures supplied by WaveMetrics, or find someone else who has 
written procedures you can use. Even if you don’t write procedures from scratch, it is useful to know enough 
about Igor programming to be able to understand code written by others.
Programming in Igor entails creating procedures by entering text in a procedure window. After entering a 
procedure, you can execute it via the command line, by choosing an item from a menu, or using a button in 
a control panel.
The bulk of the text in a procedure window falls into one of the following categories:
•
Pragmas, which send instructions from the programmer to the Igor compiler
•
Include statements, which open other procedure files
•
Constants, which define symbols used in functions
•
Structure definitions, which can be used in functions
•
Proc Pictures, which define images used in control panels, graphs, and layouts
•
Menu definitions, which add menu items or entire menus to Igor
•
Functions — compiled code which is used for nearly all Igor programming
•
Macros — interpreted code which, for the most part, is obsolete
Functions are written in Igor’s programming language. Like conventional procedural languages such as C 
or Pascal, Igor’s language includes:
•
Data storage elements (variables, strings, waves)
•
Assignment statements
•
Flow control (conditionals and loops)
•
Calls to built-in and external operations and functions
•
Ability to define and call subroutines
Igor programming is easier than conventional programming because it is much more interactive — you can 
write a routine and test it right away. It is designed for interactive use within Igor rather than for creating 
stand-alone programs.
Names in Programming
Functions, constants, variables, structures and all other programming entities have names. Names used in 
programming must follow the standard Igor naming conventions.
Names can consist of up to 255 characters. Only ASCII characters are allowed. The first character must be 
alphabetic while the remaining characters can include alphabetic and numeric characters and the under-
score character. Names in Igor are case insensitive.
Prior to Igor Pro 8.00, names used in programming were limited to 31 bytes. If you use long names, your 
procedures will require Igor Pro 8.00 or later.
The names of external operations and external functions are an exception. They are limited to 31 bytes.
Organizing Procedures
Procedures can be stored in the built-in Procedure window or in separate auxiliary procedure files. Chapter 
III-13, Procedure Windows, explains how to edit the Procedure window and how to create auxiliary pro-
cedure files.
