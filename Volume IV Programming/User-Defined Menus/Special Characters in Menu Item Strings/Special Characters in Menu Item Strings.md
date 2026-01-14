# Special Characters in Menu Item Strings

Chapter IV-5 — User-Defined Menus
IV-133
endif
End
Function/S CurrentColor()
InitializeColors()
NVAR red = root:red
NVAR green = root:green
NVAR blue = root:blue
NVAR alpha = root:alpha
String menuText
sprintf menuText, "*COLORPOP*(%d,%d,%d,%d)", red, green, blue, alpha
return menuText
End
Function SetSelectedColor()
GetLastUserMenuInfo// Sets V_Red, V_Green, V_Blue, V_Alpha, S_value, V_value
NVAR red = root:red
NVAR green = root:green
NVAR blue = root:blue
NVAR alpha = root:alpha
red = V_Red
green = V_Green
blue = V_Blue
alpha = V_Alpha
Make/O/N=(2,2,4) root:colorSpot
Wave colorSpot = root:colorSpot
colorSpot[][][0] = V_Red
colorSpot[][][1] = V_Green
colorSpot[][][2] = V_Blue
colorSpot[][][3] = V_Alpha
CheckDisplayed/A colorSpot
if (V_Flag == 0)
NewImage colorSpot
endif
End
Special Characters in Menu Item Strings
You can control some aspects of a menu item using special characters. These special characters are based 
on the behavior of the Macintosh menu manager and are only partially supported on Windows (see Special 
Menu Characters on Windows on page IV-134). They affect user-defined menus in the main menu bar. On 
Macintosh, but not on Windows, they also affect user-defined pop-up menus in control panels, graphs and 
simple input dialogs.
By default, special character interpretation is enabled in user-defined menu bar menus and is disabled in 
user-defined control panel, graph and simple input dialog pop-up menus. This is almost always what you 
would want. In some cases, you might want to override the default behavior. This is discussed under 
Enabling and Disabling Special Character Interpretation on page IV-135.
