# Types of Axes

Chapter II-13 — Graphs
II-279
The advanced version of the dialog includes two-dimensional waves in the Y Waves and X Wave lists. You 
can edit the range values for waves in the holding pen to specify individual rows or columns of a matrix or 
to specify other subsets of data. See Subrange Display on page II-321 for details.
Waves and Axes
Axes are dependent upon waves for their existence. If you remove from a graph the last wave that uses a 
particular axis then that axis will also be removed.
In addition, the first wave plotted against a given axis is called the controlling wave for the axis. There is only 
one thing special about the controlling wave: its units define the units that will be used in creating the axis label 
and occasionally the tick mark labels. This is normally not a problem since all waves plotted against a given axis 
will likely have the same units. You can determine which wave controls an axis with the AxisInfo function.
Types of Axes
The four axes named left, right, bottom and top are termed standard axes. They are the only axes that many 
people will ever need.
Each of the four standard axes is always attached to the corresponding edge of the plot area. The plot area 
is the central rectangle in a graph window where traces are plotted. Axis and tick mark labels are plotted 
outside of this rectangle.
You can also add unlimited numbers of additional user-named axes termed free axes. Free axes are so 
named because you can position them nearly anywhere within the graph window. In particular, vertical 
free axes can be positioned anywhere in the horizontal dimension while horizontal axes can be positioned 
anywhere in the vertical dimension.
The Axis pop-up menu entries L=VertCrossing and B=HorizCrossing in the New Graph dialog create free 
axes that are each preset to cross at the numerical zero location of the other. They are also set to suppress 
the tick mark and label at zero. For example, create this data:
Make yWave; SetScale/I x,-1,1,yWave; yWave= x^3
Now, using the New Graph dialog, select yWave from the Y list and then L=VertCrossing from the Y axis 
pop-up menu. This generates the following command and the resulting graph:
Display/L=VertCrossing/B=HorizCrossing yWave
You could remove the tick mark and label at -0.5 by double-clicking the axis to reach the Modify Axis dialog, 
choosing the Tick Options tab, and finally typing -0.5 in one of the unused Inhibit Ticks boxes.
The free axis types described above all require that there be at least one trace that uses the free axis. For 
special purposes Igor programmers can also create a free axis that does not rely on any traces by using the 
NewFreeAxis operation (page V-679). Such an axis will not use any scaling or units information from any 
associated waves if they exist. You can specify the properties of a free axis using the SetAxis operation 
(page V-835) or the ModifyFreeAxis operation (page V-609), and you can remove them using the KillFree-
Axis operation (page V-470).
-1.0
-0.5
0.5
1.0
-1.0
-0.5
0.5
1.0
