# Subrange Display Limitations

Chapter II-13 — Graphs
II-322
You can enter [] or [*] to indicate the entire range of the dimension, or [start,stop] for a contiguous 
subrange, or [start,stop;inc] where start, stop, and inc are dimension indices. Entering * for 
stop is the same as enteringthe index of the last element in the dimension.
For example:
Make/N=100 w1D = p
Display w1D[0,*;10]
// Display every tenth point
ModifyGraph mode=3, marker=19
Make/N=(10,8) w2D = p + 10*q
Display w2D[0][0,*;2]
// Display every other column of row 0
ModifyGraph mode=3, marker=19
The subrange syntax rules can be restated as:
For non-XY plots, the X-axis label uses the dimension label (if any) for the active dimension (the one with a 
range).
When cursors or tags are placed on a subranged trace, the point number used is the virtual point number 
as if the subrange had been extracted into a 1D wave.
Subrange syntax is also supported for waves used with error bars and with color, marker size and marker 
number as f(Z). These correspond to the ErrorBars operation (page V-199) with the wave keyword and to 
the ModifyGraph (traces) operation (page V-613) with the zmrkSize, zmrkNum, and zColor keywords.
Subrange Display Limitations
In category plots, the category wave (the text wave) may not be subranged. Waves used to specify text using 
ModifyGraph textMarker mode may not be subranged.
Subranged traces may not be edited using the draw tools (such as: option click on the edit poly icon in the 
tool palette on a graph).
Waterfall plots may not use subranges.
When multiple subranges of the same wave are used in a graph, they are distinguished only using instance 
notation and not using the subrange syntax. For example, given display w[][0],w[][1], you must use 
ModifyGraph mode(w#0)=1,mode(w#1)=2 and not ModifyGraph 
mode(w[][0])=1,mode(w[][1])=2 as you might expect.
The trace instance and subrange used to plot given trace is included in trace info information. See Identi-
fying a Trace on page II-321.
1. Only one dimension specifier can contain the range to be displayed.
Legal syntax for range is:
[] or [*] for an entire dimension
[start,stop] for a subrange
stop may be *
stop must be >= start
The range is inclusive
[start,stop;inc] for a subrange with a positive increment
2. Other dimensions must contain a single numeric index or dimension label using % syntax.
Legal syntax for nonrange 
specifier is:
[index]
[%label]
3. Unspecified higher dimensions are treated as if [0] was specified.
