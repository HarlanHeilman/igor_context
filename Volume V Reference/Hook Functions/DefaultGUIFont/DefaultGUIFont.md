# DefaultGUIFont

DefaultGUIFont
V-149
DefaultGUIFont 
DefaultGUIFont [/W=winName /Mac/Win] group = {fNameStr,fSize,fStyle} [,…]
The DefaultGUIFont operation changes the default font for user-defined controls and other Graphical User 
Interface elements.
Parameters
fNameStr is the name of a font, fSize is the font size, and fStyle is a bitwise parameter with each bit controlling 
one aspect of the font style. See Button for details about these parameters.
group may be one of the following:
Flags
Details
Although designed to be used before controls are created, calling DefaultGUIFont will update all affected 
windows with controls. This makes it easy to experiment with fonts. Keep in mind that fonts can cause 
compatibility problems when moving between machines or platforms.
The /Mac and /Win flags indicate the platform on which the fonts are to be used. If the current platform is 
not the one specified then the settings are not used but are remembered for use in window recreation 
macros or experiment recreation. This allows a user to create an experiment that will use different fonts 
depending on the current platform.
If the /W flag is used then the font settings apply only to the specified window (Graph or Panel.) If the /W flag is 
not used, then the settings are global to the experiment. Tip: Use /W=# to refer to the current active subwindow.
fNameStr may be an empty string ("") to clear a group. Setting the font name to "_IgorSmall", 
"_IgorMedium", or "_IgorLarge" will use Igor’s own defaults. The standard defaults for controls are the 
equivalent to setting all to "_IgorSmall", tabcontrol to "_IgorMedium", and button to "_IgorLarge". Use 
a fSize of zero to also get the standard default for size. On Windows, the three default fonts and sizes are all the 
same.
Although designed to be used before controls are created, calling DefaultGUIFont will update all affected 
windows with controls. This makes it easy to experiment with fonts. Keep in mind that fonts can cause 
compatibility problems when moving between machines or platforms.
all
All controls
button
Button and default CustomControl
checkbox
CheckBox controls
tabcontrol
TabControl controls
popup
Affects the icon (not the title) of a PopupMenu control. The text in the popped state is 
set by the system and can not be changed. The title of a PopupMenu is affected by the 
all group but the icon text is not.
panel
Draw text in a panel.
graph
Overlay graphs. Size is used only if ModifyGraph gfSize= -1; style is not used.
table
Overlay tables.
/Mac
Changes control fonts only on Macintosh, and it affects the experiment whenever it is 
used on Macintosh.
/W=winName
Affects the named window or subwindow. When omitted, sets an experiment-wide 
default.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Win
Changes control fonts only on Windows, and it affects the experiment whenever it is 
used on Windows.
