# Creating Box Plots and Violin Plots

Chapter II-13 — Graphs
II-330
barbColor[0][1]= {0,65535,0}
// Green
barbColor[0][2]= {0,0,65535}
// Blue
// Turn on color as f(z) mode
ModifyGraph zColor(yData)={barbColor,*,*,directRGB,0}
To see a demo of wind barbs choose FileExample ExperimentsFeature Demos2Barbs and Arrows.
See the arrowMarker keyword under ModifyGraph (traces) on page V-613 for details on the construction 
of the barb data wave.
The various color as f(z) modes are explained under Setting Trace Properties from an Auxiliary (Z) Wave 
on page II-298. You can eliminate the barbColor wave by using a color table lookup instead of a color wave.
Box Plots and Violin Plots
When you have multiple measurements that all represent the same conditions, it is useful to know how 
those measurements are distributed—tightly or loosely clustered, grouped around a central value or more 
loosely clustered with outliers, and many other possibilities. It is difficult for the eye to comprehend a 
simple cluster of dots, so plots that summarize the distribution are helpful. Box plots and violin plots are 
two ways to summarize a distribution of data points.
In Igor, box plots and violin plots are a special kind of graph trace. Each "point" of the trace represents an 
entire dataset. The data may be stored in individual waves, one wave for each dataset, in which case the 
input for the trace is a list of waves. Alternately, each dataset may be a column in a single two-dimensional 
matrix wave.
A normal XY graph trace is named for the wave containing the Y data. Thus, if the Y data is in a wave called 
"wave0", the trace is also called "wave0". But a box or violin plot may represent data coming from a number 
of waves. By default the box or violin plot trace is named for the first wave in the list of waves unless you 
specify a custom trace name. We recommend choosing a custom trace name that describes the nature of the 
collection of waves.
Box Plot and Violin Plot Terminology
To illustrate this terminology, consider these commands:
Make/N=10 wave0, wave1, wave2
Make/T labels = {"Run 1", "Run 2", "Run 3"}
Display; AppendBoxPlot/TN=trace0 wave0, wave1, wave2 vs labels
This creates a box plot with one trace named trace0. The trace consists of three datasets named wave0, 
wave1, and wave2. If we omitted /TN=trace0, the trace would have the default name wave0.
We can achieve the same thing using a 2D three-column 2D wave instead of three 1D waves:
Make/N={10,3} mat
Make/T labels = {"Run 1", "Run 2", "Run 3"}
Display; AppendBoxPlot/TN=trace0 mat vs labels
This creates a box plot with one trace named trace0. The trace consists of three datasets named mat[0], 
mat[1], and mat[2]. If we omitted /TN=trace0, the trace would have the default name mat.
Creating Box Plots and Violin Plots
To create a box plot, choose either WindowsNewBox Plot. To create a violin plot, choose Win-
dowsNewViolin Plot. This displays a dialog in which you can choose datasets and set other parame-
ters.
You choose datasets to be used for the plot from the list on the left, and transfer them to the list on the right 
by clicking the arrow button. Initially, the dialog shows only 1D waves and you need to select one wave for
