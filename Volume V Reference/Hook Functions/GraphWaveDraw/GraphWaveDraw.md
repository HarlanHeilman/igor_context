# GraphWaveDraw

Graph
V-325
Graph 
Graph
Graph is a procedure subtype keyword that identifies a macro as being a graph recreation macro. It is 
automatically used when Igor creates a window recreation macro for a graph. See Procedure Subtypes on 
page IV-204 and Saving and Recreating Graphs on page II-350 for details.
GraphMarquee 
GraphMarquee
GraphMarquee is a procedure subtype keyword that puts the name of the procedure in the graph Marquee 
menu. See Marquee Menu as Input Device on page IV-163 for details.
GraphNormal 
GraphNormal [/W=winName]
The GraphNormal operation returns the target or named graph to the normal mode, exiting any drawing 
mode that it may be in.
You would usually enter normal mode by choosing ShowTools from the Graph menu and clicking the 
graph tool (the top icon in the tool panel).
Flags
See Also
The GraphWaveDraw and GraphWaveEdit operations.
GraphStyle 
GraphStyle
GraphStyle is a procedure subtype keyword that puts the name of the procedure in the Style pop-up menu 
of the New Graph dialog and in the Graph Macros menu. See Graph Style Macros on page II-350 for details.
GraphWaveDraw 
GraphWaveDraw [flags] [yWave, xWave]
The GraphWaveDraw operation initiates drawing a curve composed of yWave vs xWave in the target or 
named graph. The user draws the curve using the mouse, and the values are stored in a pair of waves as 
XY data.
The user can manually initiate drawing by choosing ShowTools from the Graph menu and clicking in the 
appropriate tool.
Parameters
yWave and xWave can be simple names of waves in the current data folder or partial or full data folder paths 
to waves. If the waves already exist, GraphWaveDraw overwrites them. yWave and xWave can also be 
wave references pointing to existing waves in which case GraphWaveDraw overwrites them. Prior to Igor 
Pro 9.00, only simple names were accepted.
If yWave and xWave already exist, an error is generated unless you include the /O flag.
If you omit yWave and xWave then waves named W_YPolyn and W_XPolyn are created in the current data 
folder. n is an integer used to make the output wave names unique in their data folder, so Igor might create 
waves named W_XPoly0 and W_YPoly0, for example.
If there is no yWave vs xWave trace in the graph, GraphWaveDraw appends it.
Flags
/W=winName
Reverts the named graph window. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
/F[=f]
Initiates freehand drawing. In normal drawing, you click where you want a data point. 
In freehand drawing, you click once and then draw with the mouse button held down. 
If present, f specifies the smoothing factor. Max value is 8 (which is really slow), min 
value is 0 (default). The drawing tools use a value of 3 which is the recommended value.
