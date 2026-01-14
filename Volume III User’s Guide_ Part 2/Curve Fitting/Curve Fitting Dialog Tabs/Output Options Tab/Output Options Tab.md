# Output Options Tab

Chapter III-8 — Curve Fitting
III-216
Data Options Tab
Range: Enter point numbers for starting and ending points when fitting to a subset of the Y data.
Historical Note: These boxes used to require X values, they now require point numbers.
Cursors: Available when the top window is a graph displaying the Y data and the graph has the graph 
cursors on the Y data trace. Click this button to enter text in the Start and End range boxes that will restrict 
fitting to the data between the graph cursors.
Note: 
If the data use both a Y wave and an X wave, and the X values are in random order, you won’t 
get the expected result.
Clear: Click this button to remove text from the Start and End range boxes.
The range box changes if you have selected a multivariate function and multidimensional Y wave. The 
dialog presents Start and End range boxes for each dimension of the Y wave.
Weighting: select a wave that contains weighting values. Only waves that match the Y wave in number of 
points and dimensions are shown in this menu. See Weighting on page III-199 for details.
Wave Contains: select Standard Deviation if the weighting wave contains values of standard deviation for 
each Y data point. A larger value decreases the influence of a point on the fit.
Select 1/Standard Deviation if your weighting wave contains values of the reciprocal of the standard devi-
ation. A larger value increases the influence of the point on the fit.
Data Mask: select a wave that contains ones and zeroes or NaN’s indicating which Y Data points should be 
included in the fit. Only waves that match the Y wave in number of points and dimensions are shown in 
this menu. A one indicates a data point that should be included, a zero or NaN (Not a Number or blank in 
a table) indicates a point that should be excluded.
Coefficients Tab
The coefficients tab is quite complex. It is completely explained in the various sections on how to do a fit. 
See Two Useful Additions: Holding a Coefficient and Generating Residuals on page III-184, Automatic 
Guesses Didn’t Work on page III-187, Coefficients Tab for a User-Defined Function on page III-192, and 
The Coefficient Wave on page III-195.
Output Options Tab
The output options tab has settings that control the reporting and display of fit results:
