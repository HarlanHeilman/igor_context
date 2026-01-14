# Gizmo Object Rotation and Translation

Chapter II-17 — 3D Graphics
II-425
uous rotation. If the display pans instead of rotates then click the arrow tool in the Gizmo tool palette to 
enable rotation.
You can also start continuous rotation using the tool palette. Choose GizmoShow Tools and then click 
one of three rotation icons to start rotation about the X, Y or Z axis. Click the plot once or click the stop icon 
in the tool palette to stop rotation.
The Home icon in the tool palette rotates the scene to the home orientation. By default the home orientation 
is X=0, Y=0, Z=0. In this case, the positive X axis points to the right, the Y axis points up and the Z axis points 
out of the plane of the window toward you. You can set the home orientation by right-clicking and choosing 
Set Home Orientation.
During continuous rotation you can use the x, y and z keys to tweak the orientation.
Gizmo Object Rotation and Translation
In the preceding section we discussed rotation of the entire Gizmo plot about the main Gizmo axes. Each 
Gizmo object has its own set of axes which, by default, correspond to the main axes. Though this is less fre-
quently needed, it is possible to rotate a Gizmo object's axes independent of the main Gizmo axes. You do 
this by adding a rotate operation to the display list.
To see this we create a Gizmo with an axis cue and an unrotated box:
NewGizmo
ModifyGizmo showAxisCue=1
ModifyGizmo setQuaternion={0.435,-0.227,-0.404,0.777}
AppendToGizmo box={0.5,0.25,0.15}, name=box0
ModifyGizmo setDisplayList=0, object=box0
We then add a rotate operation to the display list, before the box object. This rotates the box object's axes by 
45 degrees:
ModifyGizmo insertDisplayList=0, opName=rotate0, operation=rotate, 
data={45,0,0,1}

Chapter II-17 — 3D Graphics
II-426
Now we insert a translation along the X axis:
ModifyGizmo insertDisplayList=1, opName=translate0, operation=translate, 
data={1,0,0}
The translation is along to the object's X axis, not the main X axis. Because of this, rotation followed by trans-
lation gives a different result than translation followed by rotation. To illustrate this we switch the order of 
the operations:
ModifyGizmo setDisplayList=0, opName=translate0, operation=translate, 
data={1,0,0}
ModifyGizmo setDisplayList=1, opName=rotate0, operation=rotate, data={45,0,0,1}
In this last case, at the time the translation was done, the object's axes were aligned with the main axes. The 
translation was along the object's X axis which pointed in the same direction as the main X axis.
Translate and rotate operations apply to all objects below them on the display list. They are cumulative. In 
other words, a translate or rotate operation on a given object starts from the current position or rotation of 
the object when the operation is applied.
