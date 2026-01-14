# laguerre

Label
V-474
Label 
Label [/W=winName/Z] axisName, labelStr
The Label operation labels the named axis with labelStr.
Parameters
axisName is the name of an existing axis in the top graph. It is usually one of “left”, “right”, “top” or 
“bottom”, though it may also be the name of a free axis such as “VertCrossing”.
labelStr contains the text that labels the axis.
Flags
Details
labelStr can contain escape codes which affect subsequent characters in the text. An escape code is 
introduced by a backslash character. In a literal string, you must enter two backslashes to produce one. See 
Backslashes in Annotation Escape Sequences on page III-58 for details.
Using escape codes you can change the font, size, style and color of text, create superscripts and subscripts, 
create dynamically-updated text, insert legend symbols, and apply other effects. See Annotation Escape 
Codes on page III-53 for details.
Some escape codes insert text based on axis properties. See Axis Label Escape Codes on page III-57 for 
details.
The characters “<??>” in an axis label indicate that you specified an invalid escape code or used a font that 
is not available.
See Also
See Annotation Escape Codes on page III-53. See the Legend operation about wave symbols.
Trace Names on page II-282, Programming With Trace Names on page IV-87.
laguerre 
laguerre(n, x)
The laguerre function returns the Laguerre polynomial of degree n (positive integer) and argument x. The 
polynomials satisfy the recurrence relation:
with the initial conditions
and
See Also
The laguerreA, laguerreGauss, chebyshev, chebyshevU, hermite, hermiteGauss, and legendreA 
functions.
/W=winName
Adds axis label in the named graph window or subwindow. When omitted, action 
will affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
No errors generated if the named axis doesn’t exist. Used for style macros.
(n +1)Laguerre(n +1,x) = (2n +1−x)Laguerre(n,x)−nLaguerre(n −1,x),
Laguerre(0,x) = 1
Laguerre(1,x) = 1−x.
