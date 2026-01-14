# Ticks and Grids Tab

Chapter II-13 — Graphs
II-308
Normally you will adjust the axis offset by dragging the axis in the graph. If the mouse is over an axis, the 
cursor changes to a double-ended arrow indicating that you can drag the axis. If the axis is a mirror axis 
you will not be able to drag it and the cursor will not change to the double-ended arrow.
The Offset setting does not affect a free axis. To adjust the position of a free axis, use the settings in the Free 
Position section.
The Thickness setting sets the thickness of an axis and associated tick marks in points. The thickness can be 
fractional and if you set it to zero the axis and ticks disappear.
The free position can be adjusted by dragging the axis interactively. This is the recommended way to adjust 
the position when using the absolute distance mode but it is not recommended when using the “crossing 
at” mode. This is because the crossing value as set interactively will not be exact. You should use the Free 
Position controls to specify an exact crossing value.
The Font section of the Axis tab specifies the font, font size, and typeface used for the tick labels and the axis 
label. You should leave this setting at “default” unless you want this particular axis to use a font different from 
the rest of the graph. You can set the default font for all graphs using the Default Font item in the Misc menu. 
You can set the default font for a particular graph using the Modify Graph item in the Graph menu. The axis 
label font can be controlled by escape codes within the axis label text. See Axis Labels on page II-318.
Colors of axis components are controlled by items in the Color area.
Auto/Man Ticks Tab
The items in the Auto/Man Ticks tab control the placement of tick marks along the axis. You can choose one 
of three methods for controlling tick mark placement from the pop-up menu at the top of the tab.
Choose Auto Ticks to have Igor compute nice tick mark intervals using some hints from you.
Choose Computed Manual Ticks to take complete control over the origin and interval for placing tick 
marks. See Computed Manual Ticks on page II-312 for details.
Choose User Ticks from Waves to take complete control over tick mark placement and labelling. See User 
Ticks from Waves on page II-313 for details.
In Auto Ticks mode, you can specify a suggested number of major ticks for the selected axis by entering that 
number in the Approximately parameter box. The actual number of ticks on the axis may vary from the sug-
gested number because Igor juggles several factors to get round number tick labels with reasonable spacing in a 
common numeric sequence (e.g., 1, 2, 5). In most cases, this automatically produces a correct and attractive 
graph. The Approximately parameter is not available if the selected axis is a log axis.
You can turn minor ticks on or off for the selected axis using the Minor Ticks checkbox.
The Minimum Sep setting controls the display of minor ticks if minor ticks are enabled. If the distance between 
minor ticks would be less than the specified minimum tick separation, measured in points, then Igor picks a 
less dense ticking scheme. For log axes Minor Ticks and Tick Separation affect the drawing of subminor ticks.
Ticks and Grids Tab
The Ticks and Grids tab provides control over tick marks, tick mark labels, and grid lines.
Exponential Labels
When numbers that would be used to label tick marks become very large or very small, Igor switches to 
exponential notation, displaying small numbers in the tick mark labels and a power of 10 in the axis label. 
The use of the power of 10 in the axis label is covered under Axis Labels on page II-318. In the case of log 
axes, the tick marks include the power.
With the Low Trip and High Trip settings, you can control the point at which tick mark labels switch from 
normal notation to exponential notation. If the absolute value of the larger end of the axis is between the 

Chapter II-13 — Graphs
II-309
low trip and the high trip, then normal notation is used. Otherwise, exponential is used. However, if the 
exponent would be zero, normal notation is always used.
There are actually two independent sets of low trip and high trip parameters: one for normal axes and one 
for log axes. The low trip point can be from 1e-38 to 1 and defaults to 0.1 for normal axes and to 1e-4 for log 
axes. The high trip point can be from 1 to 1e38 and defaults to 1e4.
Under some circumstances, Igor may not honor your setting of these trip points. If there is no room for 
normal tick mark labels, Igor will use exponential notation, even if you have requested normal notation.
The Engineering and Scientific radio buttons allow you to specify whether tick mark labels should use engi-
neering or scientific notation when exponential notation is used. It does not affect log axes. Engineering 
notation is just exponential notation where the exponent is always a multiple of three.
With the Exponent Prescale setting, you can force the tick and axis label scaling to values different from 
what Igor would pick. For example, if you have data whose X scaling ranges from, say, 9pA to 120pA and 
you display this on a log axis, Igor will label the tick marks with 10pA and 100pA. But if you really want 
the tick marks labeled 10 and 100 with pA in the axis label, you can set the Exponent Prescale to 12. For 
details, see Axis Labels on page II-318.
Date/Time Tick Labels
The Date/Time Tick Labels area of the Ticks and Grids tab is explained under Date/Time Axes on page 
II-315.
Tick Dimensions
You can control the length and thickness of each type of tick mark and the location of tick marks relative to 
the axis line using items in the Tick Dimensions area. Igor distinguishes four types of tick marks: major, 
minor, “fifth”, and subminor:
The tick mark thicknesses normally follow the axis thickness. You can override the thickness of individual 
tick types by replacing the word “Auto” with your desired thickness specified in fractional points. A value 
of zero is equivalent to “Auto”.
The tick length is normally calculated based on the font and font size that will be used to label the tick 
marks. You can enter your own values in fractional points. For example you might enter a value of 6 for the 
major tick mark, 3 for the minor tick mark and 4.5 for the 5th or emphasized minor tick marks. The submi-
nor tick mark only applies to log axes.
Use the Location pop-up menu to specify that tick marks for the selected axis be outside the axis, crossing 
the axis or inside the axis or you can specify no tick marks for the axis at all.
Grid
Choose Off from the Grid pop-up menu if you do not want grid lines. Choose On for grid lines on major 
and minor tick marks. Choose Major Only for grid lines on major tick marks only.
Igor provides five grid styles identified with numbers 1 through 5. Different grid styles have major and 
minor grid lines that are light, heavy, dotted or solid. If the style is set to zero (the default) and the graph 
background is white then grid style 2 is used. If the graph background is not white then grid style 5 is used.
Use the Grid Color palette to set the color of the grid lines. They are by default light blue.
0.1
2
3
4
5
6
7
8
9 1
1.0
0.8
0.6
0.4
0.2
0.0
Fifth or Emphasized
Major
Minor
Subminor
Normal Axis
Log Axis
Major
Minor
