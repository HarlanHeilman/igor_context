# ContourInfo

Constant
V-85
Constant 
Constant kName = literalNumber
Constant/C kName = (literalNumberReal, literalNumberImag)
The Constant declaration defines the number literalNumber under the name kName for use by other code, 
such as in a switch construct.
The complex form, using the /C flag to create a complex constant, requires Igor Pro 7.00 or later.
See Also
The StrConstant keyword for string types, Constants on page IV-51 and Switch Statements on page IV-43.
continue 
continue
The continue flow control keyword returns execution to the beginning of a loop, bypassing the remainder 
of the loop’s code.
See Also
Continue Statement on page IV-48 and Loops on page IV-45 for usage details.
ContourInfo 
ContourInfo(graphNameStr, contourWaveNameStr, instanceNumber)
The ContourInfo function returns a string containing a semicolon-separated list of information about the 
specified contour plot in the named graph.
Parameters
graphNameStr can be "" to refer to the top graph.
contourWaveNameStr is a string containing either the name of a wave displayed as a contour plot in the 
named graph, or a contour instance name (wave name with “#n” appended to distinguish the nth contour 
plot of the wave in the graph). You might get a contour instance name from the ContourNameList function.
If contourWaveNameStr contains a wave name, instanceNumber identifies which instance you want 
information about. instanceNumber is usually 0 because there is normally only one instance of a wave 
displayed as a contour plot in a graph. Set instanceNumber to 1 for information about the second contour 
plot of the wave, etc. If contourWaveNameStr is "", then information is returned on the instanceNumberth 
contour plot in the graph.
If contourWaveNameStr contains an instance name, and instanceNumber is zero, the instance is taken from 
contourWaveNameStr. If instanceNumber is greater than zero, the wave name is extracted from 
contourWaveNameStr, and information is returned concerning the instanceNumberth instance of the wave.
Details
The string contains several groups of information. Each group is prefaced by a keyword and colon, and 
terminated with the semicolon. The keywords are as follows: 
Keyword
Information Following Keyword
AXISFLAGS
Flags used to specify the axes. Usually blank because /L and /B (left and bottom 
axes) are the defaults.
DATAFORMAT
Either XYZ or Matrix.
LEVELS
A comma-separated list of the contour levels, including the final automatic levels, 
(or manual or from-wave levels), and the “more levels”, all sorted into ascending Z 
order.
RECREATION
List of keyword commands as used by ModifyContour command. The format of 
these keyword commands is:
keyword (x)=modifyParameters;
TRACESFORMAT
The format string used to name the contour traces (see AppendMatrixContour or 
AppendXYZContour).
