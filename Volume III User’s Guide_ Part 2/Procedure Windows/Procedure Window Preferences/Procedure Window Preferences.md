# Procedure Window Preferences

Chapter III-13 — Procedure Windows
III-407
Syntax Coloring
Procedure windows and the command window colorize comments, literal strings, flow control, and other 
syntax elements. Colors of various elements can be adjusted in two ways.
The first is from the Miscellaneous Settings dialog. Select the Text Editing category and then select the Color 
tab.
The second is by executing the following SetIgorOption colorize commands::
Values for r, g, b, and the optional alpha range from 0 to 65535. Alpha defaults to 65535 (opaque).
Changes to syntax coloring settings, made via the dialog or via SetIgorOption, are saved to preferences and 
used for future sessions.
Procedure Window Preferences
The procedure window preferences affect the creation of new procedure windows. This includes the cre-
ation of auxiliary procedure windows and the initialization of the built-in procedure window that occurs 
when you create a new experiment.
To set procedure preferences, set the attributes of any procedure window and then choose Proce-
dureCapture Procedure Prefs.
To determine the current preference settings, you must create a new procedure window and examine its settings.
Preferences are stored in the Igor Preferences file. See Chapter III-18, Preferences, for further information 
on preferences.
Command
Effect
SetIgorOption colorize,doColorize=<1 or 0>
Turn all colorize on or off
SetIgorOption colorize,OpsColorized=<1 or 0>
Turn operation keyword colorization on 
or off
SetIgorOption colorize,BIFuncsColorized=<1 or 0>
Turn function keyword colorization on 
or off
SetIgorOption colorize,keywordColor=(r,g,b[,a])
Color for language keywords
SetIgorOption colorize,commentColor=(r,g,b[,a])
Color for comments
SetIgorOption colorize,stringColor=(r,g,b[,a])
Color for strings
SetIgorOption colorize,operationColor=(r,g,b[,a])
Color for operation keywords
SetIgorOption colorize,functionColor=(r,g,b[,a])
Color for built-in function keywords
SetIgorOption colorize,poundColor=(r,g,b[,a])
Color for #keywords such as #pragma
SetIgorOption colorize,UserFuncsColorized=1
Turn colorizing on for user functions
SetIgorOption colorize,userFunctionColor=(r,g,b[,a]) Color for user-defined functions
SetIgorOption colorize,SpecialFuncsColorized=1
Turn colorizing on for special 
operations (MatrixOP and APMath)
SetIgorOption colorize,specialFunctionColor=(r,g,b[,a])
Color for special operations (MatrixOP 
and APMath)
