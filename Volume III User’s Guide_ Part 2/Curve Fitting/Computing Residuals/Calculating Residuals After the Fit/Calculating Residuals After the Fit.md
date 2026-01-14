# Calculating Residuals After the Fit

Chapter III-8 — Curve Fitting
III-220
Removing the Residual Auto Trace
When an auto-trace residual plot is added to a graph, it modifies the axis used to plot the original Y data. If 
you remove the auto-trace residual from the graph, the residual axis is removed and in most cases the Y 
data axis is restored to its previous state.
In some complicated graphs the restoration of the data axis isn’t done correctly. To restore the graph, 
double-click the Y data axis to bring up the Modify Axes dialog and select the Axis tab. You will find two 
settings labeled “Draw between … and … % of normal”. Typically, the correct settings will be 0 and 100.
Residuals Using Auto Wave
Because the changes to the graph formatting are substantial, you may want the automatic residual wave 
created and filled in but not appended to the graph. To accomplish this, simply choose _Auto Wave_ from 
the Residual pop-up menu in the Curve Fitting dialog. Once the wave is made by the curve fitting process, 
you can append it to a graph, or use it in any other way you wish.
Residuals Using an Explicit Residual Wave
You can choose a wave from the Residual pop-up menu and that wave will be filled with residual values. 
In this case, it does not append the wave to the top graph. You can use this technique to make graphs with 
the formatting completely under your own control, or to use the residuals for some other purpose.
Only waves having the same number of points as the Y data wave are listed in the menu. If you don’t want 
to let the dialog create the wave, you would first create a suitable wave by duplicating the Y data wave 
using the Duplicate Waves item in the Data menu, or using the Duplicate command:
Duplicate yData, residuals_poly3
It is often a good idea to set the wave to NaN, especially when fitting to a subrange of the data:
residuals_poly3=NaN
After the wave is duplicated, it would typically be appended to a graph or table before it is used in curve fitting.
Explicit Residual Wave Using New Wave
The easiest way to make an explicit residual wave is to let the Curve Fitting dialog do it for you. You do this 
by choosing _New Wave_ in the Residual menu. A box appears allowing you to enter a name for the new 
wave. The dialog will then generate the required commands to make the wave before the curve fit starts. The 
wave made this way will not be added to a graph. You will need to do that yourself after the fit is finished.
Calculating Residuals After the Fit
You may wish to avoid the overhead of calculating residuals during the fitting process. This section 
describes ways to calculate the residuals after a curve fit without depending on automatic wave creation.
Graphs similar to the ones at the top of this section can be made by appending a residuals wave using a free 
left axis. Then, under the Axis tab of the Modify Axes dialog, the distance for the free axis was set to zero 
and the axis was set to draw between 80 and 100% of normal. The normal left axis was set to draw between 
0 and 70% and axis standoff was turned off for both left and bottom axes.
Here are representative commands used to accomplish this.
// Make sample data
Make/N=500 xData, yData
xData = x/500 + gnoise(1/1000)
yData = 100 + 1000*exp(-.005*x) + gnoise(20)
// Do exponential fit with auto-trace
CurveFit exp yData /X=xData /D
Rename fit_yData, fit_yData_exp
// Calculate exponential residuals using interpolation in
// the auto trace wave to get model values
