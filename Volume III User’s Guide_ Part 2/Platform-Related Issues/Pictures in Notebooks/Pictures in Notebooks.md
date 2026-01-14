# Pictures in Notebooks

Chapter III-15 — Platform-Related Issues
III-458
Pictures in Notebooks
If you want to display notebook pictures on both platforms, they must be in one of these cross-platform for-
mats: PDF, PNG, JPEG, TIFF, SVG.
PDF pictures are displayed correctly on Windows in Igor Pro 9.00 or later. In earlier versions on Windows, 
PDF pictures are displayed as gray boxes.
If you have pictures in other formats and you want them to be viewable on both platforms, you should 
convert them to PNG.
There are two ways to create a PNG picture in an Igor notebook. You can load it from a file using MiscPic-
tures and then place it in a notebook or you can convert a picture that you have pasted into a notebook using 
NotebookSpecialConvert to PNG.
The Convert to PNG command in the NotebookSpecial menu converts the selected picture or pictures into 
PNG. It skips selected pictures that are already PNG or that are foreign (not native to the platform on which you 
are running). You can determine the type of a picture in a notebook by clicking in it and looking at the notebook 
status line.
The Convert to PNG dialog allows you to choose the desired resolution. Usually 4x or 8x is best.
When you create a PNG file from within Igor, from a graph window for example, you can create it at screen 
resolution or at higher resolution. For good quality when viewed at higher magnifications and when 
printed, use 4x or 8x.
