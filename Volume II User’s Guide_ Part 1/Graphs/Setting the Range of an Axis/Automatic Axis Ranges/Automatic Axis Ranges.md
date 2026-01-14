# Automatic Axis Ranges

Chapter II-13 — Graphs
II-287
Graph menu or by double-clicking a tick mark label of the axis you wish to modify. Information on the other 
tabs in this dialog is available in Modifying Axes on page II-306.
Start by choosing the axis that you want to adjust from the Axis pop-up menu. You can adjust each axis in 
turn, or a selection of axes, without leaving this dialog.
Manual Axis Ranges
When a graph is first created, it is in autoscaling mode. In this mode, the axis limits automatically adjust to 
just include all the data. The controls in the Autoscale Settings section provide autoscaling options.
You can set the axis limits to fixed values by editing the minimum and maximum parameters in the Manual 
Range Settings section. You can return the minimum or maximum axis range to autoscaling mode by 
unchecking the corresponding checkbox. These settings are independent, so you can fix one end of the axis 
and autoscale the other end.
There are a number of other ways to set the minimum and maximum parameters. Clicking the Expand 5% 
button expands the range by 5 percent. This has the effect of shrinking the traces plotted on the axis by 5%.
Clicking the Swap button exchanges the minimum and maximum parameters. This has the effect of revers-
ing the ends of the axis, allowing you to plot waves upside-down or backwards with fixed limits.
An additional way to set the minimum and maximum parameters is to select a wave from the list and use 
the Quick Set buttons. If you click the X Min/Max quick set button then the minimum and maximum X 
values of the selected wave are transferred to the parameter boxes. If you click the Y Min/Max quick set 
button then the minimum and maximum Y values of the selected wave are transferred to the parameter 
boxes. If you specified the full scale Y values for the wave then you can click the Full Scale quick set button. 
This transfers the wave’s Y full scale values to the parameter boxes. The full scale Y values can be set using 
the Change Wave Scaling item in the Data menu.
Automatic Axis Ranges
When the manual minimum and maximum checkboxes are unchecked, the axis is in autoscaling mode. In 
this mode the axis limits are determined by the data values in the waves displayed using the selected axis. 
The items in the Autoscale Settings section control the method used to determine the axis range:
The Reverse Axis checkbox swaps the minimum and maximum axis range values, plotting the trace upside-
down or backwards.
The top pop-up menu controls adjustments to the minimum and maximum axis range values.
The default mode is “Use data limits”. The axis range is set to the minimum and maximum data values of 
all waves plotted against the axis.
The “Round to nice values” mode extends the axis range to include the next major tick mark.
The “Nice + inset data” mode extends the axis range to include the next major tick mark and also ensures 
that traces are inset from both ends of the axis.
The bottom pop-up menu controls the treatment f the value zero.
The default mode is “Zero isn’t special”. The axis range is set to the minimum and maximum data values.
The “Autoscale from zero” mode forces the end of the axis that is closest to zero to be exactly zero.
The “Symmetric about zero” mode forces zero to be in the middle of the axis range.
The “Autoscale from zero if not bipolar” mode behaves like “Autoscale from zero” if the data is unipolar 
(all positive or all negative) and like “Zero isn’t special” if the data is bipolar.
Autoscaling mode usually sets the axis limits using all the data in waves associated with the traces that use 
the axis. This can be undesirable if the associated horizontal axis is set to display only a portion of the total
