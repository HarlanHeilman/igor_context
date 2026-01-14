# Creating Controls

Chapter III-14 — Controls and Control Panels
III-419
Here is a sampling of the forms that ValDisplay controls can assume.
When a thermometer bar is shown, the left edge of the thermometer region represents a low limit set by the 
programmer while the right edge represents a high limit. The low and high limits appear in some of the 
above examples. The bar is drawn from a nominal value set by the programmer and will be red if the 
current value exceeds the nominal value and will be blue if it is less than the nominal value. In the above 
examples the nominal value is 60. There is no numeric indication of the nominal value. If the nominal value 
is less than the low limit then the bar will grow from the left to the right. If the nominal value is greater than 
the high limit then the bar will grow from the right to the left.
If you carefully observe a thermometer bar that is connected to an expression whose value is slowly chang-
ing with time you will see that the bar is drawn in a zig-zag fashion. This provides a much finer resolution 
than if the bar were to be extended or contracted by an entire column of screen pixels at once.
Creating Controls 
The ease of creating the various controls varies widely. Anyone capable of writing a simple procedure can 
create buttons and checkboxes, but creating charts and custom controls requires more expertise. Most con-
trols can be created and modified using dialogs that you invoke via the Add Controls submenu in the Graph 
or Panel menu.
The Add Controls and Select Control menus are enabled only when the arrow tool in the tool palette is 
selected. To do this, choose Show Tools from the Graph or Panel menu and then click the second icon from 
the top in the graph or panel tool palette.
You can temporarily use the arrow tool without the tool palette showing by pressing Command-Option 
(Macintosh) or Ctrl+Alt (Windows). While you press these keys, the normally-disabled Add Controls and 
Select Control submenus are enabled.
When you click a control with the arrow tool, small handles are drawn that allow you to resize the control. 
Note that some controls can not be resized in this way and some can only be resized in one dimension. You 
will know this when you try to resize a control and it doesn’t budge. You can also use the arrow tool to repo-
sition a control. You can select a control by name with the Select Control submenu in the Graph or Panel menu.
With the arrow tool, you can double-click most controls to get a dialog that modifies or duplicates the con-
trol. Charts and CustomControls do not have dialog support.
When you right-click (Windows) or Control-click (Macintosh) a control, you get a contextual menu that varies 
depending on the type of control.
