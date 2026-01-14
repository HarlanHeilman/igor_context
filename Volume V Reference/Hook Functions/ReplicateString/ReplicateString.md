# ReplicateString

ReplicateString
V-802
Details
Waves are replaced in the graph specified by /W=winName otherwise waves are replaced in the top graph.
Updating a contour plot in response to replacing a wave can be time-consuming. If you must replace more 
than one wave, put all the commands separated by semicolons on a single line. In a macro, use 
DelayUpdate to prevent updates between command lines.
When using the allinCDF keyword, ReplaceWave cannot find waves buried in dynamic annotation text (for 
instance, using the \{} syntax in an annotation). ReplaceWave will not replace waves used for error bars, either.
Subsets of data, including individual rows or columns from a matrix, may be specified using Subrange 
Display Syntax on page II-321.
Examples
Make XY plot, then replace the waves:
Make fred=x, sam=log(x)
Display fred vs sam
Make fred2=2*x, sam2=ln(x)
ReplaceWave/X trace=fred, sam2
ReplaceWave trace=fred, fred2
// trace is now named fred2
Make contour plot with XYZ triplet waves, then replace the waves. Note the DelayUpdate commands after 
the first two ReplaceWave commands:
Make/N=100 junkx, junky, junkz
// Waves for XYZ triplets
junkx=trunc(x/10)
// X wave for XYZ triplets
junky=mod(x,10)
// Y wave for XYZ triplets
junkz=sin(junkx[p])*cos(junky[p])
// Z wave for XYZ triplets
Display; AppendXYZContour junkz vs {junkx, junky}
// Make contour plot
Make/O/N=150 junkx2, junky2, junkz2
// Make replacement waves
junkx2=trunc(x/15)
junky2=mod(x,15)
junkz2=sin(junkx2[p])*cos(junky2[p])
ReplaceWave/X contour=junkz,junkx2; DelayUpdate
ReplaceWave/Y contour=junkz,junky2; DelayUpdate
ReplaceWave contour=junkz,junkz2
This example is suitable for copying all the lines and pasting into the command line, or for use in a macro. 
If you are typing on the command line, you would want to put the ReplaceWave commands all on one line:
ReplaceWave/X contour=junkz,junkx2; ReplaceWave/Y contour=…
See Also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
ReplicateString
ReplicateString(str, totalNumCopies)
The ReplicateString function returns a string containing str repeated totalNumCopies times.
The ReplicateString function was added in Igor Pro 9.00.
Example
String in = "αßγ"
String out = ReplicateString(in, 3)
// Returns "αßγαßγαßγ"
See Also
PadString, ReplaceString
image=imageName
Replaces the wave supplying the Z data for imageName. If /X or /Y is used, replaces 
the wave used to set the X or Y data spacing.
trace=traceName
Replaces the wave associated with traceName. With the /X flag, waveName will 
replace the X wave associated with traceName, otherwise it will replace the Y 
wave. Note that traceName is derived from the Y wave name; if you created a 
graph using Display jack vs sam, you would use ReplaceWave/X 
trace=jack,newsam to replace the X wave.
For traces, the ReplaceWave/Y flag is equivalent to ReplaceWave with no flags.
