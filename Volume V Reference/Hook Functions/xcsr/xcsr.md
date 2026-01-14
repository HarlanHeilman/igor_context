# xcsr

x
V-1114
and the variance is
Note that this definition of the PDF uses different scaling than the one used in StatsWeibullPDF. To match 
the scaling of StatsWeibullPDF multiply the result from Wnoise by the factor scale^(1-1/shape).
The random number generator initializes using the system clock when Igor Pro starts. This almost 
guarantees that you will never repeat a sequence. For repeatable “random” numbers, use SetRandomSeed. 
The algorithm uses the Mersenne Twister random number generator.
See Also
The SetRandomSeed operation.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
x 
x
The x function returns the scaled row index for the current point of the destination wave in a wave 
assignment statement. This is the same as the X value if the destination wave is a vector (1D wave).
Details
Outside of a wave assignment statement, x acts like a normal variable. That is, you can assign a value to it 
and use it in an expression.
See Also
The p function and Waveform Arithmetic and Assignments on page II-74.
x2pnt 
x2pnt(waveName, x1)
The x2pnt function returns the integer point number on the wave whose X value is closest to x1.
For higher dimensions, use ScaleToIndex.
See Also
DimDelta, DimOffset, pnt2x, ScaleToIndex
For an explanation of waves and X scaling, see Changing Dimension and Data Scaling on page II-68.
xcsr 
xcsr(cursorName [, graphNameStr])
The xcsr function returns the X value of the point which the named cursor (A through J) is on in the top or 
named graph.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.

1
  1+ 1





 ,

2
  1+ 2




 
  
2

 1+ 1




 






2
.
