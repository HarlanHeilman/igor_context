# vcsr

vcsr
V-1067
matchStr may begin with the ! character to return items that do not match the rest of matchStr. For example:
The ! character is considered to be a normal character if it appears anywhere else, but there is no practical 
use for it except as the first character of matchStr.
variableTypeCode is used to further qualify the variable. The variable name goes into the output string only 
if it passes the match test and its type is compatible with variableTypeCode. variableTypeCode is any one of:
dfr is an optional data folder reference: a data folder name, an absolute or relative data folder path, or a 
reference returned by, for example, GetDataFolderDFR.
Examples
See Also
See the StringList and WaveList functions.
See Setting Bit Parameters on page IV-12 for details about bit settings.
vcsr 
vcsr(cursorName [, graphNameStr])
The vcsr function returns the Y (vertical) value of the point which the specified cursor (A through J) is 
attached to in the top (or named) graph.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
The result is computed from the coordinate system of the graph’s Y axis. The Y axis used is the one used to 
display the wave on which the cursor is placed.
See Also
The hcsr, pcsr, qcsr, xcsr, and zcsr functions.
Programming With Cursors on page II-321.
"xyz"
Matches variable name xyz only.
"*xyz"
Matches variable names which end with xyz.
"xyz*"
Matches variable names which begin with xyz.
"*xyz*"
Matches variable names which contain xyz.
"abc*xyz"
Matches variable names which begin with abc and end with xyz.
"!*xyz"
Matches variable names which do not end with xyz.
2:
System variables (K0, K1 . . .)
4:
Scalar variables
5:
Complex variables
VariableList("*",";",4)
Returns a list of all scalar variables.
VariableList("!V_*", ";",5)
Returns a list of all complex variables except those 
whose names begin with “V_”.
VariableList("*",";",4,root:MyData) Returns a list of all scalar variables in the root:MyData 
data folder.
