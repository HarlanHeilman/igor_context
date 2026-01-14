# Category Plot Axes and Axis Labels

Chapter II-14 — Category Plots
II-363
waves at the default “point scaling.” In any event, the X scaling of the value (numeric) waves should be 
identical. Differing X scaling causes the bars to become separated in category plots containing multiple bars 
per category. In the graph on the right the numeric waves have different X scaling
Changing the Drawing Order Breaks Stacked Bars
Stacked bar charts are heavily dependent on the concept of the “current bar” and the “next bar”. The modes 
describe how the current bar is connected to the next bar, such as “Stack on next”.
If you change the drawing order of the traces, using the Reorder Traces dialog or the Trace pop-up menu, 
one or more bars will have a new “next bar” (a different trace than before). Usually this means that a bar 
will be stacking on a different bar. This is usually a problem only when the stacking modes of the traces 
differ, or when smaller bars become hidden by larger bars.
After you change the drawing order, you may have to change the stacking modes. Bars hidden by larger bars 
may have to be moved forward in the drawing order with the Reorder Traces dialog or the Trace pop-up menu.
Bars Disappear with “Draw to next” Mode
In “Draw to next” mode, if the next bar is taller than the current bar then the current bar will not be visible 
because it will be hidden by the next bar.
You can change the drawing order with the Reorder Traces dialog or the Trace pop-up menu to move the 
shorter bars forward in the drawing order, so they will be drawn in front of the larger bars.
Category Plot Preferences
You can change the default appearance of category plots by capturing preferences from a prototype graph 
containing category plots. Create a graph containing a category plot (or plots) having the settings you use 
most often. Then choose GraphCapture Graph Prefs. Select the Category Plots categories, and click 
Capture Prefs.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. This is discussed in more detail in Chapter III-18, Preferences.
Category Plot Axes and Axis Labels
When creating category plots with preferences turned on, Igor uses the Category Plot axis settings for the 
text wave axis and XY plot axis settings for the numeric wave axis.
Only axes used by category plot text waves have their settings captured. Axes used solely for an XY plot, 
image plot, or contour plot are ignored. Usually this means that only the bottom axis settings are captured.
The category plot axis preferences are applied only when axes having the same name as the captured axis 
are created by a Display or AppendToGraph operation when creating a category plot. If the axes existed 
before the operation is executed, they are not affected by the category plot axis preferences.
15 min
1 hr
6 hrs
24 hrs
SetScale/P x 0,1,"", control
SetScale/P x,0,1,"", test
15 min
1 hr
6 hrs
24 hrs
SetScale/P x 0,2,"", control
SetScale/P x,0,1,"", test
Same X scaling
Different X scaling
