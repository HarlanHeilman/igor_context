# String Objects

Chapter II-17 — 3D Graphics
II-444
Use translate and rotate operations to position the disk in other locations and orientations.
These commands generate a disk with innerRadius=0.5, outerRadius=1, slices=10, stacks=5, startAngle=0, 
sweepAngle=360 and set its drawing style to lines:
AppendToGizmo/D disk={0.5,1,10,5,0,360}
ModifyGizmo modifyObject=disk0, objectType=Disk, 
property={useGlobalAttributes,0}
ModifyGizmo modifyObject=disk0, objectType=Disk, property={drawStyle,100011}
This command changes the disk to a partial disk with sweepAngle set to 270 instead of 360. SweepAngle is 
specified in degrees clockwise from startAngle:
ModifyGizmo modifyObject=disk0, objectType=Disk, property={sweepAngle,270}
String Objects
You can use standard Igor annotations in Gizmo as you do in graphs.
Annotations are 2D text graphics that lie flat in a plane in front of all 3D graphics. They are well suited for 
general labeling purposes. To create an annotation choose GizmoAdd Annotation and choose TextBox
