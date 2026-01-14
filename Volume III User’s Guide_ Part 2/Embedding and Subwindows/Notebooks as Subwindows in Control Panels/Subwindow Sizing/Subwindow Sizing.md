# Subwindow Sizing

Chapter III-4 — Embedding and Subwindows
III-92
Subwindow Command Concepts
All operations that create window types that can be subwindows can take a /HOST=hcSpec flag in order 
to create a subwindow in a specific host. In addition, operations and functions that can modify or operate 
on a subwindow can affect a specific subwindow using the /W=hcSpec flag, for operations, or an hcSpec as 
a string parameter, for functions.
Subwindow Syntax
This table summarizes the command line syntax for identifying a subwindow:
The window path uses the # symbol as a separator between a window name and the name of a subwindow. 
If you have a panel subwindow named P0 inside a graph subwindow named G0 inside a panel named 
Panel0, the absolute path to the panel subwindow would be Panel0#G0#P0. The relative path from the 
main panel to the panel subwindow would be #G0#P0.
Subwindow Syntax for Page Layouts
For page layout windows, the standard syntax described above applies to subwindows in the currently 
active page only. To access a subwindow in any page, whether that page is the active page or not, use a page 
number in square brackets:
Page layout page numbers start at page 1.
This example embeds a graph in page 2 of the layout regardless of what the active page is:
NewLayout
LayoutPageAction appendPage
// Create page 2
LayoutPageAction page=1
// Page 1 is now the current page
Make/O wave0 = sin(x/8)
Display/HOST=Layout0[2] wave0
// Add a graph subwindow to page 2
ModifyGraph/W=Layout0[2]#G0 mode=3
// Set markers mode in graph subwindow
Subwindow Sizing
When /HOST is used in conjunction with Display, NewPanel, NewWaterfall, NewImage, NewGizmo and 
Edit commands to create a subwindow, the values used with the window size /W=(a,b,c,d) flag can 
have one of two different meanings. If all the values are less than 1.0, then the values are taken to be frac-
tional relative to the host’s frame. If any of the values are greater than 1.0, then they are taken to be fixed 
locations measured in points relative to the top left corner of the host.
Subwindow Specification
Location
baseName
Base host window
baseName#sub1
Absolute path from base host window
#sub1
Relative path from the active window or subwindow
#
Active window or subwindow
##
Host of active subwindow
Subwindow Specification
Location
LayoutName
Base host window, active page
LayoutName[page]
Base host window, specified page
LayoutName#sub1
Absolute path on active page
LayoutName[page]#sub1
Absolute path on specified page
