# The Interpolate Dialog

Chapter III-7 — Analysis
III-117
The Interpolate Dialog
Choosing AnalysisInterpolate summons the Interpolate dialog from which you can choose the desired 
type of interpolation, the source wave or waves, the destination wave or waves, and the number of points 
in the destination waves. This dialog generates an Interpolate2 command which you can execute, copy to 
the clipboard or copy to the command line.
From the Interpolation Type pop-up menu, choose Linear or Cubic Spline or Smoothing Spline. Cubic 
spline is good for a small input data set. Smoothing spline is good for a large, noisy input data set.
If you choose Cubic Spline, a Pre-averaging pop-up menu appear. The pre-averaging feature is largely no 
longer needed and is not recommended. Use the smoothing spline instead of the cubic spline with pre-aver-
aging.
If you choose smoothing spline, a Smoothing Factor item and Standard Deviation controls appear. Usually 
it is best to set the smoothing factor to 1.0 and use the constant mode for setting the standard deviation. You 
then need to enter an estimate for the standard deviation of the noise in your Y data. Then try different 
values for the standard deviation until you get a satisfactory smooth spline through your data. See Smooth-
ing Spline Parameters on page III-119 for further details.
From the Y Data and X Data pop-up menus, choose the source waves that define the data through which 
you want to interpolate. If you choose a wave from the X Data pop-up, Interpolate2 uses the XY curve 
defined by the contents of the Y data wave versus the contents of the X data wave as the source data. If you 
choose _calculated_ from the X Data pop-up, it uses the X and Y values of the Y data wave as the source 
data.
If you click the From Target checkbox, the source and destination pop-up menus show only waves in the 
target graph or table.
The X and Y data waves must have the same number of points. They do not need to have the same data type.
The X and Y source data does not need to be sorted before using Interpolate2. If necessary, Interpolate2 sorts 
a copy of the input data before doing the interpolation.
NaNs (missing values) and INFs (infinite values) in the source data are ignored. Any point whose X or Y 
value is NaN or INF is treated as if it did not exist.
Enter the number of points you want in the destination waves in the Destination Points box. 200 points is 
usually good.
From the Y Destination and X Destination pop-up menus, choose the waves to contain the result of the 
interpolation. For most cases, choose _auto_ for the Y destination wave and _none_ for the X destination 
wave. This gives you an output waveform. Other options, useful for less common applications, are 
described in the following paragraphs.
If you choose _auto_ from the Y Destination pop-up, Interpolate2 puts the Y output data into a wave whose 
name is derived by adding a suffix to the name of the Y data wave. The suffix is "_L" for linear interpolation, 
"_CS" for cubic spline interpolation and "_SS" for smoothing spline interpolation. For example, if the Y data 
wave is called "yData", then the default Y destination wave will be called "yData_L", "yData_CS" or 
"yData_SS".
If you choose _none_ for the X destination wave, Interpolate2 puts the Y output data in the Y destination 
wave and sets the X scaling of the Y destination wave to represent the X output data.
If you choose _auto_ from the X Destination pop-up, Interpolate2 puts the X output data into a wave whose 
name is derived by adding the appropriate suffix to the name of the X data wave. If the X data wave is 
"xData" then the X destination wave will be "xData_L", "xData_CS" or "xData_SS". If there is no X data wave 
then the X destination wave name is derived by adding the letter "x" to the name of the Y destination wave. 
For example, if the Y destination is "yData_CS" then the X destination wave will be "yData_CSx".
