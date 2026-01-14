# NewFreeWave

NewFreeDataFolder
V-680
Flags
Details
A truly free axis does not use any scaling or units information from any associated waves (which need not 
exist.) You can set the properties of a free axis using SetAxis or ModifyFreeAxis.
Example
Copy this function to your Procedure window and compile:
Function axhook(s)
STRUCT WMAxisHookStruct &s
Variable t= s.max
s.max= s.min
s.min= t
return 0
End
Now execute this code on the Command line:
Make jack=x
Display jack
NewFreeAxis fred
ModifyFreeAxis fred, master=left, hook=axhook
See Also
The SetAxis, KillFreeAxis, and ModifyFreeAxis operations.
NewFreeDataFolder 
NewFreeDataFolder()
The NewFreeDataFolder function creates a free data folder and then returns its data folder reference.
Recommended for advanced programmers only.
Details
Free data folders are those that are not a part of the normal data folder hierarchy and can not be located by 
name. 
See Also
Chapter II-8, Data Folders, Free Data Folders on page IV-96 and Data Folder References on page IV-78.
NewFreeWave 
NewFreeWave(type, numPoints [,nameStr])
The NewFreeWave function creates a free 1D wave of the given type and number of points and then returns 
its wave reference.
Recommended for advanced programmers only.
Details
By default, NewFreeWave creates a free wave named '_free_'. You can specify another name via the 
optional nameStr input. The ability to specify the name of a free wave was added in Igor Pro 9.00 as a 
debugging aid - see Free Wave Names on page IV-95 and Wave Tracking on page IV-207 for details.
You can also create free waves using Make/FREE and Duplicate/FREE. These are preferable for creating 
multidimensional free waves and also fine for general use.
/L/R/B/T
Specifies whether to attach the free axis to the Left, Right, Bottom, or Top plot edge, 
respectively. The Left edge is used by default.
/O
Replaces axisName if it already exists, which means any existing axis is marked as truly 
free.
/W=winName
Draws in the named graph window. winName may also be the name of a subwindow. 
winName must not conflict with other axis names except when using the /O flag. If /W 
is omitted, it creates a new axis in the active graph window or subwindow.
