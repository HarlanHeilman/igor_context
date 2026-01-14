# Superscript and Subscript

Chapter III-1 — Notebooks
III-9
Plain Notebook Text Formats
A plain notebook has one text format which applies to all of the text in the notebook. You can set it, using the 
Notebook menu, except for the vertical offset which is always zero.
Igor does not store settings (font, size, style, etc.) for a plain text files. When you open a file as a plain text 
notebook, these settings are determined by preferences. You can capture preferences by choosing Note-
bookCapture Notebook Prefs.
Formatted Notebook Text Formats
By default, the text format for the text in a paragraph is determined by the ruler font, ruler text size, ruler 
text style, and ruler color of the ruler governing the paragraph. You can change these properties using the 
ruler pop-up menu in the ruler bar.
You can override the default text format for the selected text by applying specific formatting using the Note-
book menu or the font, size, style, and color icons in the ruler bar.
You can set the text format of the selected text to the ruler default by choosing NotebookSet Text Format 
to Ruler Default or by clicking the Default button in the ruler bar.
You should use the ruler to set the basic text format and use overrides for highlighting or other effects. For 
example, you might override the ruler text format to underline a short stretch of text or to switch to italic.
If you make a selection from the font, size, style, or color submenus of the ruler pop-up menu in the ruler 
bar, you redefine the current ruler, and all text governed by the ruler is updated.
If you make a selection from the font, size, style, or color submenus of the Notebook menu in the main menu 
bar, you override the text format for the selected text, and only the selected text is updated. This is also what 
happens if you use the font, size, style, and color icons in the ruler bar.
Text Sizes
The Text Size submenu in the Notebook menu contains an Other item. This leads to the Set Text Size dialog 
in which you can specify which sizes should appear in the Text Size submenu.
The text sizes in your Text Size menu are stored in the Igor preferences file so that the menu will include 
your preferred sizes each time you run Igor.
Vertical Offset
The vertical offset property is available only in formatted notebooks and is used mainly to implement 
superscript and subscript, as described in the next section.
Vertical offset is also useful for aligning a picture with text within a paragraph. For example, you might 
want to align the bottom of the picture with the baseline of the text.
The easiest way to do this is to use Control-Up Arrow and Control-Down Arrow key combinations (Mac-
intosh) or Alt+Up Arrow and Alt+Down Arrow key combinations (Windows), which tweak the vertical offset 
by one point at a time.
You can set the vertical offset by choosing NotebookSet Text Format which displays the Set Text Format 
dialog.
Superscript and Subscript
The last four items in the Text Size submenu of the Notebook menu have to do with superscript and sub-
script. Igor implements superscript and subscript by setting the text size and the vertical offset of the 
selected text to achieve the desired effect. They are not character properties but rather are effects accom-
plished using character properties.
