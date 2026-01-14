# GetDefaultFontStyle

GetDefaultFont
V-297
See Also
Chapter II-8, Data Folders and Data Folder References on page IV-78.
The SetDataFolder operation.
GetDefaultFont 
GetDefaultFont(winName)
The GetDefaultFont function returns a string containing the name of the default font for the named window 
or subwindow.
Parameters
If winName is null (that is, "") returns the default font for the experiment.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
Only graph windows and the experiment as a whole have default fonts. If winName is the name of a window 
other than a graph (e.g., a layout), or if winName is not the name of any window, GetDefaultFont returns 
the experiment default font.
In user-defined functions, font names are usually evaluated at compile time. To use the output of 
GetDefaultFont in a user-defined function, you will usually need to build a command as a string expression 
and execute it with the Execute operation.
Examples
String fontName = GetDefaultFont("Graph0")
String command= "SetDrawEnv fname=\"" + fontName + "\", save"
Execute command
See Also
The GetDefaultFontSize, GetDefaultFontStyle, FontSizeHeight, and FontSizeStringWidth functions.
GetDefaultFontSize 
GetDefaultFontSize(graphNameStr, axisNameStr)
The GetDefaultFontSize function returns the default font size of the graph or of the graph’s axis (in points) 
in the specified window or subwindow.
Details
If graphNameStr is "" the top graph is examined.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
If axisNameStr is "", the font size of the default font for the graph is returned.
If named axis exists, the default font size for the named axis in the graph is returned.
If named axis does not exist, NaN is returned.
See Also
The GetDefaultFont, GetDefaultFontStyle, FontSizeHeight, and FontSizeStringWidth functions.
GetDefaultFontStyle 
GetDefaultFontStyle(graphNameStr, axisNameStr)
The GetDefaultFontStyle function returns the default font style of the graph or of the graph’s axis in the 
specified window or subwindow.
Details
If graphNameStr is "" the top graph is examined.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
