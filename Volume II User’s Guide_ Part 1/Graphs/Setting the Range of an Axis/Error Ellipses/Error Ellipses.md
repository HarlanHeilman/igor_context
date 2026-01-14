# Error Ellipses

Chapter II-13 — Graphs
II-305
Error Shading
In Igor Pro 7 or later, you can use shading in place of error bars. In the Error Bars subdialog, check the “Use 
shading instead of bars” checkbox to enable shading.
Shading mode fills between either the +error to -error levels or from +error to data and data to -error 
depending on the parameters used with the shade keyword.
These commands illustrate multiple and overlapping error shading with transparency:
Make/O/N=200 jack=sin(x/8), sam=cos(x/9) + (100-x)/30
Display /W=(64,181,499,520) jack,jack,sam
ModifyGraph lsize(jack)=0,rgb(sam)=(0,0,65535)
ErrorBars jack shade={0,0,(0,65535,0,10000),(0,0,0)},const=2
ErrorBars jack#1 shade={0,0,(0,65535,0,10000),(0,0,0)},const=1
ErrorBars sam shade={0,0,(65535,0,0,10000),(0,0,0)},const=1
On Windows shading does not work with the old GDI graphics technology. See Graphics Technology on 
page III-506 for details.
These commands illustrate different +error and -error shading as well as the use of pattern:
Make/O jack=sin(x/8)
Display /W=(64,181,499,520) jack
ErrorBars jack shade={0,73,(0,65535,0),(0,0,65535),11,(65535,0,0),(0,65535,0)},const=0.5
See the shade keyword for the ErrorBars operation for details.
Error Ellipses
In Igor Pro 9.00 and later, you can specify error ellipses instead of bars or boxes. Error ellipses show both X 
and Y errors along with correlation between X and Y.
You must provide the data for error ellipses via a three-column wave with a row for each data point. This 
wave is labelled Ellipse Wave in the Error Bars dialog. It is identified by ewave=ew in the ErrorBars opera-
tion.
Each row of ew contains information for the error ellipse for one data point. The interpretation of the 
columns of ew depends on the mode, labelled Data Type in the ErrorBars dialog and identified by the mode 
parameter of the ELLIPSE keyword in the ErrorBars operation.
mode=0: ew contains the standard deviation in X, the standard deviation in Y, and the correlation between 
X and Y.
mode=1: ew contains the variance in X, the variance in Y, and the covariance of X and Y.
When specified via the ErrorBars operation ew, may include a subrange specification so long as it results in 
effectively a 2D wave with three columns and a row for each trace data point. See Subrange Display Syntax 
on page II-321.
Error Ellipse Color
The color of each error ellipse is taken from the color of the data point to which the ellipse is attached. 
Usually that is simply the trace color. You can change the color of individual data points and their corre-
sponding ellipses using the trace Color as f(z), or by point customization (see Customize at Point on page 
II-306).
You can specify the opacity of all error ellipses for a given trace using the Fill Alpha setting in the Error Bars 
dialog which ranges from 0 (fully transparent) to 1.0 (fully opaque). This specifies the fill color alpha for all 
error ellipses, overriding the data points' alpha. In the ErrorBars operation, you specify alpha as a value 
from 0 (fully transparent) to 65535 (fully opaque) using the ELLIPSE keyword. For background information 
on alpha, see RGBA Values on page IV-13.
