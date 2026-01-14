# Page Layout Style Macros

Chapter II-18 — Page Layouts
II-498
Exporting Page Layouts
You can export a layout to another application through the clipboard or by creating a file. To export via the 
clipboard, use the Export Graphics item in the Edit menu. To export via a file, use the Save Graphics item 
in the File menu.
If you want to export a section of the page, use the marquee tool to specify the section first. To do this, the 
layout icon in the top-left corner of the layout window must be selected.
If you don’t use the marquee, Igor exports the entire page, or the part of the page that has layout objects or 
drawing elements in it. The Crop to Page Contents, in the Export Graphics and Save Graphics dialogs, con-
trols this.
The process of exporting graphics from a layout is very similar to exporting graphics from a graph. You can 
find the details under Chapter III-5, Exporting Graphics (Macintosh) and Chapter III-6, Exporting Graph-
ics (Windows). Those chapters describe the various export methods and how to select the method that will 
give you the best results.
Page Layout Preferences
Page layout preferences allow you to control what happens when you create a new layout or add new 
objects to the layout layer of an existing layout. To set preferences, create a layout and set it up to your taste. 
We call this your prototype layout. Then choose Capture Layout Prefs from the Layout menu.
Preferences are normally in effect only for manual operations, not for programmed operations in Igor pro-
cedures. This is discussed in more detail in Chapter III-18, Preferences.
When you initially install Igor, all preferences are set to the factory defaults. The dialog indicates which 
preferences you have changed.
The “Window Position and Size” preference affects the creation of new layouts only.
The Object Properties preference affects the creation of new objects in the layout layer. To capture this, add 
an object to the layout layer and use the Modify Objects dialog to set its properties. Then select the object 
and choose Capture Layout Prefs. Select the Object Properties checkbox and click Capture Prefs.
The page size and margins preference affects what happens when you create a new layout, not when you 
recreate a layout using a recreation macro.
Page Layout Style Macros
The purpose of a layout style macro is to allow you to create a number of layouts with the same stylistic 
properties. Using the Window Control dialog, you can instruct Igor to automatically generate a style macro 
from a prototype layout. You can then apply the macro to other layouts.
Igor can generate style macros for graphs, tables and page layouts. However, their usefulness is mainly for 
graphs. See Graph Style Macros on page II-350. The principles explained there apply to layout style macros also.
