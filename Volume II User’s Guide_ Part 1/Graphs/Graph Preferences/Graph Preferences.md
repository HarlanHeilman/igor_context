# Graph Preferences

Chapter II-13 — Graphs
II-348
Note:
When graphs are redrawn in live mode, autoscaling is not done.
To specify a trace in a graph as being live you must use the live keyword with the ModifyGraph command. 
There is no dialog support for this setting.
ModifyGraph live(traceName)= mode
Mode can be 0 or 1. Zero turns live mode off for the given trace.
WaveMetrics provides a demo experiment that generates and displays synthetic data. You should use this 
experiment to get a feel for the performance you might expect on your particular computer as a function of 
the window size, number of points in the live wave, and the live modes. To run the demo, choose 
FileExample ExperimentsFeature DemosLive Mode.
Although live mode 1 is not restricted to unity thickness solid lines or dots modes, you will get the best per-
formance if you do use these settings.
Quick Append
Another feature that may be of use is the quick append mode. It is intended for applications in which a data 
acquisition task creates new waves periodically. It permits you to add the new waves to a graph very 
quickly. To invoke a quick append, use the /Q flag in an AppendToGraph command. There is no dialog 
support for this setting.
A side effect of quick append is that it marks the wave as not being modified since the last update of graphs 
and therefore prevents other graphs containing the same wave, if any, from being updated. For a demo, 
choose FileExample ExperimentsFeature DemosQuick Append.
Graph Preferences
Graph preferences allow you to control what happens when you create a new graph or add new traces to 
an existing graph. To set preferences, create a graph and set it up to your taste. We call this your prototype 
graph. Then choose Capture Graph Prefs from the Graph menu.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. This is discussed in more detail in Chapter III-18, Preferences.
When you initially install Igor, all preferences are set to the factory defaults. The dialog indicates which 
preferences you have not changed by displaying “default” next to them.
The Window Position and Size preference affects the creation of new graphs only. New graphs will have 
the same size and position as the prototype graph.
The Page Setup preference is somewhat unusual because all graphs share the same page setup settings, as 
shown in the Page Setup dialog. The captured page setup is already in use by all other graphs. The utility 
of this category is that new experiments will use the captured page setup for graphs.
The “XY Plots:Wave Styles” preference category refers to the various wave-specific settings in the graph, 
such as the line type, markers and line size, set with the Modify Trace Appearance dialog. This category 
also includes settings for waveform plots. Each captured wave style is associated with the index of the wave 
it was captured from. The index of the first wave displayed or appended to a graph is 0, the second 
appended wave has an index of 1, and so on.These indices are the same as are used in style macros. See 
Graph Style Macros on page II-350.
If preferences are on when a new graph with waves is created or when a wave is appended to an existing 
graph, the wave style assigned to each is based on its index. The wave with an index of 2 is given the cap-
tured style associated with index 2 (the third wave appended to the captured graph).
You might wonder what style is applied to the fifth and sixth waves if only four waves appeared in the 
graph from which wave style preferences were captured. You have two choices; either the factory default 
style is used, or the styles repeat with the first wave style and then the second style. You make this choice
