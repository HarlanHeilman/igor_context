# PanelResolution

p2rect
V-732
Details
Outside of a wave assignment statement p acts like a normal variable. That is, you can assign a value to it 
and use it in an expression.
See Also
Waveform Arithmetic and Assignments on page II-74.
For other dimensions, the q, r, and s functions.
For scaled dimension indices, the x, y, z, and t functions.
p2rect 
p2rect(z)
The p2rect function returns a complex value in rectangular coordinates derived from the complex value z 
which is assumed to be in polar coordinates (magnitude is stored in the real part and the angle, in radians, 
in the imaginary part of z).
Examples
Assume waveIn and waveOut are complex, then:
waveOut = p2rect(waveIn)
sets each point of waveOut to the rectangular coordinates based on the magnitude in the real part and the 
angle (in radians) in the imaginary part of the points in waveIn.
You may get unexpected results if the number of points in waveIn differs from the number of points in waveOut.
See Also
The functions cmplx, conj, imag, r2polar, and real.
PadString 
PadString(str, finalLength, padValue)
The PadString function returns a string identical to str except that it has been extended to a total length of 
finalLength using bytes of padValue. Use zero to create a C-language style string or use 0x20 to pad with spaces 
(FORTRAN style). This is useful when reading or writing binary files using FBinRead and FBinWrite.
See Also
UnPadString, ReplaceString, ReplicateString
Panel 
Panel
Panel is a procedure subtype keyword that identifies a macro as being a control panel recreation macro. It 
is automatically used when Igor creates a window recreation macro for a control panel. See Procedure 
Subtypes on page IV-204 and Saving a Window as a Recreation Macro on page II-47 for details.
PanelResolution
PanelResolution(wName)
The PanelResolution function returns the current resolution of the specified window in pixels per inch.
If wName is empty, it returns the current global setting for panel resolution in pixels per inch which is 
controlled by SetIgorOption PanelResolution (see page III-456).
If wName is the name of a graph window, it returns the resolution for the ControlBar area in pixels per inch.
wName can be a subwindow specification.
The PanelResolution function was added in Igor Pro 7.00.
In general, PanelResolution and ScreenResolution return the same thing. However, on Windows when the 
screen resolution is 96 DPI, which is typical for normal-resolution screens, panels can use 72 DPI for 
compatibility with Igor Pro 6 and earlier.
