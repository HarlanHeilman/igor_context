# Programmatic Drawing

Chapter III-3 — Drawing
III-73
Drawing and Editing Waves
In a graph, you can use the polygon tool to create or edit waves using the same techniques just described for 
drawing polygons. Click and hold on the polygon tool. Igor displays a pop-up menu containing, in addition to 
the usual polygon and Bezier commands, the following wave-drawing commands:
Draw Wave
Draw Wave Monotonic
Draw Freehand Wave
Draw Freehand Wave Monotonic
Edit Wave
Edit Wave Monotonic
The first four commands create and add a pair of waves with names of the form W_XPolynn and W_Y-
Polynn where nn are digits chosen to ensure the names are unique. Draw Wave and Draw Freehand Wave 
work exactly like the corresponding polygon drawing described above. The monotonic variants prevent 
you from backtracking in the X direction. As with polygons, you enter edit mode when you finish drawing.
You can edit an existing wave, or pair of waves if displayed as an XY pair, by choosing one of the Edit Wave 
commands and then clicking the wave trace you wish to edit. Again, the monotonic variant prevents back-
tracking in the X direction. If you edit a wave that is not displayed in XY mode then you can not adjust the 
X coordinates since they are calculated from point numbers.
You can use the GraphWaveDraw and GraphWaveEdit operations as described in Programmatic 
Drawing on page III-73 to start wave drawing or editing.
Drawing Exporting and Importing
Copy/Paste Within Igor
You can use the Edit menu to cut, copy, clear and paste drawing objects just as you would expect.
Drawn objects retain all of their Igor properties as long as they are not modified by any other program. If, 
however, you export an Igor drawing to a program and then copy it back to Igor, the picture will no longer 
be editable by Igor, even if you made no changes to the picture.
When selected drawing objects are copied to the clipboard and then pasted, they retain their coordinates. 
However, this can cause the pasted objects to be placed offscreen if the object’s coordinates don’t fall within 
the displayed portion of the coordinate systems.
If you find that pasting does not yield what you expected, perhaps it is because some objects were pasted 
off-screen. You can use the Mover icon to examine or retrieve any of these offscreen objects.
Pasting a Picture Into a Drawing Layer 
Pasting a picture from a drawing program may work differently than you expect. Igor does not attempt to take 
the picture apart to give you access to the component objects. Instead, Igor treats the entire picture as a single 
object that you can move and resize but not otherwise adjust.
You can change the scale of a pasted picture by either dragging the handles when the object is selected or 
by double-clicking the object and then setting the x and y scale factors in the resulting dialog.
Programmatic Drawing
All of the drawing capabilities in Igor can be used from Igor procedures. This section describes drawing 
programming in general terms and provides strategies for use along with example code.
The programmable nature is especially useful in creating new graph types. For example, even though Igor 
does not support polar plots as a native graph type we were able to create a polar plot package that pro-
duces high-quality polar graphs. (To see a demo of the package, choose FileExample Experi-
