# Inserting Pictures

Chapter III-1 — Notebooks
III-13
Special Characters
Aside from regular text characters, there are some special things that you can put into a paragraph in a for-
matted notebook. This table lists of all of the types of special characters and where they can be used.
The main way in which a special character differs from a normal character is that it is not simply a text char-
acter. Another significant difference is that some special characters are dynamic, meaning that Igor can 
update them automatically. Other special characters, while not dynamic, are linked to Igor graphs, tables 
or page layouts (see Using Igor-Object Pictures on page III-18).
This example shows three kinds of special characters:
The time and date look like normal text but they are not. If you click any part of them, the entire time or 
date is selected. They act like a single character.
An action is a special character which, when clicked, runs Igor commands. See Notebook Action Special 
Characters on page III-14 for details.
Except for pictures, which are pasted, special characters are inserted using the Special submenu in the Note-
book menu or using the Insert pop-up menu in the ruler area of a formatted notebook.
Inserting Pictures
You can insert pictures, including Igor-object pictures, by merely doing a paste. You can also insert pictures 
using EditInsert File or using the Notebook insertPicture operation.
When you insert a picture, the contents of the picture file are copied into the notebook. No link to the picture 
file is created.
If you use a platform-independent picture format, such as PNG (recommended), JPEG, TIFF, PDF, or SVG, 
then the picture is displayed correctly on all platforms. If you use a platform-specific picture format, such 
as Enhanced Metafile on Windows, the picture is displayed as a gray box if viewed on the other platform. 
On Windows, PDF is displayed correctly in Igor Pro 9.00 or later; older versions displayed PDF as a gray 
box.
Special Character Type
Where It Can Be Used
Picture
Main body text, headers and footers.
Igor-object picture (from graph, table, layout)
Main body text, headers and footers.
The date
Main body text, headers and footers.
The time
Main body text, headers and footers.
The name of the experiment file
Main body text, headers and footers.
Notebook window title
Headers and footers only.
Current page number
Headers and footers only.
Total number of pages
Headers and footers only.
Actions
Main body text only.
A picture special character
A time special character
A date special character
