# Positioning Annotations Programmatically

Chapter II-18 — Page Layouts
II-494
Pasting into a Different Experiment
The reference in the clipboard to Igor objects by name doesn’t work across Igor experiments. The second 
experiment may have a different object with the same name or it may have no object with the name stored 
in the clipboard. The best you can do when pasting from one experiment to another is to paste a picture of 
the object from the first experiment.
You can force Igor to paste the picture representation instead of the Igor object representation as described 
above, by pressing Option (Macintosh) or Alt (Windows) while choosing EditPaste.
Pasting Color Scale Annotations
For technical reasons, Igor is not able to faithfully paste a color scale annotation that uses a color index wave 
or that uses the lookup keyword of the ColorScale operation. If you paste such a color scale, Igor will change 
it to a color table color scale annotation with no lookup.
Page Layout Annotations
The term “annotation” includes textboxes, legends, tags, and color scales. You can create annotations in 
graphs and in page layouts. Annotations are discussed in detail in Chapter III-2, Annotations. This section 
discusses aspects of annotations that are unique to page layouts.
Annotations in page layouts exist as layout objects in the layout layer, along with graphs, tables, 3D Gizmo 
plots, and pictures.
In a graph, an annotation can be a textbox, legend, tag, or color scale. A legend shows the plot symbols for 
the waves in the graph. A tag is connected to a particular point of a particular wave. In a layout, tags are 
not applicable. You can create textboxes, legends, and color scales.
Annotations are distinct from the simple text elements that you can create in the drawing layers of graphs, 
layouts and control panels.
Creating a New Annotation
To create a new annotation, choose Add Annotation from the Layout menu or select the annotation tool and click 
anywhere on the page, except on an existing annotation. These actions invoke the Add Annotations dialog.
The many options in this dialog are explained in Chapter III-2, Annotations.
Modifying an Existing Annotation
If an annotation is selected when you pull down the Layout menu, you will see a Modify Annotation item 
instead of the Add Annotation item. Use this to modify the text or style of the selected annotation. You can 
also invoke the Modify Annotation dialog by clicking the annotation while the annotation tool is selected. 
Double-clicking an annotation while the arrow tool is selected brings up the Modify Object dialog, not the 
Modify Annotation dialog.
Positioning an Annotation
An annotation is positioned relative to an anchor point on the edge of the printable part of the page. The dis-
tance from the anchor point to the textbox is determined by the X and Y offsets expressed in percent of the 
width and height of the page inside the margins. The X and Y offsets are automatically set for you when you 
drag a textbox around the page. You can also set them using the Position tab of the Modify Annotation dialog 
but this is usually not as easy as just dragging.
Positioning Annotations Programmatically
This diagram shows the anchor points:
