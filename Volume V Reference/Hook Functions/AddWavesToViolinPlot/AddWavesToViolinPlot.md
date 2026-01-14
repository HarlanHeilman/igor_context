# AddWavesToViolinPlot

AddWavesToBoxPlot
V-22
See Also
Movies on page IV-245, NewMovie, AddMovieAudio
AddWavesToBoxPlot
AddWavesToBoxPlot [/W=winName /T=traceName /INST=traceInstance] wave [, wave ] 
...
Adds additional 1D waves to a pre-existing box plot trace created by AppendBoxPlot.
AddWavesToBoxPlot was added in Igor Pro 8.00.
Because a box plot trace may require a number of waves to define each data set in the trace, and because 
wave names may be quite long, the AddWavesToBoxPlot operation is provided to add waves to a list begun 
by AppendBoxPlot.
Flags
Details
If your original AppendBoxPlot command included an X wave, the total number of waves in the list of box 
plot data set waves cannot be greater than the number of points in your X wave. 
If the box plot trace is defined by a multicolumn wave, you cannot add additional waves using this 
operation.
See Also
Box Plots on page II-331, AppendBoxPlot, ModifyBoxPlot
AddWavesToViolinPlot
AddWavesToViolinPlot [/W=winName /T=traceName /INST=traceInstance] wave [, wave 
] ...
Adds additional 1D waves to a pre-existing violin plot trace created by AppendViolinPlot.
AddWavesToViolinPlot was added in Igor Pro 8.00.
Because a violin plot trace may require a number of waves to define each data set in the trace, and because 
wave names may be quite long, the AddWavesToViolinPlot operation is provided to add waves to a list 
begun by AppendViolinPlot.
Flags
/T=traceName
/INST=traceInstance
These flags specify the name and instance number of an existing box plot trace to 
which waves will be added. You can use /T without /INST, in which case a trace 
with instance number zero will be used. Do not use /INST without /T.
See Creating Graphs on page II-277 for information about trace names and trace 
instance numbers.
In the absence of both /T and /INST, the default is to use the top box plot trace 
found on the graph. That would be the most recently added box plot trace.
/W=winName
Appends to the named graph window or subwindow. When omitted, 
AddWavesToBoxPlot operates on the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
/T=traceName
