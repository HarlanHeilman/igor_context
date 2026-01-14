# Gizmo Unnamed Hook Functions

Chapter II-17 — 3D Graphics
II-473
case "killed":
break
case "scaling":
break
endswitch
return 0 
End
See WMGizmoHookStruct for details on the structure.
As of this time the following event names are defined: mouseDown, mouseMoved, rotation, killed and scal-
ing.
For an example using a named Gizmo window hook, open the Gizmo Window Hook demo experiment and 
look at the GizmoRotationNamedHook function in the GizmoRotation.ipf procedure file. This is a packed 
procedure file. It is in an independent module so you need to enable Independent Modules to see it.
Gizmo Unnamed Hook Functions
Unnamed hooks are obsolete though still supported for backward compatibility. Use named hooks instead. 
The following documentation is for historical reference only.
Each Gizmo window can have one and only one unnamed Gizmo window hook function. You designate a 
function as the unnamed window hook function using the ModifyGizmo operation with the hookFunction 
keyword.
The unnamed hook function is called when various window events take place. The reason for the hook 
function call is stored as an event code in the hook function's infoStr parameter. Certain events must be 
enabled using the ModifyGizmo operation with the hookEvents keyword.
The unnamed hook function has the following syntax:
Function functionName(infoStr)
String infoStr
String event = StringByKey("EVENT",infoStr)
...
return 0
// Return value is ignored
End
infoStr is a string which containing a semicolon-separated list of keyword:value pairs. For documentation 
see “Gizmo Unnamed Hook Functions” in the “3D Graphics” help file.

Chapter II-17 — 3D Graphics
II-474
