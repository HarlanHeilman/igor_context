# Gizmo 3D Scatter Plot and Fitted Surface Tour

Chapter II-17 — 3D Graphics
II-411
17.
Click the ColorScale Main tab and set the following controls as indicated:
Color Table: Rainbow
Axis Range/Top: 100
Axis Range/Bottom: 0
18.
Click Do It.
Igor creates the colorscale annotation.
Note that its tick mark labels don't agree with the Z axis tick mark labels in the surface plot. We 
need to set the colorscale range to match the range of the data. We will do this by re-executing 
the command that created the colorscale.
19.
Click on the last command in the history area of the command window and press Enter to copy 
it to the command line.
The command line should now show this:
ColorScale/C/N=text0/M/A=RC ctab={0,100,Rainbow,0}
20.
Edit the command as shown next and press Enter to execute it:
ColorScale/C/N=text0/M/A=RC ctab={WaveMin(data2D),WaveMax(data2D),Rainbow,0}
Now the colorscale tick mark labels agree with the Z axis tick mark labels in the surface plot.
Next we will add an image plot beneath the surface plot.
21.
In the Gizmo info window, click the "+" icon at the bottom of the object list and choose Image.
The Gizmo Image Properties dialog appears.
22.
Set the Source Type to 2D Matrix of Z Values, and select data2D from the Source Wave pop-
up menu.
We will use the same wave as the source for both the surface plot and the image.
23.
From the Intitial Orientation pop-up menu, choose XY Plane Z=0.
24.
Uncheck all checkboxes except Translate and set the X, Y, and Z components of the translation 
to 0, 0, and -1 respectively.
The translation in the Z direction moves the image from the center of the display volume to the 
bottom of the display volume, placing it on the "floor" of the surface plot.
25.
Click Do It.
Igor created an image object named image0 and added it to the object list in the info window. It 
is not yet visible in the Gizmo0 window because we have not yet added it to the display list.
26.
Drag the image0 object from the object list to the display list.
You now have an image plot below the surface plot. You may need to rotate the display to see it.
27.
Double-click the image0 object in the object list, set the Z translation to -1.5, then click Do It.
28.
This separates the image plot from the surface plot, making it easier to see.
The translation parameters are in +/-1 display volume units, not in the units of the axes. Display 
volume units are used in many instances, especially when dealing with drawing objects such as 
spheres and boxes.
29.
Choose FileSave Experiment and save the experiment as "Gizmo Surface Plot Tour.pxp".
This is just in case you want to revisit the tour later and is not strictly necessary.
Gizmo 3D Scatter Plot and Fitted Surface Tour
In this tour we will create a 3D scatter plot from a triplet wave, perform a curve fit, and append a surface 
showing how the curve fit output relates to the original scatter data.
1.
Start a new experiment by choosing FileNew Experiment.
2.
To create a triplet wave containing XYX scatter data, execute:
