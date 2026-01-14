# Subwindow Terminology

Chapter III-4 — Embedding and Subwindows
III-80
Overview
You can embed graphs, tables, Gizmo plots, and control panels into other graphs and control panels.
You can embed graphs, tables, and Gizmo plots into page layouts.
Finally, you can embed notebooks in control panels only.
The embedded window is called a subwindow and the enclosing window is called the host. Subwindows can 
be nested in a hierarchy of arbitrary depth. The top host window in the hierarchy is known as the base.
In this example, the smaller, inset graph is a subwindow:
Although you can create graphs like this by careful positioning of free axes, it is much easier to accomplish 
using embedding.
In the next example, the two graphs are subwindows embedded in a host panel:
This example is derived from the CWT demo experiment which you can find in the Analysis section of your 
Examples folder.
Subwindow Terminology
When a window is inserted into another window it is said to be embedded. In some configurations (see Sub-
window Restrictions on page III-82), an embedded window does not support the same functionality that it 
has as a standalone window. It is then called a presentation-only object. For example, when a table is embedded 
in a panel, it has scroll bars and data entry features just like a standalone table. But when a table is embedded 

Chapter III-4 — Embedding and Subwindows
III-81
in a graph or in a page layout, it is a presentation-only object with no scroll bars or other user interface ele-
ments.
The following pictures illustrate additional subwindow terminology:
A graph, layout, or control panel window operates in one of three modes:
•
Operate mode (also called normal mode)
•
Drawing mode
•
Subwindow layout mode
When the top icon in the tool palette is selected, the window is in operate mode. This is the mode in which 
the user normally uses the window or active subwindow.
Embedded 
subwindow
Operate mode
Host 
window
Selected 
subwindow
Drawing 
mode
Subwindow 
layout mode
Guide
Selected 
subwindow
Plot frame
Subwindow frame
