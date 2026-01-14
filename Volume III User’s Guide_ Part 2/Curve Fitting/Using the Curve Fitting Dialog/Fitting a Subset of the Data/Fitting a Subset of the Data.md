# Fitting a Subset of the Data

Chapter III-8 — Curve Fitting
III-197
If you are fitting waveform data rather than XY data, you would omit “vs xData” from the AppendToGraph 
command.
New Wave
As a convenience, the Curve Fitting dialog can create a destination wave for you if you choose _New Wave_ 
from the Destination menu. It does this by generating a Duplicate command to duplicate your Y data wave 
and then uses it just like any other explicit destination wave. The new wave is not automatically appended 
to your graph, so you will have to do that yourself after the fit is completed.
Fitting a Subset of the Data
A common problem is that you don’t want to include all of the points in your data set in a curve fit. There 
are two methods for restricting a fit to a subset of points. You will find these options on the Data Options 
tab of the Curve Fitting dialog.
Selecting a Range to Fit
You can select a contiguous range of points in the Range box. The values that you use to specify the range 
for a curve fit are in terms of point or row numbers of the Y data wave. Note that if you are fitting to an XY 
pair of waves and your X values are in random order, you will not be selecting a contiguous range as it 
appears on a graph.
To simplify selecting the range, you can use graph cursors to select the start and end of the range. To use 
cursors, display your raw data in a graph. Display the info panel in the graph by selecting ShowInfo from 
the Graph menu. Drag the cursors onto your raw data. Then use the Cursors button in the Curve Fitting 
dialog to generate a command to fit the cursor range.
Here is what a graph might look like after a fit over a subrange of a data set:
In this example, we used auto-trace for the destination. Notice that the trace appears over the selected range 
only. If we want to show the destination over a wider range, we need to change the destination wave’s X 
scaling. These commands change the destination wave to show more points over a wider range:
Redimension/N=500 fit_data
// change to 500 points
SetScale x 13, 20, fit_data
// set domain from 13 to 20
fit_data= W_coef[0]+W_coef[1]/((x-W_coef[2])^2+W_coef[3])
The last line was copied from the history area, where it was displayed after the fit.
This produces the following graph:

Chapter III-8 — Curve Fitting
III-198
If you use an explicit destination wave rather than auto-trace, it is helpful to set the destination wave to 
blanks (NaN) before performing the fit. As the fit progresses, it will store new values only in the destination 
wave range that corresponds to the range being fit. Also, it stores into the destination wave only at points 
where the source wave is not NaN or INF. If you don’t preset the destination wave to blanks, you will wind 
up with a combination of new and old data in the destination wave.
These commands illustrate presetting the destination wave and then performing a curve fit to a range of an 
XY pair.
Duplicate/O yData, yDataFit
// make destination
yDataFit = NaN
// preset to blank (NaN)
AppendToGraph yDataFit vs xData
CurveFit lor yData(xcsr(A),xcsr(B)) /D=yDataFit
Another way to make the fit curve cover a wider range is to select the checkbox labelled X Range Full Width 
of Graph. You will find the checkbox on the Output Options tab of the Curve Fitting dialog.
Using a Mask Wave
Sometimes the points you want to exclude are not contiguous. This might be the case if you are fitting to a 
data set with occasional bad points. Or, in spectroscopic data you may want to fit regions of baseline and 
exclude points that are part of a spectroscopic peak. You can achieve the desired result using a mask wave.
The mask wave must have the same number of points as the Y Data wave. You fill in the mask wave with 
a NaN (Not-a-Number, blank cell) or zero corresponding to data points to exclude and nonzero for data 
points you want to include. You must create the mask wave before bringing up the Curve Fitting dialog. 
You may want to edit the mask wave in a table.
Enter a NaN in a table by typing “NaN” and pressing Return or Enter. Having entered on NaN, you can 
copy it to the clipboard to paste into other cells.
You can also use a wave assignment on the command line. If your data set has a bad data point at point 4, 
a suitable command to set point four in the mask wave would be:
BadPointMask[4] = NaN
When you have a suitable mask wave, you choose it from the Data Mask menu on the Data Options tab.
You can use a mask with NaN points to suppress display of the masked points in a graph if you select the 
mask wave as an f(z) wave in the Modify Trace Appearance dialog. You could also use the same wave with 
the ModifyGraph mask keyword.
