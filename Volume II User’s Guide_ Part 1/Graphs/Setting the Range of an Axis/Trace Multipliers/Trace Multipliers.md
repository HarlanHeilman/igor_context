# Trace Multipliers

Chapter II-13 — Graphs
II-302
This example uses double-backslashes because a single backslash is an escape character in Igor literal 
strings. Since we want a backslash in the final text, because that is what Igor requires for \k and \W, we 
need to use a double-backslash in the literal strings.
If you were to enter the legend text in the Add Annotation dialog, you would use just a single backslash 
and the dialog would generate the requires command, with double-backslashes.
Trace Offsets
You can offset a trace in a graph in the horizontal or vertical direction without changing the data in the associated 
wave. This is primarily of use for comparing the shapes of traces or for spreading overlapping traces out for 
better viewing.
Each trace has an X and a Y offset, both of which are initially zero. If you check the Offset checkbox in the 
Modify Trace Appearance dialog, you can enter an X and Y offset for the trace.
You can also set the offsets by clicking and dragging in the graph. To do this, click the trace you want to 
offset. Hold the mouse down for about a second. You will see a readout box appear in the lower left corner 
of the graph. The readout shows the X and Y offsets as you drag the trace. If it doesn’t take too long to 
display the given trace, you will be able to view the trace as you drag it around on the screen.
If you press Shift while offsetting a wave, Igor constrains the offset to the horizontal or vertical dimension.
You can disable trace dragging by pressing Caps Lock, which may be useful for trackball users.
Offsetting is undoable, so if you accidently drag a trace where you don’t want it, choose Edit Undo.
It is possible to attach a tag to a trace that will show its current offset values. See Dynamic Escape Codes 
for Tags on page III-38, for details.
If autoscaling is in effect for the graph, Igor tries to take trace offsets into account. If you want to set a trace’s 
offset without affecting axis scaling, use the Set Axis Range item in the Graphs menu to disable autoscaling.
When offsetting a trace that uses log axes, the trace offsets by the same distance it does when the axis is not 
log. The shape of the trace is not changed — it is simply moved. If you were to try to offset a trace by adding 
a constant to the wave’s data, it would distort the trace.
Trace Multipliers
In addition to offsetting a trace, you can also provide a multiplier to scale a trace. The effective value used 
for plotting is then multiplier*data+offset. The default value of zero means that no multiplier is provided, not 
that the data should be multiplied by zero.
With normal (not log) axes, you can interactively scale a trace using the same click and hold technique 
described for trace offsets. First place Cursor A somewhere on the trace to act as a reference point. Then, 
after entering offset mode by clicking and holding, press Option (Macintosh) or Alt (Windows) to adjust the 
multiplier instead of the offset. You can press and release the key as desired to alternate between scaling 
and offsetting.
1.0
0.8
0.6
0.4
0.2
0.0
-0.2
-0.4
-0.6
600
500
400
300
200
x10-9 
x offset= 7.39837e-08
y offset= -0.487352
