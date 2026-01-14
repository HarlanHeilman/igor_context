# Text Markers

Chapter II-13 — Graphs
II-293
By default, the interior color of opaque hollow markers is white. You can change the interior color by select-
ing a fill color in the Modify Trace Appearance dialog or with the ModifyGraph mrkFillRGB keyword. Here 
the fill is set using the command
ModifyGraph mrkFillRGB=(1,52428,26586)
It is possible to achieve identical results by setting the stroke color of a solid marker or the fill color of a 
hollow marker, as in the following example.
Trace color set to green:
Now set the stroke color set to black, resulting in solid markers having a black outline and green interior:
Finally set the fill color to green resulting in hollow markers being filled with green:
Now the solid and hollow markers look the same. This is a historical oddity - the fill color could not be 
changed from white before Igor Pro 9.00. Before Igor9 the hollow markers with interior markings such as 
11 or 42 could not be filled with a color.
Text Markers
In addition to the built-in drawn markers, you can also instruct Igor to use one of the following as text markers:
•
A single character from a font
•
The contents of a text wave
•
The contents of a numeric wave
A single character from a font is mainly of interest if you want to use a special symbol that is available in a 
font but is not included among Igor’s built-in markers. The specified character is used for all data points.
The remaining options provide a way to display a third value in an XY plot. For example, a plot of earthquake 
magnitude versus date could also show the location of the earthquake using a text wave to supply text mark-
ers. Or, a plot of earthquake location versus date could also show the magnitude using a numeric wave to 
supply text markers. For each data point in the XY plot, the corresponding point of the text or numeric wave 
supplies the text for the marker. The marker wave must have the same number of points as the X and Y waves.
