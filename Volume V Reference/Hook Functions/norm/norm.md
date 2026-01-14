# norm

norm
V-692
Details
The X and Z axes are always at the bottom and left, whereas the Y axis runs at a default 45 degrees along 
the right-hand side. The angle and length of the Y axis can be changed using the ModifyWaterfall operation. 
Other features of the graph can be changed using normal graph operations.
Each column from matrixWave is plotted in, and clipped by, a rectangle defined by the X and Z axes with 
the rectangle displaced along the angled Y axis as a function of the Y value.
Except when hidden lines are active, the traces are drawn from back to front.
To modify certain properties of a waterfall plot, you need to use the ModifyWaterfall operation. For other 
properties, use the usual axis and trace dialogs.
See Also
Waterfall Plots on page II-326.
The ModifyWaterfall and ModifyGraph operations.
norm 
norm(srcWave)
The norm function evaluate the norm of srcWave. It returns:
/K=k
/M
Sets window coordinates to centimeters.
/N=name
Requests that the created waterfall plot window have this name, if it is not in use. If it 
is in use, then name0, name1, etc. are tried until an unused window name is found. In 
a function or macro, S_name is set to the chosen name.
/PG=(gLeft, gTop, gRight, gBottom)
Specifies the inner plot rectangle of the waterfall plot subwindow inside its host 
window.
The standard plot rectangle guide names are PL, PR, PT, and PB, for the left, right, top, 
and bottom plot rectangle guides, respectively, or user-defined guide names as 
defined by the host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/W=(left,top,right,bottom)
Specifies window size. Coordinates are in points unless /I or /M is specified before /W.
When used with the /HOST flag, the specified location coordinates of the sides can 
have one of two possible meanings:
When all values are less than 1, coordinates are assumed to be fractional relative to 
the host frame size.
When any value is greater than 1, coordinates are taken to be fixed locations measured 
in points, or Control Panel Units for control panel hosts, relative to the top left corner 
of the host frame.
When the subwindow position is fully specified using guides (using the /HOST, /FG, 
or /PG flags), the /W flag may still be used although it is not needed.
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.
