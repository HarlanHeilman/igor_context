# Using the Curve Fitting Dialog

Chapter III-8 — Curve Fitting
III-181
Curve Fitting Using the Quick Fit Menu
The Quick Fit menu is the easiest, fastest way to do a curve fit.
The Quick Fit menu gives you quick access to curve fits using the built-
in fitting functions. The data to be fit are determined by examining the 
top graph; if a single trace is found, the graphed data is fit to the 
selected fitting function. If the graph contains more than one trace a 
dialog is presented to allow you to select which trace should be fit.
The graph contextual menu also gives access to the Quick Fit menu. If 
you Control-click (Macintosh) or right-click (Windows) on a trace in a 
graph, you will see a Quick Fit item at the bottom of the resulting con-
textual menu. When you access the Quick Fit menu this way, it auto-
matically fits to the trace you clicked on. This gives you a way to avoid 
the dialog that Quick Fit uses to select the correct trace when there is 
more than one trace on a graph.
When you use the Quick Fit menu, a command is generated to perform the fit and automatically add the 
model curve to the graph. By default, if the graph cursors are present, only the data between the cursors is 
fit. You can do the fit to the entire data set by selecting the Fit Between Cursors item in the Quick Fit menu 
in order to uncheck the item. When unchecked, fits are done disregarding the graph cursors.
If the trace you are fitting has error bars and the data for the error bars come from a wave, Quick Fit will 
use the wave as a weighting wave for the fit. Note that this assumes that your error bars represent one stan-
dard deviation. If your error wave represents more than one standard deviation, or if it represents a confi-
dence interval, you should not use it for weighting. You can select the Weight from Error Bar Wave item to 
unmark it, preventing Igor from using the error bar wave for weighting.
By default, a report of curve fit results is printed to the history. If you select Textbox Preferences, the Curve 
Fit Textbox Preferences dialog is displayed. It allows you to specify that a textbox be added to your graph 
containing most of the information that is printed in the history. You can select various components of the 
information by selecting items in the Dialog.
In the screen capture above, the poly2D and Gauss2D fit functions are not available because the top graph 
does not contain a contour plot or image plot, in which case the fitting functions would be available.
For a discussion of the built-in fit functions, see Built-in Curve Fitting Functions on page III-206.
Limitations of the Quick Fit Menu
The Quick Fit menu does not give you access to the full range of curve fitting options available to you. It 
does not give you access to user-defined fitting functions, automatic residual calculation, masking, or con-
fidence interval analysis. A Quick Fit always uses automatic guesses; if the automatic guesses don’t work, 
you must use the Curve Fitting dialog to enter manual guesses.
If your graph displays an image that uses auxiliary X and Y waves to set the image pixel sizes, Quick Fit 
will not be able to do the fit. This is because these waves for an image plot have an extra point that makes 
them unsuitable for fitting. A contour plot uses X and Y waves that set the centers of the data, and these can 
be used for fitting. Quick Fit will do the right thing with such a contour plot.
Using the Curve Fitting Dialog
If you want options that are not available via the Quick Fit menu, the next easiest way to do a fit is to choose 
Curve Fitting from the Analysis menu. This displays the Curve Fitting dialog, which presents an interface 
for selecting a fitting function and data waves, and for setting various curve fitting options. You can use the 
dialog to enter initial guesses if necessary. The Curve Fitting dialog can also be used to create a new user-
defined fitting function.
