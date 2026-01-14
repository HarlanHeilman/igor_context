# Applying the Style Macro

Chapter II-13 — Graphs
II-351
When we click Do It, Igor generates a graph style macro and saves it in the procedure window.
The graph style macro for this example is:
Proc Graph0Style() : GraphStyle
PauseUpdate; Silent 1
// modifying window...
ModifyGraph/Z lStyle[1]=1,lStyle[2]=2,lStyle[3]=3,lStyle[4]=4
ModifyGraph/Z rgb[0]=(0,0,0)
ModifyGraph/Z rgb[1]=(3,52428,1)
ModifyGraph/Z rgb[2]=(1,12815,52428)
ModifyGraph/Z rgb[3]=(52428,1,41942)
ModifyGraph/Z rgb[4]=(65535,21845,0)
EndMacro
Notice that the graph style macro does not refer to wave0, wave1, wave2, wave3 or wave4. Instead, it refers 
to traces by index. For example,
ModifyGraph rgb[0]=(0,0,0)
sets the color for the trace whose index is 0 to black. A trace’s index is determined by the order in which the 
traces were displayed or appended to the graph. In the Modify Trace Appearance dialog, the trace whose 
index is zero appears at the top of the list.
The /Z flag used in the graph style macro tells Igor not to worry if the command tries to modify a trace that is not 
actually in the graph. For example, if you make a graph with three traces (indices from 0 to 2) and apply this style 
macro to it, there will be no trace whose index is 3 at the time you run the macro. The command:
ModifyGraph rgb[3]=(52428,1,41942)
would generate an error in this case. Adding the /Z flag continues macro execution and ignores the error.
Style Macros and Preferences
When Igor generates a graph style macro, it generates commands to modify the target graph according to 
the prototype graph. It assumes that the objects in the target will be in their factory default states at the time 
the style macro is applied to the target. Therefore, it generates commands only for the objects in the proto-
type which have been modified. If Igor did not make this assumption, it would have to generate commands 
for every possible setting for every object in the prototype and style macros would be very large.
Because of this, you should create the new graph with preferences off and then apply the style macro.
Applying the Style Macro
To use this macro, you would perform the following steps.
1.
Turn preferences off by choosing Preferences Off from the Misc menu.
2.
Create a new graph, using the New Graph dialog and optionally the Append Traces to Graph dialog.
3.
Choose Graph0Style from the Graph Macros submenu in the Windows menu.
4.
Turn preferences back on by choosing Preferences On from the Misc menu.
If you use only the New Graph dialog, you can use the shorter method:
