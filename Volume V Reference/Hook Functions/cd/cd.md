# cd

cabs
V-58
cabs 
cabs(z)
The cabs function returns the real-valued absolute value of complex number z.
See Also
The magsqr function.
CameraWindow 
CameraWindow
CameraWindow is a procedure subtype keyword that identifies a macro as being a camera window 
recreation macro. It is automatically used when Igor creates a window recreation macro for a camera 
window. See Procedure Subtypes on page IV-204 and Saving and Recreating Graphs on page II-350 for 
details.
CaptureHistory 
CaptureHistory(refnum, stopCapturing)
The CaptureHistory function returns a string containing text from the history area of the command window 
since a matching call to the CaptureHistoryStart function.
Parameters
refnum is a number returned from a call to CaptureHistoryStart. It identifies the starting point in the history 
for the returned string.
Set stopCapturing to nonzero to indicate that no more history should be captured for the given refnum. 
Subsequent calls to CaptureHistory with the same refnum will result in an error.
Set stopCapturing to zero to retrieve history text captured so far. Further calls to CaptureHistory with the 
same reference number will return this text, plus any additional history text added subsequently.
Details
You can have multiple captures active at one time. Each call to CaptureHistoryStart will return a unique 
reference number identifying a start point in the history. The capture corresponding to each reference 
number can be terminated at any time, regardless of the order of the CaptureHistoryStart calls.
CaptureHistoryStart 
CaptureHistoryStart()
The CaptureHistoryStart function returns a reference number to identify a starting point in the history area 
text. Subsequently, the CaptureHistory function can be used to retrieve captured history text. See 
CaptureHistory for details.
catch 
catch
The catch flow control keyword marks the beginning of code in a try-catch-endtry flow control construct 
for handling any abort conditions.
See Also
The try-catch-endtry flow control statement for details.
cd 
cd dataFolderSpec
The cd operation sets the current data folder to the specified data folder. It is identical to the longer-named 
SetDataFolder operation.
cd is named after the UNIX "change directory" command.
See Also
SetDataFolder, pwd, Dir, Data Folders on page II-107
