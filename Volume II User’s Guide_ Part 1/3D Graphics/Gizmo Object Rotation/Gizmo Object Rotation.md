# Gizmo Object Rotation

Chapter II-17 — 3D Graphics
II-424
Viewport
A viewport is the rectangular 2D region of the window where the projected scene is drawn. You can use 
this to scale and distort the scene in the Gizmo display window.
The viewport projection depends on 4 parameters: left, bottom, width and height.
LookAt
A LookAt projection maps the center point to the negative Z axis, the eye point to the center, and the up 
vector to the Y axis. It may be useful if you want to change the origin of the coordinate system and the basic 
orientation.
Gizmo Object Rotation
You can click in a Gizmo display and drag the mouse to rotate the plot. The default rotation is implemented 
as if there is a virtual trackball in the center of the Gizmo window. Rotation through a positive angle is in a 
counterclockwise direction when viewed along the ray from the origin.
When experimenting with rotation it is helpful to display the axis cue which shows the X, Y and Z direc-
tions. Right-click and choose Show Axis Cue. The axis cue shows the orientation of the main Gizmo axes.
You can rotate the plot using the keyboard when a Gizmo display window is active. Press the x, y, or z keys 
to rotate the display counterclockwise in 1-degree increments about the respective axis. Press the shift key 
along with x, y, or z to rotate clockwise.
The up arrow and down arrow keys rotate the plot about a horizontal line drawn through the middle of the 
display area. The left arrow and right arrow keys rotate the plot about a vertical line drawn through the 
middle of the display area.
By default the mouse scroll wheel zooms the plot. You can change it to rotate the plot using a miscellaneous 
setting. Choose MiscMiscellaneous Settings and click Gizmo in the list on the left to see the Gizmo mis-
cellaneous settings. Using the mouse scroll wheel for scrolling behaves the same as using the arrow keys.
You can start the 3D scene rotating continuously by clicking and gently flinging with the mouse. This 
requires releasing the mouse button before stopping mouse movement. Click the plot once to stop contin-
