# WMGizmoHookStruct

WMFitInfoStruct
V-1107
Structure WMDrawUserShapeStruct
char action[32]
// Input: Specifies what action is requested.
Int32 options
// Input: Value from /MO flag.
// Output: When action is getInfo, set bits as follows:
// Set bit 0 if the shape should behave like a simple line.
 
// 
When resizing end-points, you will get live updates.
// Set bit 1 if the shape is to act like a button;
// 
You will get mouse down in normal operate mode.
// Set bit 2 to get roll-over action.
// 
You will get hitTest action and
// 
if 1 is returned, the mouse will be captured.
Int32 operateMode
// Input: If 0, the shape is being edited;
// if 1, normal operate mode
// (only if options bit 1 or 2 was set during getInfo).
PointF mouseLoc
// Input: The location of the mouse in normalized coordinates.
Int32 doSetCursor
// Output: If action is hitTest, set true
// to use the following cursor number.
// Also used for mouseMoved in rollover mode.
Int32 cursorCode
// Output: If action is hitTest and doSetCursor is set,
// then set this to the desired Igor cursor number.
double x0,y0,x1,y1
// Input: Coordinates of the enclosing rectangle of the shape.
RectF objectR
// Input: Coordinates of the enclosing rectangle of the shape
// in device units.
char winName[MAX_HostChildSpec+1] // Input: Full path to host subwindow
// Information about the coordinate system
Rect drawRect
// Draw rect in device coordinates
Rect plotRect
// In a graph, this is the plot area
Rect axRect
// In a graph, this is the plot area including axis standoff
char xcName[MAX_OBJ_NAME+1]
// Name of X coordinate system, may be axis name
char ycName[MAX_OBJ_NAME+1]
// Name of Y coordinate system, may be axis name
double angle
// Input: Rotation angle, use when displaying text
String textString
// Input: Use or ignore; special output for "getInfo"
String privateString
// Input and output: Maintained by Igor
// but defined by user function;
// may be binary; special output for "getInfo"
EndStructure
WMFitInfoStruct
See The WMFitInfoStruct Structure on page III-263 for further explanation of WMFitInfoStruct.
Structure WMFitInfoStruct
char IterStarted
// Nonzero on the first call of an iteration
char DoingDestWave
// Nonzero when called to evaluate autodest wave
char StopNow
// Fit function sets this to nonzero to
// indicate that a problem has occurred
// and fitting should stop
Int32 IterNumber
// Number of iterations completed
Int32 ParamPerturbed
// See The WMFitInfoStruct Structure on page III-263
EndStructure
WMGizmoHookStruct
See Gizmo Named Hook Functions on page II-472 for further explanation of WMGizmoHookStruct.
Structure WMGizmoHookStruct
Int32 version
char winName[MAX_HostChildSpec+1]
// Full path to host window or subwindow
char eventName[32]
Int32 width
Int32 height
Int32 mouseX
Int32 mouseY
Variable xmin
Variable xmax
