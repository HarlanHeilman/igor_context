# Exporting a Graphic File for Transfer to a Windows Computer

Chapter III-5 — Exporting Graphics (Macintosh)
III-98
Choosing a Graphics Format
Because of the wide variety of types of graphics, destination programs, printer capabilities, operating 
system behaviors and user-priorities, it is not possible to give definitive guidance on choosing an export 
format. But here is an approach that will work in most situations.
If the destination program accepts PDF or SVG, then they are probably your best choice because of their 
high-quality vector graphics and platform-independence.
Encapsulated PostScript (EPS) is also a very high quality format which works well if the destination 
program supports it but it does not support transparency.
If SVG, PDF and EPS are not appropriate, your next choice would be a high-resolution bitmap. The PNG 
format is preferred because it is platform-independent and is compressed.
Exporting Graphics Via the Clipboard
To export a graphic from the active window via the clipboard, choose EditExport Graphics. This displays 
the Export Graphics dialog.
When you click the OK button, Igor copies the graphics for the active window to the clipboard. You can 
then switch to another program and do a paste.
When a graph, page layout, or Gizmo plot is active and in operate mode, choosing EditCopy copies to 
the clipboard whatever format was last used in the Export Graphics dialog. For a table, EditCopy copies 
the selected numbers to the clipboard and does not copy graphics.
When a page layout has an object selected or when the marquee is active, choosing EditCopy copies an 
Igor object in a format used internally by Igor along with a PDF and does not use the format from the Export 
Graphics dialog
Although Igor can export a number of different formats, not all programs can recognize them on the clip-
board. You may need to export via a file.
Igor can export PNG images to the clipboard and can then paste them back in. On the Macintosh, the clip-
board type is 'PNGf' but because there is no standard for PNG on the clipboard it is therefore unlikely that 
other programs can import them except as files.
Exporting Graphics Via a File
To export a graphic from the active window via a file, choose FileSave Graphics. This displays the Save 
Graphics File dialog.
The controls in the Format area of the dialog change to reflect options appropriate to each export format.
When you click the Do It button, Igor writes the graphic to a file. You can then switch to another program 
and import the file.
If you select _Use Dialog_ from the Path pop-up menu, Igor presents a Save File dialog in which you can 
specify the name and location of the saved file.
Exporting a Graphic File for Transfer to a Windows Computer
The best method for transferring Igor graphics to a Windows computer is to transfer the entire Igor exper-
iment file, open it in Igor for Windows, and export the graphic via one of the Windows-compatible methods 
available in Igor for Windows.
Prior to Igor Pro 9, PDF pictures were not displayed by Igor on Windows. They are nowrendered as high-
resolution bitmaps.
