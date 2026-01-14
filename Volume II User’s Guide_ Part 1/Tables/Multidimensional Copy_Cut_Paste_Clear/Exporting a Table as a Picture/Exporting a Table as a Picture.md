# Exporting a Table as a Picture

Chapter II-12 — Tables
II-271
You can do the same using the table popup menu (gear icon in top/right corner of the table). The Edit Waves 
item does not appear in the Table menu in the main menu bar.
The Edit Waves item appears in the contextual menu or table popup menu only if one or more editable 
wave references are selected. NULL waves (wave reference=0) and free waves can not be edited in a table.
​This feature is not available in the table subwindow in the debugger.
Printing Tables
Before printing a table you should bring the table to the top of the desktop and set the page size and orien-
tation using the Page Setup dialog. Choose the Page Setup for All Tables item from the Files menu.
In each experiment, Igor stores one page setup for all tables. Thus, changing the page setup while a table is 
active changes the page setup for all tables in the current experiment.
When you invoke the Page Setup dialog you must make sure that the table that you want to print is the top 
window. Changing the page setup for graphs, page layouts or other windows does not affect the page setup 
for tables.
You can print all or part of a table. To print the whole table, select just one cell and choose File-Print Table. 
To print the selection, select multiple cells and choose FilePrint Table Selection.
Exporting Tables as Graphics
Although Igor tables are intended primarily for editing data, you can also use them for presentation pur-
poses. You can put a table into an Igor page layout, as discussed in Chapter II-18, Page Layouts. This section 
deals with exporting a table to other applications as a picture.
Typically you would do this if you are preparing a report in a word processor or page layout program or 
making an illustration in a drawing program. If you are exporting to a program that has strong text format-
ting features, it may be better to copy the data from the table as text, using the Copy item in the Edit menu. 
You can paste the text into the other program and then format it as you wish.
Exporting a Table as a Picture
To export a table as a Macintosh picture via the clipboard, choose Export Graphics from the Edit menu. This 
copies the table to the clipboard as a picture.
The picture that Igor puts into the clipboard contains just the visible cells in the table window. You can 
scroll, expand or shrink the window to control which cells will appear in the picture.
Igor can write a picture out to a file instead of copying it to the clipboard. To do this, use the Save Graphics 
submenu of the File menu.
Most word processing, drawing and page layout programs permit you to import a picture via the clipboard 
or via a file.
Although we have not optimized tables for presentation purposes, we did put two features into tables specifi-
cally for presentation. First, you can hide the point column by setting its width to zero. Second, you can replace 
the automatic column titles with column titles of your own. Use the Modify Columns dialog for both of these.
There are some features lacking that would be nice for presentation. You can’t change the background color 
of a table. You can’t change or remove the grid lines. If you want to do these things, export the table to a 
drawing program for sprucing up.
