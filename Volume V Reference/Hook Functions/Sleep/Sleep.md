# Sleep

Silent
V-871
Silent 
Silent num
The Silent operation is largely obsolete. Only very obscure uses remain and most users can ignore this 
operation.
Prior to Igor Pro 7, Silent was used to enable or disable the display of macro commands in the command 
line as they were executed. It was also used to enable compatibility modes for very old experiments.
Parameters
If num is 2, commands issued by AppleEvents or ActiveX Automation are not shown in the history are of 
the command window. Use 3 to re-enable.
If num is 100, 101 or 102, all procedures are recompiled. For 102, the time to recompile is displayed in the 
history.
sin 
sin(angle)
The sin function returns the sine of angle which is in radians.
In complex expressions, angle is complex, and sin(angle) returns a complex value:
See Also
asin, cos, tan, sec, csc, cot
sinc 
sinc(num)
The sinc function returns sin(num)/num. The sinc function returns 1.0 when num is zero. num must be real.
sinh 
sinh(num)
The sinh function returns the hyperbolic sine of num:
In complex expressions, num is complex, and sinh(num) returns a complex value.
See Also
cosh, tanh, coth
Sleep 
Sleep [flags] timeSpec
The Sleep operation puts Igor to sleep for a while. After the while is up, Igor continues execution.
You could use Sleep, for example, to give an instrument time to perform an action or to allow a user to 
admire a graph before proceeding.
More advanced programmers may prefer to use a background task as an alternative. See Background 
Tasks on page IV-319.
Parameters
The format of timeSpec depends on which flags, if any, are present.
If no flags are present, then timeSpec is in hh:mm:ss format and specifies the number of elapsed hours, 
minutes and seconds to sleep.
sin(x + iy) = sin(x)cosh(y) + icos(x)sinh(y).
sinh(x) = ex  ex
2
.

Sleep
V-872
Flags
Details
The Sleep operation does not let the user choose menus, move cursors, run procedures, draw in graphs, or 
do any other interactive task.
Normally timeSpec specifies an amount of elapsed time. If the /A flag is present, then timeSpec is an absolute 
time when sleep is to end. If the specified absolute time has already passed, no sleep occurs unless you also 
use /W, which makes it wait until tomorrow.
If you specify time in hh:mm:ss format, you can also specify the time indirectly through a string variable. 
See the examples.
/A
timeSpec is an absolute time in 24 hour format (e.g., 16:00:00).
/A/W
Wait until tomorrow if absolute time has passed.
/B
Stop sleeping if the user clicks the mouse button.
The /B flag is ignored if you use the /PROG flag.
/C=cursor
/M=message
If you use /C=6 or /PROG, the progress dialog displays message above the progress 
bar. By default the message reads "Sleeping".
/PROG={cancelButtonTitleStr, continueButtonTitleStr, abortMode}
Displays a progress dialog with user-settable titles for the Cancel and Continue 
buttons.
If you pass "" for cancelButtonTitleStr, the Cancel button is hidden. If you pass "" for 
continueButtonTitleStr, the Continue button is hidden. It is an error to pass "" for both 
buttons.
If abortMode is 0, the User Abort Key Combinations and the Cancel button abort any 
running procedure code. If it is 1, the user abort key combinations and the Cancel 
button terminate the Sleep operation but user procedure code continues to run.
The /B and /Q flags are ignored if you use the /PROG flag.
See Displaying a Progress Dialog below for further information.
/Q
Continue executing the procedure containing the Sleep operation even if the User 
Abort Key Combinations were pressed.
The /Q flag is ignored if you use the /PROG flag.
/S
timeSpec is a numeric expression in seconds.
/T
timeSpec is a numeric expression in ticks (about 1/60 of a second).
Controls what kind of cursor to display during sleep.
cursor values 3 through 6 require Igor Pro 7.00 or later.
cursor value 7 requires Igor Pro 9.00 or later.
Under rare circumstances, cursors 0, 3, 4, and 5 may cause memory leaks.
cursor=-1:
No cursor change.
cursor=0:
Hour glass (default).
cursor=1:
Arrow.
cursor=2:
“Click”.
cursor=3:
Spinning beachball.
cursor=4:
Watch with spinning hands.
cursor=5:
Jacob’s ladder.
cursor=6:
Displays a progress dialog instead of changing the cursor.
cursor=7:
Spinning arrrows.
Other:
Watch.

Sleep
V-873
You can end sleep by pressing the User Abort Key Combinations. Normally when you do this, it aborts 
any procedure that is running. However, if you use the /Q flag, the procedure continues running normally.
Displaying a Progress Dialog
When you specify /C=6 or if you use the /PROG flag, Sleep displays a progress dialog with a progress bar 
showing how much of the sleep time has passed. The dialog displays a prompt which you can control using 
the /M flag.
If you use /PROG, then /Q and /B are ignored.
If you use /C=6, then /Q and /B have special meanings:
If you use the /PROG flag, you can provide your own titles for the Cancel and Continue buttons.
Examples
These examples assume the current time is 4 PM:
Sleep 00:01:30
// sleeps for 1 minute, 30 seconds
Sleep/A 23:30:00
// sleeps until 11:30 PM
Sleep/A 03:00:00
// doesn't sleep at all because time is past
Sleep/A/W 03:00:00
// sleeps until 3 AM tomorrow
String str1= "03:00:00"
// put wakeup call time in string
Sleep/A/W $str1
// sleeps until 3 AM tomorrow
Sleep/B/C=2/S/Q 60
// sleep 60 seconds, or until user clicks,
// and keep going (don't abort)
The following function creates a graph and then periodically updates the displayed data. By default, it 
sleeps for a number of seconds specified by the sleepTime parameter.
Function SleepDemo(sleepTime, displayProgressDialog)
Variable sleepTime
// In seconds
Variable displayProgressDialog
// 1 for progress dialog
Make/N=200/O junk
SetScale/I x 0, 2*pi, junk
junk=sin(x)
DoWindow/F SleepDemoGraph
if (V_Flag == 0)
Display/N=SleepDemoGraph junk
endif
DoUpdate
try
Variable i
for (i = 0; i < 10; i+=1)
if (displayProgressDialog)
// Because the abortMode is 0, pressing the user abort key combinations
// or pressing the Done button generates an abort instead of merely
// terminating the current Sleep call. 
int abortMode = 0
Sleep/S/PROG={"Done", "Continue", abortMode} sleepTime
else
// /B makes Sleep terminate if the user clicks.
/C=6
Progress dialog with Cancel button which aborts running procedures.
The Abort key combinations abort running user procedures.
/C=6/B
Progress dialog with Abort button which aborts running procedures.
The Abort key combinations abort running user procedures.
/C=6/Q
Progress dialog with Continue button which terminates the current sleep operation 
but allows procedures to continue.
Abort key combinations allow running procedures to continue.
/C=6/B/Q
Progress dialog with Continue and Abort buttons. The Continue button terminates 
the current sleep operation but allows procedures to continue. The Abort button 
aborts running procedures.
Abort key combinations allow running procedures to continue.
