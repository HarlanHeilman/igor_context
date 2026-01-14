# Write-protect

Chapter III-1 — Notebooks
III-10
The following table illustrates the use and effects of each of these items.
Help Links in Formatted Notebooks
You can format text as a help link by selecting the text and clicking the Help button in the ruler. Usually 
you do this while editing a help file.
Clicking text in a notebook that is formatted as a help link goes to the specified help topic. This allows you 
to easily link to help topics from a documentation notebook. The help link text must reference a topic or 
subtopic in a help file; the target can not be in a notebook.
Since simply clicking a help link in a notebook activates the link, to edit a help link you need to do one of 
the following:
•
Use the arrow keys instead of simply clicking in the help link
•
Press the command key (Macintosh) or Ctrl key (Windows) while clicking in the help link
•
Select at least one character instead of simply clicking in the help link
Notebook Read/Write Properties
There are three properties that control whether a notebook can be modified.
Read-only
The read-only property is set if you open the file for read-only by executing OpenNotebook/R. It is also set 
if you open a file for which you do not have read/write permission.
When the read-only property is set, a lock icon appears in the bottom/left corner of the notebook window 
and you can not modify the notebook manually or via commands.
The read-only property can not be changed after the notebook is opened.
Use read-only if you want no modifications to be made to the notebook.
Write-protect
You can set the write-protect property to on or off by clicking the pencil icon in the bottom/left corner of the 
notebook window or using the Notebook operation with the writeProtect keyword.
The write-protect property is intended to give the user a way to prevent inadvertent manual modifications 
to the notebook. The user can turn the property on or off at will.
Action
Effect on Character Properties
Result
Type “XYZ”.
XYZ
Highlight “Y” and then choose 
Superscript.
Reduces text size and sets vertical offset for “Y”. X
YZ
Highlight “Z” and then choose 
Superscript.
Sets text size and vertical offset for “Z” to make 
it superscript relative to “Y”.
X
YZ
Highlight “Z” and then choose In Line. Sets text size and vertical offset for “Z” to be 
same as for “Y”.
X
YZ
Highlight “YZ” and then choose 
Normal.
Sets text size for “YZ” same as “X” and sets 
vertical offset to zero.
XYZ
