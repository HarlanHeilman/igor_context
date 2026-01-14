# Operation Result Displayer

Chapter II-11 — Dialog Features
II-230
Operation Result Displayer
In some Igor dialogs that perform numeric operations (Analysis menu: Integrate, Smooth, FFT, etc.) there is a 
group of controls allowing you to choose how to display the result. Choices are offered to put the result into 
the top graph, a new graph, the top table, or a new table. For two-dimensional results, New Image and New 
Contour are also offered. If the result is complex, as is the case for an FFT, New Contour is not available.
Here is what the Result Displayer looks like in the Smooth dialog:
The contents of the displayer are not available here because the Display Output Wave checkbox is not 
selected. This is the default state.
When you choose New Graph, there are four choices in the Graph menu for the contents and layout of the 
new graph. In this menu, Src stands for Source. It is the wave containing the input data; Output is the wave 
containing the result of the operation.
In many cases, the second choice, Src and Output, Same Axes, will not be appropriate because the operation 
changes the magnitude of data values or the range of the X values.
This picture shows the result of an FFT operation when Src and Output, Stacked Axes is chosen:
When you choose New Image or New Contour to display matrix results, the Graph Layout menu allows 
only Output Only or Src and Output, Stacked Axes. The axes aren’t really stacked - it makes side-by-side 
graphs. It makes little sense to put two images or two contours on one set of axes.
The Result Displayer doesn’t give you many options for formatting the graph, and doesn’t allow any 
control over trace style, placement of axes, etc. It is intended to be a convenient way to get started with a 
graph. You can then modify the graph in any way you choose.
If you want a more complex graph, you may need to use the New Graph dialog (choose New Graph from 
the Windows menu) after you have clicked Do It in an operation dialog.
If you choose Top Graph instead of New Graph, the output wave will be appended to the top graph. It is 
assumed that this graph will already contain the source wave, so there is no option to append the source 
wave to the top graph. The Graph layout menu disappears, and two menus are presented to let you choose 
axes for the new wave:
-1.0
-0.5
0.0
0.5
1.0
6
5
4
3
2
1
0
30
20
10
0
10
8
6
4
2
0

Chapter II-11 — Dialog Features
II-231
The menus allow you to choose the standard axes: left and right in the V Axis menu; top and bottom in the 
H Axis menu. If the top graph includes any free axes (axes you defined yourself) they will be listed in the 
appropriate menu as well.
In most cases the source wave will be plotted on the left and bottom axes. You will usually want to select 
the right axis because of the differing magnitude of data values that result from most operations. You may 
also want to select the top axis if the operation (like the FFT) changes the X range as well.
Here is the result of choosing right and top when doing an FFT (this is the same input data as in the graph above):
Note that the format of the graph is poor. We leave it to you to format it as you wish. If you want a stacked 
graph, it may be better to choose the New Graph option.
-1.0
-0.5
0.0
0.5
1.0
6
5
4
3
2
1
0
30
25
20
15
10
5
0
10
8
6
4
2
0

Chapter II-11 — Dialog Features
II-232
