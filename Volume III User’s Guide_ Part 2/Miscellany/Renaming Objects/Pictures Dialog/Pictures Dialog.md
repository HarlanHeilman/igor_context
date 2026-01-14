# Pictures Dialog

Chapter III-17 — Miscellany
III-510
Formats that are not supported on the current platform are drawn as gray boxes.
See also Picture Compatibility on page III-449 for a discussion of Macintosh graphics on Windows and 
vice-versa.
Importing PDF Pictures
PDF (Portable Document Format) is Adobe's platform-independent vector graphics format. However, not 
all programs can import PDF. 
On Macintosh, Igor has supported importing PDF graphics since Igor Pro 5. PDF pictures are using bitmaps 
except in Macintosh native graphics mode (see Graphics Technology on page III-506).
On Windows, Igor supports importing PDF graphics in Igor Pro 9 or later. PDF pictures are drawn using 
bitmaps.
The Picture Gallery
When you create a named picture using one of the techniques listed above, Igor stores it in the current 
experiment’s picture gallery. When you save the experiment, the picture gallery is stored in the experiment 
file. You can inspect the collection using the Pictures dialog via the Misc menu.
Igor gives names to pictures so they can be referenced from an Igor procedure. For example, if you paste a 
picture into a layout, Igor assigns it a name of the form “PICT_0” and stores it in the picture gallery. If you 
then close the layout and ask Igor to create a recreation macro, the macro will reference the picture by name.
You can rename a named picture using the Pictures dialog in the Misc menu, the Rename Objects dialog in 
the Misc menu, the Rename dialog in the Data menu, or the RenamePICT operation (see page V-797). You 
can kill a named picture using the Pictures dialog or the KillPICTs operation (see page V-470).
Pictures Dialog
The Pictures dialog permits you to view the picture gallery, to add pictures, to remove pictures and to place 
a picture into a graph or page layout. It also can place a copy of a picture into a formatted notebook. To 
invoke it, choose Pictures from the Misc menu.
EPS (Encapsulated PostScript)
High resolution vector format.
Requires PostScript printer.
On Windows and on Macintosh in Qt graphics mode, a screen preview is 
displayed on screen.
SVG (Scalable Vector Graphics)
Cross-platform vector and bitmap format.
Always rendered using Qt graphics. In other graphics technology modes, 
it is drawn into a high-resolution btmap which is then drawn on the 
screen, exported, or printed.
Format
Notes
