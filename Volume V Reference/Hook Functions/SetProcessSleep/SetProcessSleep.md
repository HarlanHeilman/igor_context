# SetProcessSleep

SetMarquee
V-852
SetIgorOption IndependentModuleDev=?; Print V_Flag
// Query
SetIgorOption IndependentModuleDev=1
// Set
Most SetIgorOption keywords are obscure and rarely of use. Here are the some of the more commonly-used 
SetIgorOption keywords:
It is rarely necessary, but you can find the more obscure applications using HelpSearch Igor Files to 
search for "SetIgorOption".
SetMarquee 
SetMarquee [ /HAX=hAxisName /VAX=vAxisName /W=winName] left, top, right, bottom
The SetMarquee operation creates a marquee on the target graph or layout window or the specified 
window or subwindow.
Parameters
The left, top, right, and bottom coordinates are in units of points unless you specify /HAX or /VAX in which 
case they are in axis units. Axis units are allowed for graphs only, not for layouts.
If the coordinates are all 0, the marquee, if it exists, is killed.
Flags
Details
Igor stores marquee coordinates internally as integers in units of points. If you specify coordinates in axis 
units, there will be some roundoff error when Igor converts to integer points. This results in a small 
discrepancy between the coordinates you set using /HAX or /VAX and the coordinates returned by 
GetMarquee.
See Also
GetMarquee
SetProcessSleep 
SetProcessSleep sleepTicks
The SetProcessSleep operation is obsolete and does nothing as of Igor Pro 7.00. It is documented here in case you come 
across it in old Igor procedure code. Do not use it in new code.
The SetProcessSleep operation determines how much time Igor will give to background tasks or other 
Macintosh applications executing in the background. This operation does nothing on Windows.
Parameters
sleepTicks is the amount of time given to background tasks in sixtieths of a second. sleepTicks values between 
0 and 60 are valid.
IndependentModuleDev
See SetIgorOption IndependentModuleDev=1 on page IV-239
PoundDefine 
See Conditional Compilation on page IV-108
GraphicsTechnology 
See Graphics Technology on page III-506
PanelResolution 
See SetIgorOption PanelResolution on page III-456
DisableThreadSafe 
See Debugging ThreadSafe Code on page IV-225
/HAX=hAxisName
Specifies that the left and right parameters are in units of the axis named by 
hAxisName. The /HAX flag was added in Igor Pro 9.00.
/VAX=vAxisName
Specifies that the top and bottom parameters are in units of the axis named by 
vAxisName. The /VAX flag was added in Igor Pro 9.00.
/W=winName
Specifies the named window or subwindow. When omitted, action will affect the 
active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
