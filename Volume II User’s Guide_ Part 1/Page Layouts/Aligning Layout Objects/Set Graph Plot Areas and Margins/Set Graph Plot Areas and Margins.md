# Set Graph Plot Areas and Margins

Chapter II-18 — Page Layouts
II-492
Set Width and Height of Layout Objects
Set the width and height of one of the graph objects by selecting it and dragging the resulting handles or by 
double-clicking it and entering values in the Modify Objects dialog.
Click in a blank part of the page to deselect all objects. Now click the object whose dimensions you just set. 
Now Shift-click to select the other graph objects. With all of the graph objects selected, choose Make Same 
Width And Height from the Layout menu.
Set Vertical Positions of Layout Objects
Drag the graph objects to their approximate desired positions on the page. You can drag an object vertically 
without affecting its horizontal position by pressing Shift while dragging. You must press Shift after click-
ing the object - otherwise the Shift-click will deselect it. Once you have set the approximate position, fine 
tune the vertical positions using the arrow keys to nudge the selected object.
Set Graph Plot Areas and Margins
At this point, your axes would be aligned except for one subtle thing. The width of text (e.g., tick mark 
labels) in the left margin of each graph can be different for each graph. For example, if one graph has left 
axis tick mark labels in the range of 0.0 to 1.0 and another graph has labels in the range 10,000 to 20,000, Igor 
would leave more room in the left margin of the second graph. The solution to this problem is to set the 
graph margins, as well as the width of the plot areas, of each graph to the same specific value.
To do this, select all of the graph objects and then choose Make Plot Areas Uniform from the Layout menu. 
This invokes the following dialog:
Because we are stacking graphs vertically, we want their horizontal margins and plot areas to be the same, 
which is why we have selected Horizontally from the pop-up menu. The three checkboxes are selected 
because we want to set both the left and right margins as well as the plot area width.
Now click each of the three Estimate buttons. When you click the Estimate button next to the Set Left 
Margins To checkbox, Igor sets the corresponding edit box to the largest left margin of all of the graphs 
selected in the list. Igor does a similar thing for the other two Estimate buttons. As a result, after clicking 
the three buttons, you should have reasonable values. Click Do It.
Now examine the stacked graph objects. It is possible that you may want to go back into the Make Plot 
Areas Uniform dialog to manually tweak one or more of the settings.
