# RemoveContour

RemoveContour
V-791
kwListStr is treated as if it ends with a listSepStr even if it doesn’t.
Searches for keySepStr and listSepStr are always case-sensitive. Searches for keyStr in kwListStr are usually 
case-insensitive. Setting the optional matchCase parameter to 1 makes the comparisons case sensitive.
In Igor6, only the first byte of keySepStr and listSepStr was used. In Igor7 and later, all bytes are used.
If listSepStr is specified, then keySepStr must also be specified. If matchCase is specified, keySepStr and 
listSepStr must be specified.
Examples
Print RemoveByKey("AKEY", "AKEY:123;BKEY:val") 
// prints "BKEY:val"
Print RemoveByKey("AKEY", "akey=1;BK=b;", "=")
// prints "BK=b;"
Print RemoveByKey("AKEY", "AKEY=1,BK=b,", "=", ",")
// prints "BK=b,"
Print RemoveByKey("ckey","CKEY:1;BKEY:2")
// prints "BKEY:2"
Print RemoveByKey("ckey","CKEY:1;BKEY:2",":",";",1)
// prints "CKEY:1;BKEY:2"
See Also
The NumberByKey, StringByKey, ReplaceNumberByKey, ReplaceStringByKey, ItemsInList, AxisInfo, 
IgorInfo, SetWindow, and TraceInfo functions.
RemoveContour 
RemoveContour [/W=winName] contourInstanceName [, contourInstanceName]…
The RemoveContour operation removes the traces, and releases memory associated with the contour plot 
of contourInstanceName in the target or named graph.
Parameters
contourInstanceName is usually simply the name of a wave. More precisely, contourInstanceName is a wave 
name, optionally followed by the # character and an instance number to identify which contour plot of a 
given wave is to be removed.
Flags
Details
If the axes used by the contour plot are no longer in use, they will also be removed.
A contour instance name in a string can be used with the $ operator to specify contourInstance.
Examples
Display;AppendMatrixContour zw
//new graph, contour of zw matrix
AppendMatrixContour zw
//two contours of zw
RemoveContour zw#1
//remove the second contour
See Also
The AppendMatrixContour and AppendXYZContour operations.
/ALL
Removes all contour plots from the graph. Any contour name parameters listed are 
ignored. /ALL was added in Igor Pro 9.00.
/W=winName
Removes contours from the named graph window or subwindow. When omitted, 
action will affect the active window or subwindow. This must be the first flag 
specified when used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
