# Procedure Window Text Format Settings

Chapter III-13 — Procedure Windows
III-406
Three modes are available: points, spaces, and mixed. In points mode, you specify the default tab width in 
units of points. In the Document Settings dialog, you can enter this setting in inches, centimeters, or points, 
but it is always stored as points. Prior to Igor Pro 9.00, this was the only mode available.
In spaces mode, you specify the default tab width in units of spaces.
In mixed mode, you specify the default tab width for procedure windows controlled by proportional fonts 
in units of points and for procedure windows controlled by monospace fonts in units of spaces.
Mixed mode is recommended for compatibility with other text editors which typically set default tab 
widths in units of spaces.
In Igor Pro 9.00 and later, when you create a new procedure window, Igor inserts a DefaultTab pragma 
statement, like this:
#pragma DefaultTab = {3,20,4} // Sets default tab width in Igor Pro 9 or later
The DefaultTab pragma is explained in the next section.
The Default Tab Pragma For Procedure Files
In Igor Pro 9.00 and later, you can specify default tab settings by entering a pragma statement in the proce-
dure window, like this:
#pragma DefaultTab = {<mode>,<width in points>,<width in spaces>}
Older versions of Igor ignore this pragma.
The pragma is applied when the procedure file is compiled. It helps keep aligned comments aligned when 
you share the procedure file with another Igor user or if you change the font, text size, or magnification of 
the procedure window.
The DefaultTab pragma, if present, sets the default tab width parameters the same as if you set them in the 
Document Settings dialog. <mode> is 1 for points mode, 2 for spaces mode, and 3 for mixed mode. Specify-
ing the default tab width in spaces keeps comments in procedure files that you share with others aligned 
so long as the other users use a proportional font for procedure files. The recommended pragma is:
#pragma DefaultTab = {3,20,4} // Sets default tab width in Igor Pro 9 or later
When you create a new procedure window, Igor inserts this DefaultTab statement in the new window. It 
overrides your default tab width preferences and specifies mixed mode (3) with the default tab width for 
proportional fonts set to 20 points and the default tab width for monospace fonts set to 4 spaces. Most 
people use a monospace font for procedure windows, in which case the default tab width is 4 spaces. If you 
share the procedure file with other users, this pragma increases the likelihood that aligned comments will 
remain aligned.
You can remove or edit the automatically inserted DefaultTab pragma. However, we recommend that you 
leave it as is.
We also recommend that you manually add this pragma to existing procedure files. You will then need to 
re-align comments.
Procedure Window Text Format Settings
You can specify the font, text size, style and color using items in the Procedure menu. Since procedure 
windows are always plain text windows (as opposed to notebooks, which can be formatted text) these text 
settings are the same for all characters in the window.
Igor does not store text format settings for plain text files. When you open a procedure file, these settings 
are determined by preferences. You can capture preferences by choosing ProcedureCapture Procedure 
Prefs.
