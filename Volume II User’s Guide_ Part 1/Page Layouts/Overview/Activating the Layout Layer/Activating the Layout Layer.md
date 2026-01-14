# Activating the Layout Layer

Chapter II-18 — Page Layouts
II-479
exported. Because of this change, a layout created in Igor7 or later may appear with a different size when 
opened in Igor6.
You may be accustomed to controlling the size and orientation of a page layout page using FilePage 
Setup. In Igor7 and later, you need to use LayoutPage Size instead.
An ancillary benefit of this change is that it eliminates operating-system dependencies, making behavior 
across platforms more consistent.
Printing Page Layouts
When you print a page layout, Igor aligns the top/left corner of the layout page, as set in the Layout Page 
Size dialog, with the top/left corner of the printer’s printable area, as set in the Page Setup dialog. The 
printer’s printable area is controlled by the printer margins as set in the Page Setup dialog.
You can preview the printed output using the Print Preview dialog from the File menu.
Page Layout Layers
A page in a layout has six layers. There is one layer for layout objects, four layers for drawing elements, and 
one layer (not shown in this graphic) for user-interface elements.
The two icons in the top-left corner of the layout window control whether you are in layout mode or 
drawing mode.
The layout layer is most useful for presenting multiple graphs and for annotations that refer to multiple 
graphs. The drawing layers are useful for adding simple graphic elements such as arrows between graphs.
The top layer (not shown in the graphic above) is the Overlay layer. It is provided for programmers who 
wish to add user-interface drawing elements without disturbing graphic elements. It is not included when 
printing or exporting graphics. This layer was added in Igor Pro 7.00.
Activating the Layout Layer
When you click the layout mode icon, the layout layer is activated. You can use the layout tools to add 
objects to or modify objects in the layout layer only.
All graphs, tables and annotations 
go in the Layout layer.
Most manual drawing is done in the 
User Front layer.
UserFront
ProgFront
Layout
UserBack
ProgBack
Layout mode icon — activates the layout layer
Drawing mode icon — activates the selected drawing layer
