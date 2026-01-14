# Creating Controls

Chapter I-2 — Guided Tour of Igor Pro
I-41
22.
Resize and reposition the Graph0 and Graph1 windows so they are side-by-side and roughly 
square.
The graphs should look like this:
Creating a Page Layout
1.
Choose the WindowsNew Layout menu item and click Do It.
A new blank page layout window is created.
2.
Click in the graph icon (
) and choose “Graph0”.
Graph0 is added to the layout.
3.
Again, click in the graph icon and choose “Graph1”.
Graph1 is added to the layout.
4.
Click the marquee icon 
.
5.
Drag out a marquee that approximately fills the bottom half of the page.
6.
Choose LayoutArrange Objects.
The Arrange Objects dialog appears.
7.
Select both Graph0 and Graph1 and leave the Use Marquee checkbox checked.
8.
Click Do It.
The two graphs are tiled inside the area defined by the marquee.
9.
Click in the page area outside the marquee to dismiss it.
10.
Choose WindowsSend to Back.
This sends the page layout window behind all other windows.
Saving Your Work - Tour 1D
1.
Choose the FileSave Experiment As menu item.
2.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
3.
Type “Tour 1D.pxp” in the name box and click Save.
If you want to take a break, you can quit Igor Pro now.
Creating Controls
This section illustrates adding controls to an Igor graph — the type of thing a programmer might want to 
do. If you are not interested in programming, you can skip to the End of the General Tour on page I-45.
1.
If you are returning from a break, open your “Tour 1D.pxp” experiment and turn off preferences.

Chapter I-2 — Guided Tour of Igor Pro
I-42
2.
Click the graph with the spiral (Graph0) to bring it to the front.
3.
Choose the GraphShow Tools menu item or press Command-T (Macintosh) or Ctrl+T 
(Windows).
A tool palette is displayed to the left of the graph. The second icon is selected indicating that the graph 
is in the drawing as opposed to normal mode.
The selector tool (arrow) is active. It is used to create, select, move and resize controls.
4.
Choose GraphAdd ControlControl Bar.
The Control Bar dialog appears.
5.
Enter a height of 30 points and click Do It.
This reserves a space at the top of the graph for controls.
6.
Click in the command line, type the following and press Return or Enter.
Variable ymult=1, xmult=1
This creates two numeric variables and sets both to 1.0.
7.
Click Graph0 and then choose GraphAdd ControlAdd Set Variable.
The SetVariable Control dialog appears.
A SetVariable control provides a way to display and change the value of a variable.
8.
Choose ymult from the Value pop-up menu.
9.
Enter 100 in the Width edit box.
This setting is back near the top of the scrolling list.
10.
Set the High Limit, Low Limit, and Increment values to 10, 0.1, and 0.1 respectively.
You may need to scroll down to find these settings.
11.
From the Font Size pop-up menu, choose 12.
You may need to scroll down to find this pop-up menu.
12.
Click Do It.
A SetVariable control attached to the variable ymult appears in the upper-left of the control bar.
13.
Double-click the ymult control.
The SetVariable Control dialog appears.
14.
Click the Duplicate button at the bottom of the dialog.
15.
Choose xmult as the value.
16.
Click Do It.
A second SetVariable control appears in the control bar. This one is attached to the xMult variable.
17.
Choose GraphAdd ControlAdd Button.
The Button Control dialog appears.
18.
Tab to the Title edit box and enter “Update”.
19.
Click the New button adjacent to Procedure.
The Control Procedure dialog appears in which you can create or edit the procedure to be called when 
control-related events occur. Such procedures are called “control action procedures”.
20.
Make sure the “Prefer structure-based procedures” checkbox is checked.
21.
Edit the procedure text so it looks like this:
Function ButtonProc(ba) : ButtonControl
STRUCT WMButtonAction& ba
switch(ba.eventCode)
case 2:
// Mouse up
WAVE spiralX

Chapter I-2 — Guided Tour of Igor Pro
I-43
NVAR xmult
spiralX = x*cos(xmult*x)
WAVE spiralY
NVAR ymult
spiralY = x*sin(ymult*x)
break
endswitch
return 0
End
Proofread the function to make sure you entered it as shown above.
22.
Click the Save Procedure Now button.
The Control Procedure dialog disappears and the text you edited is inserted into the (currently hid-
den) procedure window.
23.
Click Do It.
A Button control is added to the control bar.
The three controls are now functional but are not esthetically arranged.
24.
Use the Arrow tool to rearrange the three controls into a more pleasing arrangement. Expand the 
button so it doesn’t crowd the text by dragging its handles.
After selecting a control with the arrow tool, you can drag it or use the arrow keys on the keyboard 
to finetune its position.
The graph now looks like this:
25.
Click the top icon in the tool palette to enter “operate mode”.
26.
Choose GraphHide Tools or press Command-T (Macintosh) or Ctrl+T (Windows).
27.
Click the up arrow in the ymult control.
The value changes to 1.1.
28.
Click the Update button.
The ButtonProc procedure that you created executes. The spiralY and spiralX waves are recalculated 
according to the expressions you entered in the procedure and the graphs are updated.
29.
Experiment with different ymult and xmult settings as desired.
