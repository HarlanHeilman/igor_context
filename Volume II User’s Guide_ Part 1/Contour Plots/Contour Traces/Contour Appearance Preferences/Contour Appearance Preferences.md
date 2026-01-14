# Contour Appearance Preferences

Chapter II-15 — Contour Plots
II-380
Another solution is to shift the contour level slightly down from a peak or up from a valley. Or you could 
choose a new set of levels that don’t include the level exhibiting the problem. See Contour Levels on page 
II-368.
Crossing Contour Lines
Contour lines corresponding to different levels will not cross each other, but contour lines of the same level 
may appear to intersect. This typically happens when a contour level is equal to a “saddle point” of the sur-
face. An example of this is a contour level of zero for the function:
z= sinc(x) - sinc(y)
You should shift the contour level away from the level of the saddle point. See Contour Levels on page 
II-368.
Flat Areas in the Contour Data
Patches of constant Z values in XYZ triplet data don’t contour well at those levels. If the data has flat areas 
equal to 2.0, for example, a contour level at Z=2.0 may produce ambiguous results. Gridded contour data 
does not suffer from this problem.
You should shift the contour level above or below the level of the flat area. See Contour Levels on page 
II-368.
Contour Preferences
You can change the default appearance of contour plots by capturing preferences from a prototype graph 
containing contour plots.
Create a graph containing one or more contour plots having the settings you use most often. Then choose 
Capture Graph Prefs from the Graph menu. Select the Contour Plots category, and click Capture Prefs.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. This is discussed in more detail in Chapter III-18, Preferences.
The Contour Plots category includes both contour appearance settings and axis settings.
Contour Appearance Preferences
The captured contour appearance settings are automatically applied to a contour plot when it is first cre-
ated, provided preferences are turned on. They are also used to preset the Modify Contour Appearance 
dialog.
If you capture the contour plot preferences from a graph with more than one contour plot, the first contour 
plot appended to a graph gets the settings from the contour first appended to the prototype graph. The 
second contour plot appended to a graph gets the settings from the second contour plot appended to the 
prototype graph, etc. This is similar to the way XY plot wave styles work.
z= sinc(x) - sinc(y)
6
5
4
3
6
5
4
3
 -0.2 
 0 
 0.4 
 0.2 
 0.2 
 0 
 0 
 0 
 -0.4 
 -0.2
