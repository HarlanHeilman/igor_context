# Exporting Gizmo Windows

Chapter II-17 — 3D Graphics
II-465
The window is printed at a multiple of screen resolution. The multiple is controlled by the Default Output 
Resolution Factor in the Gizmo section of the Miscellaneous Settings dialog which you can access via the 
Misc menu. The factory default value for this multiple is 2.
You can override the default printing resolution by executing:
ModifyGizmo outputResFactor = n
where n is a positive integer, typically 1, 2, 4 or 8. This applies to the active window only. It affects subse-
quent printing and overrides the Default Output Resolution Factor setting. This setting is not stored in the 
recreation macro for the Gizmo window and therefore does not persist. The maximum value of n that will 
work depends on the amount of video memory ( VRAM) that you have in your graphics hardware.
You can also improve the output by anti-aliasing objects. To do this, add to the display list a blend function 
with GL_SRC_ALPHA and GL_ONE_MINUS_SRC_ALPHA and add an enable operation with 
GL_LINE_SMOOTH. You can also enable the GL_POINT_SMOOTH to smooth points in a scatter object.
If you are unable to print an image from Gizmo you may have run out of VRAM. This may produce a blank 
or distorted graphic. Some of the things that you should try are:
•
Close any other Gizmo window that you might have open.
•
Reduce the size of the Gizmo display window.
•
Reduce the resolution as set by the Default Output Resolution Factor setting or via ModifyGizmo 
outputResFactor.
•
If you are working on a system with more than one monitor move the display window to the one 
driven by a graphics card with the most VRAM.
•
Run the experiment on hardware that has more VRAM.
Exporting Gizmo Windows
You can export a Gizmo plot using one of these techniques:
•
Choose FileSave Graphics to export to a PNG, JPEG or TIFF file. This generates a SavePICT com-
mand.
•
Choose EditExport Graphics to export to the clipboard as PNG, JPEG or TIFF.
•
Choose EditCopy. This exports to the clipboard using the settings last set in the Export Graphics 
dialog.
•
Right-click and choose Copy to Clipboard from the contextual pop-up menu. This is the same as 
choosing EditCopy.
The ExportGizmo operation is also available for backward compatibility only. It is obsolete and you should 
use SavePICT instead.
The Export Graphics dialog and the SavePICT operation give you control of the output resolution as a mul-
tiple of screen resolution. Exporting at high resolution requires sufficient video memory (VRAM). Most 
hardware supports 2x (two times screen resolution). You may be able to increase resolution further depend-
ing on the available VRAM.
If you are unable to export an image from Gizmo you may have run out of VRAM. This may produce a 
blank or distorted graphic. Some of the things that you should try are:
•
Close any other Gizmo window that you might have open.
•
Reduce the size of the Gizmo display window.
•
Reduce the resolution as set in the Export Graphics or Save Graphics dialogs.
•
If you are working on a system with more than one monitor move the display window to the one
