# SetEnvironmentVariable

SetDrawLayer
V-844
SetDrawLayer 
SetDrawLayer [/K/W=winName] layerName
The SetDrawLayer operation makes all future drawing operations use the named layer.
Parameters
Valid layerNames for graphs:
Valid layerNames for page layouts:
Valid layerNames for control panels:
There are really only three layers for control panels. ProgFront is treated as an alias for ProgBack and 
UserFront is treated as an alias for UserBack.
Flags
Details
The Overlay layer is drawn above all else. It is not included when printing or exporting graphics and is 
provided for programmers who wish to add user-interface drawing elements without disturbing graphics 
drawing elements. Overlay was added in Igor Pro 7.00.
The back-to-front order of the layers is shown by the layer pop-up menu obtained by clicking the Layer icon 
in the drawing palette: 
. A checkmark indicates the current layer. Non-drawing layers are indicated 
with gray text.
Output Variables
SetDrawLayer sets S_Name to the name of the previously-selected drawing layer. You can use this to 
restore the active drawing layer after programmatic drawing.
See Also
Drawing Layers on page III-68 and the DrawAction operation.
SetEnvironmentVariable
SetEnvironmentVariable(varName, varValue)
The SetEnvironmentVariable function creates an environment variable in Igor's process and sets its value 
to varValue. If a variable named varName already exists, its value is set to varValue.
The function returns 0 if it succeeds or a nonzero value if it fails.
The SetEnvironmentVariable function was added in Igor Pro 7.00.
ProgBack
UserBack
ProgAxes
UserAxes
ProgFront
UserFront
Overlay
ProgBack
UserBack
ProgFront
UserFront
Overlay
ProgBack
UserBack
ProgFront
UserFront
Overlay
/K
Kills (erases) the given layer.
/W=winName
Sets the named window or subwindow for drawing. When omitted, action will affect 
the active window or subwindow. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
