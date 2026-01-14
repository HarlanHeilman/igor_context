# Info Panel and Cursors

Chapter II-13 — Graphs
II-319
The Character submenu presents a palette from which you can select special characters to add to the axis 
label.
The Marker submenu inserts a code to draw a marker symbol. These symbols are independent of any traces 
in the graph.
Axis Label Units
The items in the Units pop-up menu insert escape codes that allow you to create an axis label that automat-
ically changes when the extent of the axis changes.
For example, if you specified units for the controlling wave of an axis, you can make those units appear in 
the axis label by choosing the Units item from the Units pop-up menu. If appropriate Igor will automatically 
add a prefix (µ for micro, m for milli, etc.) to the label and will change the prefix appropriately if the extent 
of the axis changes. The extent of the axis changes when you explicitly set the axis or when it is autoscaled.
If you choose the Scaling or Inverse Scaling items from the Units pop-up menu, Igor automatically adds a 
power of 10 scaling (x10^3, x10^6, etc.) to the axis label if appropriate and changes this scaling if the extent 
of the axis changes. The Trial Exponent buttons determine what power is used only in the label preview so 
you can see what your label will look like under varying axis scaling conditions. Both of these techniques 
can be ambiguous — it is never clear if the axis has been multiplied by the scale factor or if the units contain 
the scale factor.
A less ambiguous method is to use the Exponential Prefix escape code. This is identical to the Scaling code except 
the “x” is missing. You can then use it in a context where it is clear that it is a multiplier of units. For example, if 
your axis range is 0 to 3E9 in units of cm/s, typing “Speed, \ucm/s” would create “Speed, 109cm/s”.
It is common to parenthesize scaling information in an axis label. For example the label might say “Joules 
(x106)”. You can do this by simply putting parentheses around the Scaling or Inverse Scaling escape codes. 
If the scaling for the axis turns out to be x100 Igor omits it and also omits the parentheses so you get “Joules” 
instead of “Joules (x100)” or “Joules()”.
If you do not specify scaling but the range of the axis requires it, Igor labels one of the tick marks on the axis 
to indicate the axis scaling. This is an emergency measure to prevent the graph from being misleading. You 
can prevent this from happening by inserting the Manual Override escape code, \u#2, into your label. No 
scaling or units information will be added at the location of the escape code or on the tick marks.
The situation with log axes is a bit different. By their nature, log axes never have to be scaled and units/scal-
ing escape codes are not used in axis labels. If the controlling wave for a log axis has units then Igor auto-
matically uses the units along with the appropriate prefix for each major tick mark label.
Annotations in Graphs
You can add text annotation to a graph by choosing GraphAdd Annotation. This displays the Add Anno-
tation dialog. If text annotation is already on the graph you can modify it by double-clicking it. This brings 
up the Modify Annotation dialog. See Chapter III-2, Annotations, for details.
Info Panel and Cursors
You can display an information panel (“info panel” for short) for a graph by choosing GraphShow Info. 
An info panel displays a precise readout of values for waves in the graph. To remove the info panel from a 
graph while the graph is the target window choose GraphHide Info.
You can use up to five different pairs of cursors (AB through IJ). To control which pairs are available, click 
the gear icon and select select cursor pairs from the Show Cursor Pairs submenu. By default, cursors beyond 
B use the cross and letter style.
