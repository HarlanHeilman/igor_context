# Compatibility with Previous Versions of Igor

Chapter II-18 — Page Layouts
II-478
The background color is white by default. If you wish, after selecting a background color, you can capture 
your preferred background color by choosing Capture Layout Prefs from the Layout menu.
Page Layout Pages
Each page can have any number of pages. You use the page sorter to add and delete pages.
The Page Sorter
The page sorter occupies the left side of the layout window. It provides an overview of all pages in the 
layout by displaying a thumbnail view of each page.
Control-clicking (Macintosh) or right-clicking (Windows) in the page sorter area displays a contextual menu 
from which you can add a page, insert a new page between existing pages, or delete existing pages. You 
can also add or delete pages using the controls at the bottom of the page sorter.
The editing area of the layout displays only one page at a time. The displayed page is called the "active 
page". You set the active page by clicking one of the thumbnails in the sorter. Igor identifies the active page 
by drawing a red outline around its thumbnail.
Although only one page can be active, you can select multiple pages. You would do this to delete or reorder 
multiple pages at a time. Igor identifies selected pages by drawing a darker outline around their thumb-
nails.
Starting from a single selected page, you can select a range of pages by clicking on a non-selected thumbnail 
while pressing the shift key. Alternatively, you can select or deselect individual pages by pressing the 
command key (Macintosh) or control key (Windows) while clicking the corresponding thumbnail.
To change the order of pages, select one or more thumbnails and drag them to the desired place in the 
sorter.
You can also manipulate the pages in a layout programatically using the LayoutPageAction operation.
You can resize the page sorter by dragging the divider between it and the page editing area to the left or 
right. Dragging the divider all the way to the left hides the page sorter entirely.
Page Layout Page Sizes
Each layout stores a global page size and page margins. You can also set the size and margins for specific 
individual pages. The global page size and margins apply to any page in the layout for which you have not 
set an explicit size. You can set both the global and the per-page dimensions using the Layout Page Size 
dialog via the Layout menu, or using the LayoutPageAction operation.
When it is created, a layout is given a default page size and page margins based on preferences. You can 
change these default dimensions by setting the global dimensions for a page layout and choosing Lay-
outCapture Layout Prefs.
Compatibility with Previous Versions of Igor
Page layouts were originally conceived, decades ago, primarily for use in printing hard copy. Because of 
this, in Igor Pro 6 and earlier versions, the layout page size was controlled using the system Page Setup 
dialog, which is part of the printing system.
Over time, the use of hard copy has diminished, replaced by on-screen formats such as HTML and PDF. It 
is more common now to create graphics for display in a web page or for inclusion in an electronic document 
to be sent to a journal editor. For these purposes, you usually need to control the size of the graphics inde-
pendent of any paper size.
Consequently, in Igor Pro 7 and later, each layout has its own size setting that is independent of the page 
setup. The page setup affects printing of the layout only, not the size of the page on the screen or when
