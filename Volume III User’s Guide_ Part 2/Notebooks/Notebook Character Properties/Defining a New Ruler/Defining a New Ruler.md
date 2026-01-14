# Defining a New Ruler

Chapter III-1 — Notebooks
III-11
The write-protect property does not affect commands such as Notebook and NotebookAction. Even if 
write-protect is on, they can still modify the notebook.
Use write-protect if you want to avoid inadvertent manual modifications to the notebook but want the user 
to be able to take full control.
Changeable By Command Only
You can control the changeableByCommandOnly property using NewNotebook/OPTS=8 or using the 
Notebook operation with the changeableByCommandOnly keyword.
This property is intended to allow programmers to control whether the user can manually modify the note-
book or not. Its main purpose is to allow a programmer to create a notebook subwindow in a control panel 
for displaying status messages and other information that is not intended to be modified by the user. There 
is no way to manually change this property - it can be changed by command only.
When the changeableByCommandOnly property is on, a lock icon appears in the bottom/left corner of the 
notebook window.
Use changeableByCommandOnly if you want no manual modifications to be made to the notebook but 
want it to be modifiable via commands.
The changeableByCommandOnly property is intended for programmatic use only and is not saved to disk.
For further information on notebook subwindows, see Notebooks as Subwindows in Control Panels on 
page III-91.
Working with Rulers
A ruler is a set of paragraph properties that you can apply to paragraphs in a formatted notebook. Using rulers, 
you can make sure that paragraphs that you want to have the same formatting do have the same formatting. Also, 
you can redefine the format of a ruler and all paragraphs governed by that ruler will be automatically updated.
In a simple notebook, you might use just the one built-in ruler, called Normal. In a fancier notebook, where 
you are concerned with presentation, you might use several rulers.
The pop-up menu on the left side of the ruler shows which ruler governs the first currently selected para-
graph. You can use this pop-up menu to:
•
Apply an existing ruler to the selected paragraphs
•
Create a new ruler
•
Redefine an existing ruler
•
Find where a ruler is used
•
Rename a ruler
•
Remove a ruler from the document
Defining a New Ruler
To create a new ruler, choose Define New Ruler from the Ruler pop-up menu. This displays the Define New 
Ruler dialog.
Enter a name for the ruler. Ruler names must follow rules for standard (not liberal) Igor names. They may 
be up to 31 bytes in length, must start with a letter and may contain letters, numbers and the underscore 
character.
Use the icons in the dialog’s ruler bar to set the font, text size, text style, and color for the new ruler.
Click OK to create the new ruler.
