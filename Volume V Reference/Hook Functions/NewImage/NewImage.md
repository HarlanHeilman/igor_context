# NewImage

NewGizmo
V-681
The type parameter can be either a code as documented for WaveType or can be 0x100 to create a data folder 
reference wave or 0x200 to create a wave reference wave.
You can redimension free waves as desired but, for maximum efficiency, you should create the wave with 
the desired type and total number of points and then use the /E=1 flag with Redimension to simply reshape 
without moving data.
A free wave is automatically discarded when the last reference to it disappears.
See Also
Free Waves on page IV-91, Make, Duplicate.
NewGizmo 
NewGizmo [flags]
The NewGizmo operation creates a new Gizmo display window.
Documentation for the NewGizmo operation is available in the Igor online help files only. In Igor, execute:
DisplayHelpTopic "NewGizmo"
NewImage 
NewImage [flags] matrix
The NewImage operation creates a new image graph much like “Display;AppendImage matrix” 
except the graph is prepared using a style more appropriate for images. Rather than using preferences, 
NewImage provides several discrete styles to choose from.
Parameters
matrix is usually an MxN matrix containing image data. See AppendImage for details.
Flags
/F
By default, the image is flipped vertically to correspond to normal image orientation. 
if /F is present then the image is not flipped.
/G=g
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/HOST=hcSpec
Embeds the new image plot in the host window or subwindow specified by hcSpec.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/K=k
/N=name
Requests that the created graph have this name, if it is not in use. If it is in use, then 
name0, name1, etc. are tried until an unused window name is found. In a function or 
macro, S_name is set to the chosen graph name.
Controls treatment of three-plane images as direct (RGB) color.
g=1:
Suppresses the autodetection of three-plane images as direct (RGB) color.
g=1:
Same as no /G flag (default).
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.
