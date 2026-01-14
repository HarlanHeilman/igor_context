# DrawAction

DrawAction
V-172
Details
DPSS generates Slepian's Discrete Prolate Spheroidal Sequences in a 2D double-precision wave of 
dimensions numPoints by numWindows.
If you do omit /DEST the operation creates the output wave M_DPSS in the current data folder. The 
sequences/tapers are arranged as columns in the output wave.
Examples
DPSS/DEST=dpss5 1000,5
Display dpss5[][0],dpss5[][1],dpss5[][2],dpss5[][3],dpss5[][4]
ModifyGraph rgb(dpss5#1)=(0,65535,0),rgb(dpss5#2)=(1,16019,65535)
ModifyGraph rgb(dpss5#3)=(65535,0,52428),rgb(dpss5#4)=(0,0,0)
// Different sequences are orthogonal
MatrixOp/o aa=col(dpss5,1)*col(dpss5,4)
Integrate/METH=1 aa/D=W_INT
Print W_INT[numpnts(W_INT)-1]
See Also
MultiTaperPSD, WindowFunction, ImageWindow, Hanning
References
D. Slepian, "Prolate spheroidal wave functions, Fourier analysis and uncertainty -- V: The discrete case.", 
Bell Syst. Tech J., vol 57 pp. 1317-1430, May 1978.
DrawAction 
DrawAction [/L=layerName/W=winName] keyword = value [, keyword = value …]
The DrawAction operation deletes, inserts, and reads back a named drawing object group or the entire 
draw layer.
Parameters
DrawAction accepts multiple keyword = value parameters on one line.
/NW=nw
Specifies the time-bandwidth product. This value should typically be in the range 
[2,6]. Given a time-bandwidth product nw it is recommended to use no more than 
2*nw tapers in order to maximize variance efficiency. The default value of the time-
bandwidth product is 3.
/DTPS=sumsWave
Saves the sums of the generated DPSS windows in a wave specified by sumsWave.
/Q
Suppress printing information in the history.
/Z
Suppress errors. The variable V_Flag is set to 0 if successful and to -1 otherwise.
beginInsert [=index]
Inserts draw commands before or at index position or at position specified by 
getgroup or delete parameters; position otherwise is zero.
commands [=start,stop] Stores commands in S_recreation for draw objects between start and stop index 
values, range defined by getgroup, or entire layer otherwise.
delete [=start,stop]
Deletes draw objects between start and stop index values, range defined by 
getgroup, or entire layer otherwise.
extractOutline 
[=start,stop]
Stores polygon outline between start and stop index values, range defined by 
getgroup, or entire layer otherwise. Waves W_PolyX and W_PolyY contain 
coordinates with NaN separators. V_npnts contains the number of objects, 
V_startPos contains the starting index value and V_endPos contains the ending 
index value. Coordinates are for the first object encountered.
endInsert
Terminates insert mode.
getgroup=name
Stores first and last index of named group in V_startPos and V_endPos. Use 
_all_ to specify the entire layer. Sets V_flag to truth group exists.

DrawAction
V-173
Flags
Details
Commands stored in S_recreation are the same as those that would be generated for the range of objects in 
the recreation macro for the window but also have comment lines preceding each object of the form:
// ;ITEMNO:n;
where n is the item number of the draw object.
Examples
Create a drawing with a named group:
NewPanel /W=(455,124,936,413)
SetDrawEnv fillfgc= (65535,0,0)
DrawRect 58,45,132,103
SetDrawEnv gstart,gname= fred
SetDrawEnv fillfgc= (65535,43690,0)
DrawRect 79,62,154,120
SetDrawEnv arrow= 1
DrawLine 139,70,219,70
SetDrawEnv gstop
SetDrawEnv fillfgc= (0,65535,65535)
DrawRect 95,77,175,138
SetDrawEnv fillfgc= (0,0,65535)
DrawRect 111,91,191,156
Get and print commands for the “fred” group:
DrawAction getgroup=fred,commands
Print S_recreation
prints:
// ;ITEMNO:2;
SetDrawEnv gstart,gname= fred
// ;ITEMNO:3;
SetDrawEnv fillfgc= (65535,43690,0)
// ;ITEMNO:4;
DrawRect 79,62,154,120
// ;ITEMNO:5;
SetDrawEnv arrow= 1
// ;ITEMNO:6;
DrawLine 139,70,219,70
// ;ITEMNO:7;
SetDrawEnv gstop
Replace group fred (the orange rectangle and the arrow) with a different object. First delete the group and 
enter insert mode:
DrawAction getgroup=fred, delete, begininsert
Next draw the replacement:
SetDrawEnv gstart,gname= fred
SetDrawEnv fillfgc= (65535,65535,0)
DrawOval 82,62,161,123
SetDrawEnv gstop
Lastly exit insert mode:
DrawAction endinsert
See Also
The SetDrawEnv operation and Chapter III-3, Drawing.
/L=layerName
Specifies the drawing layer on which to act. layerName is one of the drawing layers 
as specified in SetDrawLayer.
/W=winName
Sets the named window or subwindow for drawing. When omitted, action will 
affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
