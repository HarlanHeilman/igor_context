# Page Layout Background Color

Chapter II-18 — Page Layouts
II-477
Page Layout Windows
To create a page layout window, choose WindowsNew Layout.
Page Layout Names and Titles
Every page layout window that you create has a name. This is a short Igor-object name that you or Igor can 
use to reference the layout from a command or procedure. When you create a new layout, Igor assigns it a 
name of the form Layout0, Layout1 and so on. You will most often use a layout’s name when you kill and 
recreate the layout, see Killing and Recreating a Layout on page II-477.
A layout also has a title. The title is the text that appears at the top of the layout window. Its purpose is to 
identify the layout visually. It is not used to identify the layout from a command or procedure. The title can 
consist of any text, up to 255 bytes.
You can change the name and title of a layout using the Window Control dialog. This dialog is a collection of 
assorted window-related things. Choose Window Control from the Control submenu of the Windows menu.
Hiding and Showing a Layout
You can hide a layout window by pressing the Shift key while clicking the close button.
You can show a layout window by choosing its name from the WindowsLayouts submenu.
Killing and Recreating a Layout
Igor provides a way for you to kill a layout and then later to recreate it. This temporarily gets rid of a layout 
that you expect to be of use later.
You kill a layout by clicking the layout window’s close button or by using the Close item in the Windows menu. 
When you kill a layout, Igor offers to create a window recreation macro. Igor stores the window recreation 
macro in the procedure window of the current experiment. You can invoke the window recreation macro later 
to recreate the layout. The name of the window recreation macro is the same as the name of the layout.
For further details, see Closing a Window on page II-46 and Saving a Window as a Recreation Macro on 
page II-47.
Page Layout Zooming
You can zoom the page using the Zoom submenu in the Layout menu or the Zoom submenu in the Layout 
menu or the Zoom pop-up menu in the lower-left corner of the layout window.
By zooming out you see the entire page at once. You can zoom in to place drawing elements with higher 
precision.
Igor stores the position of layout objects with a precision of one point (nominally 1/72th of an inch, about 
0.35 mm).
Page Layout Background Color
You can choose a background color for a page layout. This is useful for creating slides.
The background color applies to all pages of the page layout.
You can specify thebackground color by:
•
Using the Background Color submenu in the Layout menu.
•
Using the Background Color submenu in the Misc pop-up menu.
•
Using the NewLayout command line operation.
•
Using the ModifyLayout command line operation.
