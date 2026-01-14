# ContourNameList

ContourNameList
V-86
The format of the RECREATION information is designed so that you can extract a keyword command from 
the keyword and colon up to the “;”, prepend “ModifyContour”, replace the “x” with the name of a 
contour plot (“data#1” for instance) and then Execute the resultant string as a command.
Examples
The following command lines create a very unlikely contour display. If you did this, you would most likely 
want to put each contour plot on different axes, and arrange the axes such that they don’t overlap. That 
would greatly complicate the example.
Make/O/N=(20,20) jack
Display;AppendMatrixContour jack
AppendMatrixContour/T/R jack
// Second instance of jack
This example accesses the contour information for the second contour plot of the wave “jack” (which has 
an instance number of 1) displayed in the top graph:
Print StringByKey("ZWAVE", ContourInfo("","jack",1))
// prints jack
See Also
The Execute and ModifyContour operations.
ContourNameList 
ContourNameList(graphNameStr, separatorStr)
The ContourNameList function returns a string containing a list of contours in the graph window or 
subwindow identified by graphNameStr.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
The parameter separatorStr should contain a single ASCII character such as “,” or “;” to separate the names.
A contour name is defined as the name of the wave containing the data from which a contour plot is 
calculated, with an optional #n suffix that distinguishes between two or more contour plots in the same graph 
window that have the same wave name. Since the contour name has to be parsed, it is quoted if necessary.
Examples
The following command lines create a very unlikely contour display. If you did this, you would most likely 
want to put each contour plot on different axes, and arrange the axes such that they don’t overlap. That 
would greatly complicate the example.
Make/O/N=(20,20) jack,'jack # 2';
Display;AppendMatrixContour jack
AppendMatrixContour/T/R jack
AppendMatrixContour 'jack # 2'
AppendMatrixContour/T/R 'jack # 2'
Print ContourNameList("",";")
prints jack;jack#1;'jack # 2';'jack # 2'#1;
XAXIS
X axis name.
XWAVE
X wave name if any, else blank.
XWAVEDF
Full path to the data folder containing the X wave or blank if there is no X wave.
YAXIS
Y axis name.
YWAVE
Y wave name if any, else blank.
YWAVEDF
Full path to the data folder containing the Y wave or blank if there is no Y wave.
ZWAVE
Name of wave containing Z data from which the contour plot was calculated.
ZWAVEDF
Full path to the data folder containing the Z data wave.
Keyword
Information Following Keyword
