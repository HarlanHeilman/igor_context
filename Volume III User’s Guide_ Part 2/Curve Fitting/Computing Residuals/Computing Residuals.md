# Computing Residuals

Chapter III-8 — Curve Fitting
III-217
Destination: Select a wave to receive model values from the fit, or select _auto_ to have Igor create an 
evenly-spaced auto-destination wave for the model values. Updated on each iteration so you can follow the 
fit progress by the graph display. See The Destination Wave on page III-196 for details on the Destination 
menu, the Length box shown above and on the New Wave box that isn’t shown above.
X Range Full Width of Graph: If you have restricted the range of the fit using graph cursors, the auto des-
tination wave will cover only the range selected. Select this checkbox to make the auto destination cover the 
full width of the graph.
Residual: Select a wave to receive calculated values of residuals, or the differences between the model and 
the data. See Computing Residuals on page III-217 for details on residuals and on the various selections 
you can make from this menu.
Error Analysis: Selects various kinds of statistical error analysis. See Confidence Bands and Coefficient 
Confidence Intervals on page III-223 for details.
Add Textbox to Graph: When selected, a textbox with information about the fit will be added to the graph 
containing the Y data. Click the Textbox Preferences button to display a dialog in which you can select 
various bits of information to be included in the text box.
Create Covariance Matrix: When this is selected, the dialog generates the command to create a covariance 
matrix for the fit. See Covariance Matrix on page III-226 for details on the covariance matrix.
Suppress Screen Updates: When this is selected, graphs and tables are not updated while the fit progresses. 
This can greatly speed up the fitting process, especially if the fit involves a contour or image plot, but 
reduces the feedback you get during the fit.
Computing Residuals
A residual is what is left when you subtract your fitting function model from your raw data.
Ideally, your raw data is equal to some known function plus random noise. If you subtract the function from 
your data, what’s left should be noise. If this is not the case, then the function doesn’t properly fit your raw data.
The graphs below illustrate some exponential raw data fitted to an exponential function and to a quadratic (3 
term polynomial). The residuals from the exponential fit are random whereas the residuals from the quadratic 
display a trend overlaid on the random scatter. This indicates that the quadratic is not a good fit for the data.

Chapter III-8 — Curve Fitting
III-218
The easiest way to make a graph such as these is to let it proceed automatically using the Residual pop-up 
menu in the Output Options tab of the Curve Fitting dialog. The graphs above were made this way with 
some minor tweaks to improve the display.
The residuals are recalculated at every iteration of a fit. If the residuals are displayed on a graph, you can 
watch the residuals change as the fit proceeds.
In addition to providing an easy way to compute residuals and add the residual plot to a graph, it prints 
the wave assignment used to create the residuals into the history area as part of the curve fitting process. 
For instance, this is the result of a line fit to waveform data:
•CurveFit line LineYData /X=LineXData /D /R
fit_LineYData= W_coef[0]+W_coef[1]*x
Res_LineYData= LineYData[p] - (W_coef[0]+W_coef[1]*LineXData[p])
W_coef={-0.037971,2.9298}
V_chisq= 18.25;V_npnts= 20;V_numNaNs= 0;V_numINFs= 0;
V_startRow= 0;V_endRow= 19;V_q= 1;V_Rab= -0.879789;
V_Pr= 0.956769;V_r2= 0.915408;
W_sigma={0.474,0.21}
Coefficient values ± one standard deviation
a
=-0.037971 ± 0.474
b
=2.9298 ± 0.21
1000
500
0
1.0
0.8
0.6
0.4
0.2
0.0
-60
0
60
Residuals from exponential ﬁt
Raw data with exponential ﬁt
1000
500
0
1.0
0.8
0.6
0.4
0.2
0.0
60
0
-60
Residuals from quadratic ﬁt
Raw data with quadratic ﬁt
