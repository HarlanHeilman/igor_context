# Using the Interp Function

Chapter III-7 — Analysis
III-110
The required steps are:
1.
Select XY Pair to Waveform from Igor's DataPackages submenu.
The panel is displayed:
2.
Select the X and Y waves (xData and yData) in the popup menus. When this example's xData wave 
is analyzed it is found to be "not regularly spaced (slope error avg= 0.52...)", which means that Set-
Scale is not appropriate for converting yData into a waveform.
3.
Use Interpolate is selected here, so you need a waveform name for the output. Enter any valid wave 
name.
4.
Set the number of output points. Using a number roughly the same as the length of the input waves 
is a good first attempt. You can choose a larger number later if the fidelity to the original is insuffi-
cient. A good number depends on how uneven the X values are - use more points for more uneven-
ness.
5.
Click Make Waveform.
6.
To compare the XY representation of the data with the waveform representation, append the wave-
form to a graph displaying the XY pair. Make that graph the top graph, then click the "Append to 
<Name of Graph>" button.
7.
You can revise the Number of Points and click Make Waveform to overwrite the previously created 
waveform in-place.
Using the Interp Function
We can use the interp function (see page V-458) to create a waveform version of our Gaussian. The required 
steps are:
1.
Make a new wave to contain the waveform representation.
2.
Use the SetScale operation to define the range of X values in the waveform.
3.
Use the interp function to set the data values of the waveform based on the XY data.
Here are the commands:
Duplicate yData, wData
SetScale/I x 0, 1, wData
wData = interp(x, xData, yData)
To compare the waveform representation to the XY representation, we append the waveform to the graph.
AppendToGraph wData
Let’s take a closer look at what these commands are doing.
