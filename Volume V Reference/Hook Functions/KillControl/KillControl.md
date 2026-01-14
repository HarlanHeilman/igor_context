# KillControl

JulianToDate
V-468
Example: 3D Joint Histogram
Make/O/N=(1000) xwave=gnoise(10), ywave=gnoise(5), zwave=enoise(4)
JointHistogram/BINS={15,15,20,0} xwave,ywave,zwave
NewImage M_JointHistogram
ModifyImage M_JointHistogram plane=10
See Also
Histogram, ImageHistogram
JulianToDate 
JulianToDate(julianDay, format)
The JulianToDate function returns a date string containing the day, month, and year. The input julianDay 
is truncated to an integer.
Parameters
julianDay is the Julian day to be converted.
format specifies the format of the returned date string.
See Also
The dateToJulian function.
For more information about the Julian calendar see: 
<http://www.tondering.dk/claus/calendar.html>.
KillBackground 
KillBackground
The KillBackground operation kills the unnamed background task.
KillBackground works only with the unnamed background task. New code should used named background 
tasks instead. See Background Tasks on page IV-319 for details.
Details
You can not call KillBackground from within the background function itself. However, if you return 1 from 
the background function, instead of the normal 0, Igor will terminate the background task.
See Also
The BackgroundInfo, CtrlBackground, CtrlNamedBackground, SetBackground, and SetProcessSleep 
operations; and Background Tasks on page IV-319.
KillControl 
KillControl [/W=winName] controlName
The KillControl operation kills the named control in the top or specified graph or panel window or subwindow.
If the named control does not exist, KillControl does not complain.
format
Date String
0
mm/dd/year
1
dd/mm/year
2
Tuesday November 15, 2002
3
year mm dd
4
year/mm/dd
