# SetIgorOption PanelResolution

Chapter III-15 — Platform-Related Issues
III-456
The coordinates specify the location of the content region, in Macintosh terminology, or the client area, in 
Windows terminology, of the window. They do not specify the location of the window frame or border.
On Macintosh, a point is always interpreted to be one pixel except on Retina displays where it is two.
On Windows, the correspondence between a point and a pixel can be controlled by the user using system 
settings. Since Igor stores window positions in units of points, if the user changes the number of pixels per 
point, the size of Igor windows in pixels will change.
Control Panel Resolution on Windows
In the past, by default, Windows screens ran at 96 DPI (dots-per-inch) resolution. In recent years, high-res-
olution displays, also called UltraHD displays and 4K displays, have become common.
In Igor6 and before, commands that create control panels and controls use screen pixel units to specify sizes 
and coordinates. This results in tiny controls on high-resolution displays.
In Igor7 and later, control panels and control sizes and coordinates can be specified in units of points instead 
of pixels. Since a point is a resolution-independent unit, this results in controls that are the same logical size 
regardless of the physical resolution of the screen.
By default, panels are drawn using pixels if the screen resolution is 96 DPI but using points for higher-DPI 
settings. This gives backward compatibility on standard screens and reasonably-sized controls on high-res-
olution screens.
You can change the way control panel coordinates and control sizes are interpreted using two different 
methods:
1.
Control Panel Expansion (Igor Pro 9.00 and later)
2.
You can set control panel expansion using the Expansion submenu in the Panel menu or using the 
Expansion setting in the Panel section of the Miscellaneous Settings dialog. If you are using Igor Pro 
9.00 or later, this method is preferred.
See the Control Panel Expansion on page III-443 for further discussion.
3.
SetIgorOption with the PanelResolution keyword.
This method requires executing commands as described in the next section. It can make panels larger 
than normal but not smaller. It is not recommended in Igor Pro 9.00 or later.
See also Control Panel Units on page III-444.
SetIgorOption PanelResolution
In Igor Pro 9.00 and later we recommend that you use Control Panel Expansion instead of SetIgorOption 
PanelResolution.
You set this option by executing a command of the form:
SetIgorOption PanelResolution = <resolution>

Chapter III-15 — Platform-Related Issues
III-457
The <resolution> parameter controls how Igor interprets coordinates and sizes in control panels. It must be 
one of these values:
This setting is not remembered across Igor sessions.
The resolution for a panel is set when the panel is created so changing the panel resolution does not affect 
already-existing control panels.
Programmers are encouraged to test their control panels at various resolution settings.
For the most part, Igor6 control panels will work fine in Igor7 and later. However, if you have panels that 
rearrange their components depending on the window size, you probably have some code that uses the 
ratio of 72 and ScreenResolution. For example, here is a snippet from the WaveMetrics procedure Axis 
Slider.ipf:
case "Resize":
GetWindow kwTopWin,gsize
// Returns points
// Controls are positioned in pixels
grfName= WinName(0, 1)
V_left *= ScreenResolution / 72
// Convert points to pixels
V_right *= ScreenResolution / 72
Slider WMAxSlSl,size={V_right-V_left-kSliderLMargin,16}
break
To make this work properly at variable resolution, we use the PanelResolution function, added in Igor Pro 
7.00:
case "Resize":
GetWindow kwTopWin,gsize
// Returns points
grfName= WinName(0, 1)
V_left *= ScreenResolution / PanelResolution(grfName)
// Variable
V_right *= ScreenResolution / PanelResolution(grfName)
// resolution
Slider WMAxSlSl,size={V_right-V_left-kSliderLMargin,16}
break
The PanelResolution function, when called with "" as the parameter returns the current global default 
setting for panel resolution in pixels per inch or, if in Igor6 mode, 72. When called with the name of a control 
panel or graph, it returns the current resolution of the specified window in pixels per inch.
If you want your procedures to work with Igor6, you should insert this into each procedure file that needs 
the PanelResolution function:
#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)
// For compatibility with Igor7
String wName
return 72
End
#endif
To find other examples, use the Help Browser to search procedure files for PanelResolution.
See also Control Panel Units on page III-444.
0:
Coordinates and sizes are treated as points regardless of the screen resolution.
1:
Coordinates and sizes are treated as pixels if the screen resolution is 96 DPI, points otherwise. 
This is the default setting in effect when Igor starts.
72:
Coordinates and sizes are treated as pixels regardless of the screen resolution (Igor6 mode).
>96
If <resolution> is greater than 96, panel coordinates and sizes are treated as points regardless 
of the screen resolution. Larger values make larger panels and controls. For example on a 96 
DPI screen SetIgorOption PanelResolution = 192 makes them twice as large as 
normal.
