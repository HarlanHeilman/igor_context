# Annotation Text Escape Codes

Chapter III-2 — Annotations
III-35
When manipulating annotations with the mouse, be sure that the graph or page layout are in the “operate” 
mode; not the “drawing” mode. The tool palette indicates which mode the window is in:
The Annotation Dialog
You can use the annotation dialog to create new annotations or modify existing annotations. The annotation 
dialog seems complex but comprises only a few major functions:
•
A pop-up menu to choose the annotation type.
•
A Name setting.
•
Tabs that group related Annotations settings.
•
A Preview box to show what the annotation will look like or to display commands.
•
The normal Igor dialog buttons.
Modifying Annotations
If an annotation is already in a graph or Gizmo plot, you can modify it by double-clicking it while in the 
“operate” mode. This invokesModify Annotation dialog.
In a page layout, to modify an annotation, you must first select the Annotation (“A”) tool in layout mode. 
Then single-click the annotation to invoke the Modify Annotation dialog.
Annotation Text Content
You enter text into the Annotation text entry area in the Text tab.
The annotation text may contain both plain text and “escape code” text which produces special effects such 
as superscript, font, font size and style, alignment, text color and so on. The text can contain multiple lines. 
At any point when entering plain text, you can choose a special effect from a pop-up menu within the Insert 
group, and Igor will insert the corresponding escape code. Igor wizards can type them in directly.
As you type annotation text, the Preview box shows what the resulting annotation will look like. You can 
not enter text in the Preview box.
Annotation Text Escape Codes
An escape code consists of a backslash character followed by one or more characters. It represents the 
special effect you selected. The effects of the escape code persist until overridden by a following escape 
code. The escape codes are cryptic but you can see their effects in the Preview box.
In the adjacent example, the subscript escape 
code “\B” begins a subscript and is not dis-
played in the annotation; the “n” that follows is 
plain text displayed as a subscript. The normal 
escape code “\M” overrides the subscript mode 
so that the plain text “= z” that follows has the original size and Y position (vertical offset) used for the “J”.
The section Annotation Escape Codes on page III-53 provides detailed documentation for the escape codes.
Graph Window
Operate
Draw
Mode
Mode
Page Layout 
Annotation Tool
Page Layout
Operate
Draw
Mode
Mode
Jn = z
Normal “escape code”
J\Bn\M = z
Subscript “escape code”
Jn = z
Normal “escape code”
J\Bn\M = z
Subscript “escape code”
