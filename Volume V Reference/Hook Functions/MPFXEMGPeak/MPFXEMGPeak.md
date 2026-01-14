# MPFXEMGPeak

MPFXEMGPeak
V-667
Details
Note that neither winName nor procedureTitleAsName is a string but is the actual window name or procedure 
window title. If the procedure window’s title (procedure windows don’t have names) has a space in it, use 
$ and quotes:
MoveWindow/P=$"Log Histogram" 0,0,600,400
If /W, /F, /C, and /P are omitted, MoveWindow moves the target window.
The coordinates are in points if neither /I nor /M is used.
In Igor Pro 7.00 or later, to move the window without changing its size, pass -1 for both right and bottom.
You can use the MoveWindow operation to minimize, restore, or maximize a window by specifying 0, 1, or 
2 for all of the coordinates, respectively, as follows:
MoveWindow 0, 0, 0, 0
// Minimize target window.
MoveWindow 1, 1, 1, 1
// Restore target window.
MoveWindow 2, 2, 2, 2
// Maximize target window.
On Macintosh, “maximize” means to move and resize the window so that it fills the screen. 
“Minimize”means to minimize to the dock.
If the window size has been constrained by SetWindow sizeLimit, those limits are silently applied to 
the size set by MoveWindow.
See Also
The MoveSubwindow and DoWindow operations.
MPFXEMGPeak
MPFXEMGPeak(cw, yw, xw)
The MPFXEMGPeak function implements a single exponentially modified Gaussian peak with no Y offset 
in the format of an all-at-once fitting function. The exponentially modified Gaussian peak shape is a 
convolution of an exponential and a Gaussian peak.
/I
Coordinates are in inches.
/M
Coordinates are in centimeters.
/P=procedureTitleAsName
Moves the specified procedure window instead of the target window.
/W=winName
Moves the named window.
