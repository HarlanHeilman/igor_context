# WinList

WinList
V-1098
Details
A “window function” alters the input data by decreasing values near the start and end of the data smoothly 
towards zero, so that when the FFT of the data is computed the effects of nonintegral-periodic signals are 
diminished. This improves the ability of the FFT to distinguish among closely-spaced frequencies. Each 
window function has advantages and disadvantages, usually trading off rejection of “leakage” against the 
ability to discriminate adjacent frequencies. For more details, see the References.
WindowFunction stores the window function’s normalization value (the average squared window value) 
in V_value. This is the value you would get from WaveStats’s V_rms*V_rms for a wave of srcWave’s length 
whose values were all equal to 1:
Make/O data = 1
WindowFunction Bartlet, data
// Bartlet allowed as synonym for Bartlett
Print V_value
// Prints 0.330709, mean of squared window values
WaveStats/Q data
Print V_rms*V_rms
// Prints 0.330709
See Also
FFT, ImageWindow, DPSS
References
For more information about the use of window functions see: 
Harris, F.J., On the use of windows for harmonic analysis with the discrete Fourier Transform, Proc, IEEE, 
66, 51-83, 1978.
Wikipedia entry: <http://en.wikipedia.org/wiki/Window_function>.
WinList 
WinList(matchStr, separatorStr, optionsStr)
The WinList function returns a string containing a list of windows selected based on the matchStr and 
optionsStr parameters.
Details
For a window name to appear in the output string, it must match matchStr and also must fit the 
requirements of optionsStr. separatorStr is appended to each window name as the output string is generated.
The name of each window is compared to matchStr, which is some combination of normal characters and 
the asterisk wildcard character that matches anything. For example:
matchStr may begin with the ! character to return items that do not match the rest of matchStr. For example:
The ! character is considered to be a normal character if it appears anywhere else, but there is no practical 
use for it except as the first character of matchStr.
"*"
Matches all window names
"xyz"
Matches window name xyz only
"*xyz"
Matches window names which end with xyz
"xyz*"
Matches window names which begin with xyz
"*xyz*"
Matches window names which contain xyz
"abc*xyz"
Matches window names which begin with abc and end with xyz
"!*xyz"
Matches window names which do not end with xyz

WinList
V-1099
optionsStr is used to further qualify the window. The acceptable values for optionsStr are:
windowTypes is a literal number. The window name goes into the output string only if it passes the match 
test and its type is compatible with windowTypes. windowTypes is a bitwise parameter:
See Setting Bit Parameters on page IV-12 for details about bit settings.
Procedure windows and help windows don't have names. WinList returns the window title instead.
includeTypes is also a literal number. The window name goes into the output string only if it passes the 
match test and its type is compatible with includeTypes. includeTypes is one of:
""
Consider all windows.
"WIN:"
The target window.
"WIN:windowTypes"
Consider windows that match windowTypes.
"INCLUDE:includeTypes"
Consider procedure windows that match includeTypes.
Using INCLUDE: implies WIN:128.
"INDEPENDENTMODULE:1"
Consider procedure windows that are part of any independent 
module as well as those that are not. Matching windows names are 
actually the window titles followed by " [<independent module 
name>]".
Using INDEPENDENTMODULE: implies WIN:128.
"INDEPENDENTMODULE:0"
Consider procedure windows only if they are not part of any 
independent module. Matching windows names are actually the 
window titles, which for an external file includes the file extension, 
such as "WMMenus.ipf".
Using INDEPENDENTMODULE: implies WIN:128.
"FLT:1"
Return only panels that were created with NewPanel/FLT=1. 
Specifying "FLT" also implies "WIN:64".
Omit FLT or use "FLT:0" to return windows that do not float (and 
most do not).
"FLT:2"
Return only panels that were created with NewPanel/FLT=2. 
Specifying "FLT" also implies "WIN:64".
"VISIBLE:1"
Return only visible windows (ignore hidden windows).
1:
Graphs
2:
Tables
4:
Layouts
16:
Notebooks
64:
Panels
128:
Procedure windows
512:
Help windows
4096:
XOP target windows
16384:
Camera windows in Igor Pro 7.00 or later
65536:
Gizmo windows in Igor Pro 7.00 or later
1:
Procedure windows that are not #included.
2:
Procedure windows included by #include "someFileName".
