# Resetting a Picture’s Size

Chapter II-18 — Page Layouts
II-496
Igor generates the lines of the legend text starting with the bottom graph object in the layout and working 
toward the top. You can edit the text to remove symbols that you don’t want or to change what appears 
after the symbol.
If you change the symbol for a trace referenced in the legend, Igor automatically updates the layout legend. 
If you append or remove waves to the graphs represented in the layout, Igor updates the layout legend. 
Updating happens when you activate the layout unless you have turned the layout’s DelayUpdate setting 
off, in which case it happens immediately.
You can freeze a legend by converting it to a textbox. This stops Igor from automatically updating it when 
waves are added to or removed from graphs. To do this, select the annotation tool and click in the legend. 
In the resulting Modify Annotation dialog, change the pop-up menu in the top-left corner from Legend to 
Textbox. You can also do this using the following command:
Textbox/C/N=text0
// convert legend named text0 into a textbox
Instead of specifying the name of the trace for a legend symbol, you can specify the trace number. For exam-
ple, "\s(Graph0.#0)" displays the legend for trace number 0 of Graph0.
Default Font
By default, annotations use the default font chosen in the Default Font dialog via the Misc menu. You can 
override the default font using the Font pop-up menu in the Add Annotation dialog.
Page Layout Pictures
You can insert a picture that you have created in another application, for example a drawing program or 
equation editor, into the layout layer or into a drawing layer. If the picture has some relation to other 
drawing elements, you should use the drawing layer. If it has some relation to other layout objects, you 
should use the layout layer. The use of drawing layers is discussed under Pasting a Picture Into a Drawing 
Layer on page III-73. This section discusses pictures in the layout layer.
Inserting a Picture in the Layout Layer
All pictures displayed in the layout layer reside in the picture gallery which you can see by choosing 
MiscPictures. If you paste a picture from the clipboard into the layout layer, Igor automatically adds it to 
the picture gallery. If the picture is in a file on disk, you must first load it into the picture gallery. Then you 
can place it in the layout layer.
See Pictures on page III-509 for information on supported picture formats.
Resetting a Picture’s Size
If you expand or shrink a picture in the layout layer, you can reset it to its default size by pressing Option 
(Macintosh) or Alt (Windows) and double-clicking it with the arrow tool.
Escape code for 
wave trace symbol
Specifies the graph
Specifies the trace in the graph
\s(Graph0.data0) data0
\s(Graph1.data1) data1
\s(Graph2.data2) data2
 data0
 data1
 data2
You can put any text here
