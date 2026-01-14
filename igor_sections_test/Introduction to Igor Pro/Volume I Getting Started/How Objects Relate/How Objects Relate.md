# How Objects Relate

Chapter I-1 — Introduction to Igor Pro
I-3
In the following illustration, the wave consists of five data points numbered 0 through 4. The user has set 
the wave's X scaling such that its X values start at 0 and increment by 0.001 seconds per point. The graph 
displays the wave's stored data values versus its computed X values.
Waves can have from one to four dimensions and can contain either numeric or text data.
Igor is also capable of dealing with data that does not fit the waveform metaphor. We call this XY data. Igor 
can treat two waves as an XY pair. In an XY pair, the data values of one wave supply the X component and 
the data values of another wave supply the Y component for each point in the pair.
A few analysis operations, such as Fourier transforms, inherently work only on waveform data. They take 
a wave’s X scaling into account.
Other operations work equally well on waveform or XY data. Igor can graph either type of data and its pow-
erful curve fitting works on either type.
Most users create waves by loading data from a file. You can also create waves by typing in a table, evalu-
ating a mathematical expression, acquiring from a data acquisition device, and accessing a database.
How Objects Relate 
This illustration shows the relationships among Igor's basic objects. Waves are displayed in graphs and 
tables. Graphs and tables are displayed in page layouts. Although you can display a wave in a graph or 
table, a wave does not need to be displayed to exist.
0
0
3.74 
1
.001
4.59 
2
.002
4.78 
3
.003
5.49 
4
.004
5.66
Point 
number
X value
Data value
5.5
5.0
4.5
4.0
4
3
2
1
0
ms
Igor computes a wave’s X values.
Igor stores a wave’s data values in memory.
In a graph of waveform data, Igor plots a 
wave’s data values versus its X values.
X scaling is a property of a wave that speciﬁes 
how to ﬁnd the X value for a given point.
X scaling
Graph
Table
Waves reside in memory. 
Each wave has a unique name that you can assign to it.
Waves
Page Layout
You use a wave’s name to designate it for display 
or analysis or in a mathematical expression.
The traces in a graph and columns in a table are 
representations of waves.
Page layouts display multiple graphs and tables as 
well as pictures and annotations for presentation.
