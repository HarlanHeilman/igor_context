# Specialized Menu Item Definitions

Chapter IV-5 — User-Defined Menus
IV-132
Specialized Menu Item Definitions
A menu item string that contains certain special values adds a specialized menu such as a color menu.
Only one specialized menu item string is allowed in each menu or submenu, it must be the first item, and 
it must be the only item.
To retrieve the selected color, line style, etc., the execution text must be a procedure that calls the GetLas-
tUserMenuInfo operation (see page V-306). Here’s an example of a color submenu implementation:
Menu "Main", dynamic
"First Item", /Q, Print "First Item"
Submenu "Color"
CurrentColor(), /Q, SetSelectedColor() // Must be first submenu item
// No items allowed here
End
End
Function InitializeColors()
NVAR/Z red= root:red
if(!NVAR_Exists(red))
Variable/G root:red=65535, root:green=0, root:blue=1, root:alpha=65535
Menu Item String
Result
"*CHARACTER*
"Character menu, no character is initially selected, font is Geneva, 
font size is 12.
"*CHARACTER*(Arial)
Character menu shown using Arial font at default size.
"*CHARACTER*(Arial,36)
"Character menu of Arial font in 36 point size.
"*CHARACTER*(,36)
"Character menu of Geneva font in 36 point size.
"*CHARACTER*(Arial,36,m)
"Character menu of Arial font in 36 point size, initial character is m.
"*COLORTABLEPOP*
"Color table menu, initial table is Grays.
"*COLORTABLEPOP*(YellowHot)
"Color table menu, initial table is YellowHot. See CTabList on page 
V-118 for a list of color tables.
"*COLORTABLEPOP*(YellowHot,1)
"Color table menu with the colors drawn reversed.
"*COLORPOP*
"Color menu, initial color is black.
"*COLORPOP*(0,65535,0)
"Color menu, initial color is green.
"*COLORPOP*(0,65535,0,49151)
"Color menu, initial color is green at 75% opacity.
"*FONT*
"Font menu, no font is initially selected, does not include “default” as a 
font choice.
"*FONT*(Arial)
"Font menu, Arial is initially selected.
"*FONT*(Arial,default)
"Font menu with Arial initially selected and including “default” as a 
font choice.
"*LINESTYLEPOP*
"Line style menu, no line style is initially selected.
"*LINESTYLEPOP*(3)
"Line style menu, initial line style is style=3 (coarse dashed line).
"*MARKERPOP*
"Marker menu, no marker is initially selected.
"*MARKERPOP*(8)
"Marker menu, initial marker is 8 (empty circle).
"*PATTERNPOP*
"Pattern menu, no pattern is initially selected.
"*PATTERNPOP*(1)
"Pattern menu, initial pattern is 1 (SW-NE light diagonal).
