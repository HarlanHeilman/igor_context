# SetBackground

SetBackground
V-836
SetBackground 
SetBackground numericExpression
The SetBackground operation sets numericExpression as the current unnamed background task.
SetBackground works only with the unnamed background task. New code should used named background 
tasks instead. See Background Tasks on page IV-319 for details.
The background task runs while Igor is not busy with other things. Normally, there won’t be a background task. 
The most common use for the background task is to monitor or drive a continuous data acquisition process.
Parameters
numericExpression is a single precision numeric expression that Igor executes when it isn’t doing anything 
else.
Details
numericExpression is expected to return one of three numeric values:
Usually the expression will be a call to a user-defined numeric function or external function to drive or 
monitor data acquisition. The expression should be designed to execute very quickly and it should not present 
a dialog to the user nor should it create or destroy windows. Generally, it should do nothing more than store 
data into waves or variables. You can use Igor’s dependency mechanism to perform more extensive tasks.
SetBackground designates the background task but you must use CtrlBackground to start it. You can also 
use KillBackground to stop it. You can not call SetBackground from the background function itself.
See Also
The BackgroundInfo, CtrlBackground, CtrlNamedBackground, KillBackground, and SetProcessSleep 
operations, and Background Tasks on page IV-319.
/E=z
/N=n
/R
Reverses the autoscaled axis (smaller values at the left for horizontal axes, at the top 
for vertical axes) when used with /A. Although it only has an effect for autoscale, it 
can be used with nonautoscale version of SetAxis so that the next time the Axis Range 
tab is used the “reverse axis” checkbox will already be set.
/W=winName
Sets axes in the named graph window or subwindow. When omitted, action will 
affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
No error reporting if named axis doesn’t exist in a style macro.
0:
Background task executed normally.
1:
Background task wants to stop.
2:
Background task encountered error and wants to stop.
Sets the treatment of zero when the axis is in autoscale mode.
z=0:
Normal mode where zero is not treated special.
z=1:
Forces the smaller end of the axis to be set to zero (autoscale from zero).
z=2:
Axis is symmetric about zero.
z=3:
If the data is unipolar (all positive or all negative), this behaves like /E=1 
(autoscale from zero). If the data is bipolar, it behaves like /E=0 (normal 
autoscaling).
Sets the algorithm for axis autoscaling.
n=0:
Normal mode; sets the axis limits equal to the data limits.
n=1:
Picks nice values for the axis limits.
n=2:
Picks nice values; also ensures that the data is inset from the axis ends.
