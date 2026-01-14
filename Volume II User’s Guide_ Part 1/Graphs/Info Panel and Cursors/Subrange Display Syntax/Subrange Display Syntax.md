# Subrange Display Syntax

Chapter II-13 — Graphs
II-321
To apply your style function to a cursor, right-click the cursor home icon in the info panel and choose 
choose StyleStyle Function<Your Style Function>.
Programming With Cursors
These functions and operations are useful for programming with cursors.
The ShowInfo and HideInfo operations show and hide the info panel.
The Cursor operation sets the position of a cursor. It can also be used to change characteristics of the cursor 
such as the color, hair style, and number of digits used in the Graph Info Panel display.
The CsrInfo function returns information about a cursor.
These functions return the current position of a cursor:
These functions return information about the wave to which a cursor is attached, if any:
The CursorStyle keyword marks a user-defined function for inclusion in the Style Function submenu of 
the cursor pop-up menu.
The section Cursors — Moving Cursor Calls Function on page IV-339 explains how to trigger a user-
defined function when a cursor is moved.
Identifying a Trace
Igor can display a tooltip that identifies a trace when you hover the mouse over it. To enable this mode, 
choose GraphShow Trace Info Tags.
Subrange Display
In addition to displaying an entire wave in a graph, you can specify a subrange of the wave to display. This 
feature is mainly intended to allow the display of columns of a matrix as if they were extracted into indi-
vidual 1D waves but can also be used to display other subsets or to skip every nth data point.
To display a subrange of a graph using the New Graph and Append Traces dialogs, you must be in the more 
complex version of the dialogs which appears when you click the More Choices button. Select your Y wave 
and optionally an X wave and click the Add button. This adds the trace to the list below. You can then edit 
the subrange in the list.
Subrange Display Syntax
The Display operation (page V-161), AppendToGraph operation (page V-35), and ReplaceWave operation 
(page V-801) support the following subrange syntax for a wave list item:
wavename[rdspec][rdspec][rdspec][rdspec]
where rdspec is a range or dimension specification expressed as dimension indices (point numbers for 1D 
waves). For an n-dimensional wave, enter n specifications and omit the rest.
Only one rdspec can be a range spec. The others must be a single numeric element index or dimension label 
value.
pcsr
qcsr
hcsr
vcsr
xcsr
zcsr
CsrWave
CsrWaveRef
CsrXWave
CsrXWaveRef
