# Gaps

Chapter II-13 — Graphs
II-303
With log axes, the trace multiplier provides an alternative method of offsetting a trace on a log axis (remember: 
log(a*b)=log(a)+log(b)). For compatibility reasons and because the trace offset method better handles switching 
between log and linear axis modes, Igor uses the multiplier method when you drag a trace only if the offset is 
zero and the multiplier is not zero (the default meaning “not set”). Consequently, to use the multiplier technique, 
you must use the command line or the Offset controls in the Modify Trace Appearance dialog to set a nonzero 
multiplier. 1 is a good setting for this purpose.
Hiding Traces
You can hide a trace in a graph by checking the Hide Trace checkbox in the Modify Trace Appearance 
dialog. When you hide a trace, you can use the Include in Autoscale checkbox to control whether or not the 
data of the hidden trace should be used when autoscaling the graph.
Complex Display Modes
When displaying traces for complex data you can use the Complex Mode pop-up menu in the Modify Trace 
Appearance dialog to control how the data are displayed. You can display the complex and real compo-
nents together or individually, and you can also display the magnitude or phase.
The default display mode is Lines between points. To display a wave’s real and imaginary parts side-by-
side on a point-for-point basis, use the Sticks to zero mode.
Gaps
In Igor, a missing or undefined value in a wave is stored as the floating point value NaN (“Not a Number”). 
Normally, Igor shows a NaN in a graph as a gap, indicating that there is no data at that point. In some cir-
cumstances, it is preferable to treat a missing value by connecting the points on either side of it.
You can control this using the Gaps checkbox in the Modify Trace Appearance dialog. If this checkbox is 
checked (the default), Igor shows missing values as gaps in the data. If you uncheck the checkbox, Igor 
ignores missing values, connecting the available data points on either side of the missing value.
25
20
15
10
5
0
-5
-10
v
3.0
2.5
2.0
1.5
1.0
0.5
0.0
Hz
real and imaginary parts using 
Sticks to zero display mode
Point 4 real part
Point 4 imag part
1.2
1.0
0.8
0.6
0.4
0.2
0.0
1.0
0.8
0.6
0.4
0.2
0.0
Gaps
No Gaps
