# DefaultTab

DefaultTab
V-150
To read back settings, use DefaultGUIFont [/W=winName/Mac/Win/OVR] group to return the 
current font name in S_name, the size in V_value, and the style in V_flag. With /OVR or if /Mac or /Win is 
not current, it returns only override values. Otherwise, values include Igor built-in defaults. If S_name is 
zero length, values are not defined.
Default Fonts and Sizes
The standard defaults for controls is the equivalent to setting all to "_IgorSmall", tabcontrol to 
"_IgorMedium", and button to "_IgorLarge". Use a fSize of zero to also get the standard default for size. 
On Windows, the three default fonts and sizes are all the same.
Examples
DefaultGUIFont/Mac all={"Zapf Chancery",12,0},panel={"geneva",12,3}
DefaultGUIFont/Win all={"Century Gothic",12,0},panel={"arial",12,3}
NewPanel
Button b0
DrawText 40,43,"Some text"
See Also
The DefaultGUIControls operation. Chapter III-14, Controls and Control Panels, for details about control 
panels and controls.
Window Position Coordinates on page III-455 and Points Versus Pixels on page III-455 for explanations 
of how font sizes in panels are interpreted for various screen resolutions.
Demos
Choose FileExample ExperimentsFeature Demos 2All Controls Demo.
DefaultTab
#pragma DefaultTab={mode,widthInPoints,widthInSpaces}
The DefaultTab pragma allows you to specify default tab settings by entering a pragma statement in a 
procedure file. Specifying tab widths in spaces rather than points provides better results if the procedure 
window font or font size is changed.
The DefaultTab pragma was added in Igor Pro 9.00. It is ignored by earlier versions of Igor.
See Procedure Window Default Tabs on page III-405 for details.
Macintosh
Windows
Control
Font
Font Size
Font
Font Size
Button
Lucida Grande
13
MS Shell Dlg*
* MS Shell Dlg is a “virtual font name” which maps to Tahoma on Windows XP, to 
MS Sans Serif on Windows 7, and to Segoe UI on Windows 8 and Windows 10.
12
Checkbox
Geneva
9
MS Shell Dlg
12
GroupBox
Geneva
9
MS Shell Dlg
12
ListBox
Geneva
9
MS Shell Dlg
12
PopupMenu†
† On Macintosh, the PopupMenu font is Geneva 9 for the title and Lucida Grande 12 
for the popup menu itself. On Windows, both fonts are MS Shell Dlg 12.
Geneva
9
MS Shell Dlg
12
SetVariable
Geneva
9
MS Shell Dlg
12
Slider
Geneva
9
MS Shell Dlg
12
TabControl
Geneva
12
MS Shell Dlg
12
TitleBox
Geneva
9
MS Shell Dlg
12
ValDisplay
Geneva
9
MS Shell Dlg
12
