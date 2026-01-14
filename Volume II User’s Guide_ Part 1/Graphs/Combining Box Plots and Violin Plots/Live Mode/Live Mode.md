# Live Mode

Chapter II-13 — Graphs
II-347
Creating Split Axes
You can create split axes using the same techniques described above for creating stacked plots. Simply plot 
your data twice using different axes and then adjust the axes so they are stacked. You can then adjust the 
range of the axes independently. You can use draw tools to add cut marks.
WaveMetrics supplies a procedure package to automate all aspects of creating split axes except setting the 
range and adjusting the ticking details of the axes. To use the package, choose GraphPackagesSplit Axes. 
For an example, choose FileExample ExperimentsGraphing TechniquesSplit Axes.
Before using the package, you should create the graph in near final form using just the main axes. For best 
results, especially if you will be using cut marks, you should work with the graph at actual size before adding 
the split axes. It is recommended that you create a recreation macro just before executing the split axis macros. 
This is so you can easily revert in case you need to change the pre-split setup.
After creating the split, you can execute the AddSplitAxisMarks procedure to add cut marks between the two 
axes. You can then use the drawing tools to duplicate the cut marks if you want marks on the traces as well as 
the axes. Of course, you can also draw your own cut marks. You should use the default Plot Relative coordi-
nate system for cut marks so they will remain in the correct location should you resize the graph.
Some programs draw straight lines between data points on either side of the split. While such lines provide 
the benefit of connecting traces for the viewer, they also are misleading and inaccurate. This package accu-
rately plots both sections and does not attempt to provide a bridge between them. If you feel it is necessary, 
you can use drawing tools to add a connecting bridge.
Live Graphs and Oscilloscope Displays
This section will be of interest mainly if you use Igor for data acquisition.
Normally, when the data in a wave is modified, all graphs containing traces derived from that wave are 
redrawn from scratch. Although fast compared to other programs, this process may noticeably limit the 
graph update rate.
Live Mode
If you specify one or more traces in a graph as being “live” then Igor takes some shortcuts, resulting in faster 
than normal updates. Fast update is obtained when certain conditions are observed.
-8
-6
-4
-2
0
2
4
6
data set 1
data set 2
data set 3
