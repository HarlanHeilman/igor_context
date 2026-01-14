# try-catch-endtry

TrimString
V-1047
ModifyGizmo ModifyObject=scatter0 property={ color,0,0,0,1}
AppendToGizmo Path=root:M_TetraPath,name=path0
ModifyGizmo ModifyObject=path0 property={ pathColor,0,0,1,1}
ModifyGizmo setDisplayList=0, object=scatter0
ModifyGizmo setDisplayList=1, object=path0
ModifyGizmo autoscaling=1
ModifyGizmo compile
ModifyGizmo endRecMacro
End
References
Watson, D.F., Computing the n-dimensional Delaunay tessellation with application to Voronoi polytopes, 
The Computer J., 24, 167-172, 1981.
Further information about this algorithm can be found in:
Watson, D.F., CONTOURING: A guide to the analysis and display of spatial data, Pergamon Press, 1992.
See Also
The Interpolate3D operation and the Interp3D function.
TrimString
TrimString(str [, simplifyInternalSpaces])
The TrimString function returns a string identical to str except that leading and trailing whitespace 
characters are removed. The whitespace characters are space, tab, carriage-return and linefeed.
If the optional second parameter is non-zero, then each run of whitespace characters between words in str 
is "simplified" to a single space character.
TrimString was added in Igor Pro 7.00.
Examples
Print TrimString(" spaces at ends ")
// Prints "spaces at ends"
Print TrimString(" spaces at ends ", 1)
// Prints "spaces at ends"
See Also
SplitWave, RemoveEnding, ReplaceString
trunc 
trunc(num)
The trunc function returns the integer closest to num in the direction of zero.
The result for INF and NAN is undefined.
See Also
The round, floor, and ceil functions.
try 
try
The try flow control keyword marks the beginning of the initial code block in a try-catch-endtry flow 
control construct.
See Also
The try-catch-endtry flow control statement for details.
try-catch-endtry 
try
<code>
catch
<code to handle abort>
endtry
A try-catch-endtry flow control statement provides a means for catching and responding to abort conditions 
in user functions. A programmatic abort is generated when the code executes Abort, AbortOnRTE or
