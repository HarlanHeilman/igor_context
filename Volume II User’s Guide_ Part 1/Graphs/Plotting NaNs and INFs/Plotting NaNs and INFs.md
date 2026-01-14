# Plotting NaNs and INFs

Chapter II-13 — Graphs
II-284
If you remove the last item associated with a given axis then that axis will also be removed.
Replacing Traces
You can “replace” a trace in the sense of changing the wave that the trace is displaying in a graph. All the 
other characteristics of the trace, such as mode, line size, color, and style, remain unchanged. You can use 
this to update a graph with data from a wave other than the one originally used to create the trace.
To replace a trace, use the Replace Wave item in the Graph menu to display the Replace Wave in Graph dialog:
A special mode allows you to browse through groups of data sets composed of identically-named waves 
residing in different data folders. For instance, you might take the same type of data during multiple runs 
on different experimental subjects. If you store the data for each run in a separate data folder, and you give 
the same names to the waves that result from each run, you can select the Replace All in Data Folder check-
box and then select one of the data folders containing data from a single run. All the waves in the chosen 
data folder whose names match the names of waves displayed in the graph will replace the same-named 
waves in the graph.
You can also replace waves one at a time with any other wave. With the Replace All in Data Folder checkbox 
unchecked, choose a trace from the list below the menu. To replace the Y wave used by the trace, check the 
Y checkbox; to replace the X wave check the X checkbox. You can replace both if you wish. Select the waves 
to use as replacements from the menus to the right of the checkboxes. You can select _calculated_ from the 
X wave menu to remove the X wave of an XY pair, converting it to a waveform display.
The menus allow you to select waves having lengths that don’t match the length of the corresponding X or 
Y wave. In that case, use the edit boxes to the right to select a sub-range of the wave’s points. You can also 
use these boxes to select a single row or column from a two-dimensional wave.
The dialog creates command lines using the ReplaceWave operation (page V-801).
Plotting NaNs and INFs
The data value of a wave is normally a finite number but can also be a NaN or an INF. NaN means “Not a 
Number”, and INF means “infinity”. An expression returns the value NaN when it makes no sense math-
ematically. For example, log(-1) returns the value NaN. You can also set a point to NaN, using a table or 
a wave assignment, to represent a missing value. An expression returns the value INF when it makes sense 
mathematically but has no finite value. log(0) returns the value -INF.
Igor ignores NaNs and INFs when scaling a graph. If a wave in a graph is set to lines between points mode 
then Igor draws lines toward an INF. By default, it draws no line to or from a NaN so a NaN acts like a 
missing value. You can override the default, instructing Igor to draw lines through NaNs using the Gaps 
checkbox in the Modify Trace Appearance dialog.
The following graph illustrate these points. It was created with these commands:
Make wave1= log(abs(x-64))
wave1(40)=log(-1)
Display wave1
