# GetUserData

GetUserData
V-316
Details
For all window types, GetSelection sets V_flag:
Here is a description of what GetSelection does for each window type:
Examples
In a new experiment, make a table named “Table0” with some columns, and select some combination of 
rows and columns:
Make wave0 = p
Make wave1 = p + 1
Edit wave0, wave1
ModifyTable selection = (3,0,8,1,3,0)
Now execute these commands in a procedure or in the command line:
GetSelection table, Table0, 3
Print V_flag, V_startRow, V_startCol, V_endRow, V_endCol
Print S_selection
This will print the following in the history area:
1 3 0 8 1
wave0.d;wave1.d; 
GetUserData 
GetUserData(winName, objID, userdataName)
The GetUserData function returns a string containing the user data for a window, subwindow graph trace 
or control. The return string will be empty if no user data exists.
V_flag
0: No selection when GetSelection was invoked.
1: There was a selection when GetSelection was invoked.
winType
bitFlags
Action
graph
Does nothing.
panel
Does nothing.
table
1
Sets V_startRow, V_startCol, V_endRow, and V_endCol based on the selected 
cells in the table. The top/left cell, not including the Point column, is (0, 0).
2
Sets S_selection to a semicolon-separated list of column names.
4
Sets S_dataFolder to a semicolon-separated list of data folders, one for each column.
layout
2
Sets S_selection to a semicolon separated list of selected objects in the layout 
layer (not any drawing layers). S_selection will be "" if no objects are selected.
notebook
1
Sets V_startParagraph, V_startPos, V_endParagraph, and V_endPos based on 
the selected text in the notebook.
2
Sets S_selection to the selected text.
4
Requires Igor Pro 8.05 or later.
Sets V_startParagraph and V_endParagraph to the left margin and right margin 
respectively of the current ruler in points relative to the ruler 0 position.
Sets V_startPos, and V_endPos to the left edge and right edge respectively of the 
selection in points relative to the ruler 0 position.
procedure 1
Sets V_startParagraph, V_startPos, V_endParagraph, V_endPos based on the 
selected text in the procedure window.
2
Sets S_selection to the selected text.
