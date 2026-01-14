# Making a Window Recreation Macro

Chapter I-2 — Guided Tour of Igor Pro
I-26
15.
Click the graph’s zoom button (Macintosh) or maximize button (Windows).
To zoom the graph window on Macintosh, press the Option key while clicking the green button in the 
top/left corner of the window.
Notice how the rectangle and line expand with the graph. Their coordinates are measured relative to 
the plot area (rectangle enclosed by the axes).
16.
Click the graph’s zoom button (Macintosh) or restore button (Windows).
To restore the graph window on Macintosh, press the Option key while clicking the green button in 
the top/left corner of the window.
17.
Click the Arrow tool and then double-click the rectangle.
The Modify Rectangle dialog appears showing the properties of the rectangle.
18.
Enter 0 in the Thickness box in the Line Properties section.
This turns off the frame of the rectangle.
19.
Choose Solid from the Fill Mode pop-up menu.
20.
Choose a light gray color from the Fore Color pop-up menu under the Fill Mode pop-up menu.
21.
Click Do It.
Observe that the rectangle forms a gray area behind the traces and axes.
22.
Again, double-click the rectangle.
The Modify Rectangle dialog appears.
23.
From the X Coordinate pop-up menu, choose Axis Bottom.
The X coordinates of the rectangle will be measured in terms of the bottom axis — as if they were data 
values.
24.
Press Tab until the X0 box is selected and type “0”.
25.
Tab to the X1 box and type “1.6”.
26.
Tab to the Y0 box and type “0”.
27.
Tab to Y1 and type “1”.
The X coordinates of the rectangle are now measured in terms of the bottom axis and the left side will 
be at zero while the right side will be at 1.6.
The Y coordinates are still measured relative to the plot area. Since we entered zero and one for the Y 
coordinates, the rectangle will span the entire height of the plot area.
28.
Click Do It.
Notice the rectangle is nicely aligned with the axis and the plot area.
29.
Click the operate icon (
) to exit drawing mode.
30.
Press Option (Macintosh) or Alt (Windows), click in the middle of the plot area and drag about 2 
cm to the right.
The X axis range changes. Notice that the rectangle moved to align itself with the bottom axis.
31.
Choose EditUndo Modify.
Making a Window Recreation Macro
1.
Click the graph’s close button.
Igor presents a dialog which asks if you want to save a window recreation macro. The graph’s name is 
“Graph0” so Igor suggests “Graph0” as the macro name.
2.
Click Save.
Igor generates a window recreation macro in the currently hidden procedure window. A window rec-
reation macro contains the commands necessary to recreate a graph, table, page layout, control panel or 
3D plot. You can invoke this macro to recreate the graph you just closed.
