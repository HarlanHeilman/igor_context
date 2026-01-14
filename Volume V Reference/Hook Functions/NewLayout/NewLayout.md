# NewLayout

NewLayout
V-682
Details
The graph is sized to make the image pixels a multiple of the screen pixels with the graph size constrained 
to be not too small and not too large.
If matrix appears to fit Igor’s standard monochrome category, then explicit mode is set (See ModifyImage 
explicit). To be considered monochrome the wave must be unsigned byte and contain only values of 0, 64 or 255.
Once the graph is created it is a normal graph and has no special properties other than the settings it was 
created with. Specifically, it will not autosize itself if the dimensions of matrix are changed. NewImage is 
just a shortcut for creating a graph window with a style appropriate for images.
This operation is limited in scope by design. If you need to specify the position, size or title, then use the 
operations Display and AppendImage.
If the styles provided are not what you desire, touch up an image graph to meet your needs and then use 
Capture Graph Prefs from the Graphs menu. Then use “Display;AppendImage” rather than NewImage.
See Also
The Display, DoWindow, AppendImage, and ModifyImage operations.
NewLayout 
NewLayout [flags] [as titleStr]
The NewLayout operation creates a page layout.
Unlike the Layout operation, NewLayout can be used in user-defined functions. Therefore, NewLayout 
should be used in new programming instead of Layout.
NewLayout just creates the layout window. Use AppendLayoutObject to add objects to the window.
Parameters
The optional titleStr parameter is a string expression containing the layout’s title. If not specified, Igor will 
provide one which identifies the objects displayed in the graph.
Flags
/S=s
/B=(r,g,b[,a])
Specifies the background color for the layout. r, g, b, and a specify the color and 
optional opacity as RGBA Values. The default is opaque white.
/C=colorOnScreen
Obsolete. In ancient times, this flag switched the screen display of the layout between 
black and white and color. It is still accepted but has no effect.
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/K=k
Specifies one of several window styles.
s=0:
Fills entire window with image. No axes. However, this can result in 
the lower-right corner not being visible due to the target icon or 
grow icon (Macintosh).
s=1:
Like s=0 but insets image to avoid corner icon.
s=2:
Provides minimalist axes (default).
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
