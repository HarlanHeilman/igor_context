# Date/Time Example

Chapter II-13 — Graphs
II-316
In Igor, a date can not be accurately represented in a single precision wave. Make sure you use double precision 
waves to store dates and date/times. (A single precision wave can provide dates and date/times calculated from 
its X scaling, but not from its data values.)
For further discussion of how Igor represents dates, see Date/Time Waves on page II-85.
Times without dates can be thought of in two ways: as time-of-day times and as elapsed times.
Time-of-day times are represented in Igor as the number of seconds since midnight.
Elapsed times are represented as a number of seconds in the range -9999:59:59 to +9999:59:59. For integral 
numbers of seconds, this range of elapsed times can be precisely represented in a signed 32-bit integer 
wave. A single-precision floating point wave can precisely represent integral-second elapsed times up to 
about +/-4600 hours.
Igor displays dates or times on an axis if the appropriate units for the wave controlling the axis is “dat”. 
This is case-sensitive — “Dat” won’t work. You can set the wave’s units using the Change Wave Scaling 
item in the Data menu, or the SetScale operation.
To make a horizontal axis a date or time axis for a waveform graph, you must set the X units of the wave 
controlling the axis to “dat”. For an XY graph you must set the data units of the wave supplying the X coor-
dinates for the curve to “dat”. To make the vertical axis a date or time axis in either type of graph, you must 
set the data units of the wave controlling the axis to “dat”.
If you choose Date/Time as the axis mode in the Axis tab of the Modify Axis dialog, the dialog sets the 
appropriate wave units to “dat”.
For Igor to display an axis as date or time, the following additional restrictions must be met: the axis must 
span at least 2 seconds and both ends must be within the legal range for a date/time value. If any of these 
restrictions is not met, Igor displays a single tick mark.
When an axis is in the date/time mode, the Date/Time Tick Labels box in the Ticks and Grids tab of the 
Modify Axis dialog is available.
From the Time Format pop-up menu, you can choose Normal, Military, or Elapsed. Use Normal or Military 
for time-of-day times and Elapsed for elapsed times. In normal mode, the minute before midnight is dis-
played as 11:59:00 PM and midnight is displayed as 12:00:00 AM. In military mode, they are displayed as 
23:59:00 and 00:00:00.
Elapsed mode can display times from -9999:59:59 to +9999:59:59. This mode makes sense if the values dis-
played on the axis are actually elapsed times (e.g., 23:59:00). It makes no sense and will display no tick labels 
if the values are actually date/times (e.g., 7/28/93 23:59:00).
Custom Date Formats
In the short, long and abbreviated modes, dates are displayed according to system date/time settings. If you 
choose Other from the Date Format pop-up, a dialog is displayed giving you almost complete control over 
the format of the tick labels. The dialog allows you to choose from a variety of built-in formats or to create 
a fully custom format.
Depending on the extent of the axis, the tick mark labels may show date or date and time. You can suppress 
the display of the date when both the date and time are showing by selecting the Suppress Date checkbox. 
This checkbox is irrelevant when you choose the elapsed time mode in which dates are never displayed.
Date/Time Example
The following example shows how you can create a date/time graph of a waveform whose Y values are tem-
perature and whose X values, as set via the SetScale operation, are dates:
// Make a wave to contain temperatures for the year
Make /N=365 temperature
// single precision data values
