# AxisInfo

AxisInfo
V-43
AxisInfo 
AxisInfo(graphNameStr, axisNameStr)
The AxisInfo function returns a string containing a semicolon-separated list of information about the 
named axis in the named graph window or subwindow.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
axisNameStr is the name of the graph axis.
Details
The string contains groups of information. Each group is prefaced by a keyword and colon, and terminated 
with a semicolon. The keywords are:
The format of the RECREATION information is designed so that you can extract a keyword command from 
the keyword up to the “;”, prepend “ModifyGraph”, replace the “x” with the name of an actual axis and 
then Execute the resultant string as a command.
Examples
Make/O data=x;Display data
Print StringByKey("CWAVE", AxisInfo("","left"))
// Prints data
Keyword
Information Following Keyword
AXFLAG
Flag used to select the axis in any of the operations that display waves (Display, 
AppendMatrixContour, AppendImage, etc.).
AXTYPE
Axis type, such as “left”, “right”, “top”, or “bottom”.
CATWAVE 
Wave supplying the categories for the axis if this is a category plot.
CATWAVEDF
Full path to data folder containing category wave.
CTRACE
Name of the trace controlling the names axis. See Trace Names on page II-282 for 
background information. This field was added in Igor Pro 9.00.
CWAVE 
Name of wave controlling named axis.
CWAVEDF
Full path to data folder containing controlling wave.
FONT
Actual name of font used to draw axis tick labels.
FONTSIZE
Actual size of font used to draw axis tick labels, in points.
FONTSTYLE
Actual font style used to draw axis tick labels, in points. See ModifyGraph (axes) on 
page V-626 fstyle for the meaning of this integer value.
HOOK
Name set by ModifyFreeAxis with hook keyword.
ISCAT 
Truth that this is a category axis (used in a category plot).
ISTFREE
Truth that this is truly free axis (created via NewFreeAxis).
MASTERAXIS
Name set by ModifyFreeAxis with master keyword.
RECREATION
List of keyword commands as used by ModifyGraph command. The format of these 
keyword commands is:
keyword(x)=modifyParameters;
SETAXISCMD
Full SetAxis command.
SETAXISFLAGS
Flags that would be used with the SetAxis function to set the particular auto-scaling 
behavior that the axis uses. If the axis uses a manual axis range, SETAXISFLAGS is blank.
UNITS 
Axis units, if any.
