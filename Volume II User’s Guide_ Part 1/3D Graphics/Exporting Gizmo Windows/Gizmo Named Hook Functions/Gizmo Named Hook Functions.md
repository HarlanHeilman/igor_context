# Gizmo Named Hook Functions

Chapter II-17 — 3D Graphics
II-472
In Igor7 and later you can add standard Igor annotations, including textboxes and colorscales, to a Gizmo 
window using GizmoAdd Annotation. These annotations appear in an overlay in front of the 3D graph-
ics and behave like annotations in a graph window.
Miscellaneous Gizmo Changes
In Igor7 and later arguments to the shininess attribute have changed to front and back values.
In Igor7 and later a Gizmo object optionally has an internal color attribute. When you create an object you 
have the option to specify a color or to leave it unspecified. If you specify a color, Gizmo creates a default 
color material for the object. The default color material has the GL_FRONT_AND_BACK and GL_AMBI-
ENT_AND_DIFFUSE settings. If you don't specify a color then Gizmo does not create a default color mate-
rial and you must create a color material yourself. This color material affects all objects that appear later in 
the display list if they have no default color material. This change was necessary in order to support creation 
of shiny surfaces.
Gizmo Hook Functions
This section is for advanced programmers only.
A hook function is a user-defined function called by Igor when certain events occur. It allows a programmer 
to react to events and possibly modify Igor's behavior. A window hook function is a hook function that is 
called for events in a particular window.
Igor's support for this feature is described under Window Hook Functions on page IV-293 and, as of Igor7, 
applies to Gizmo as well as other types of windows.
Because Gizmo was previously implemented as an XOP, it has its own hook function mechanism separate 
from the Igor mechanism. This section describes Gizmo's specific hook function support.
You can use either Igor hook functions or Gizmo hook functions or both for a Gizmo window. However 
using both may lead to confusion. If you install both an Igor hook function and a Gizmo hook function on 
a given Gizmo window, the Igor hook function is called first.
As in Igor itself, Gizmo originally had just one window hook function, installed by the ModifyGizmo hook-
Function keyword. Later a named hook function, installed by ModifyGizmo namedHook, was added. 
Unnamed hooks are obsolete. We recommend that you use named hooks.
Gizmo Named Hook Functions
A named Gizmo window hook function takes one parameter - a WMGizmoHookStruct structure. This 
built-in structure provides your function with information about the status of various window events.
You install a named Gizmo hook function using ModifyGizmo with the namedHook or namedHookStr 
keywords. The hookEvents keyword is not relevant for named hook functions.
The hook function should usually return 0. In the case of mouse wheel hook events returning a non-zero 
value prevents Gizmo from rotating in response to the wheel.
The named window hook function has this format:
Function MyGizmoHook(s)
STRUCT WMGizmoHookStruct &s
strswitch(s.eventName)
case "mouseDown":
break
case "mouseMoved":
break
case "rotation":
break
