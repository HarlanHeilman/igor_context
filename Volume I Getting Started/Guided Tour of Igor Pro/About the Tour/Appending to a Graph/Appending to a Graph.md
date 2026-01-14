# Appending to a Graph

Chapter I-2 — Guided Tour of Igor Pro
I-23
8.
Change “timeval” to “timeval2”.
The dialog should now look like this:
9.
Click the Make Table box to check it and then click Load.
The data is loaded and a new table is created to show the data.
10.
Click the close button of the new table window.
A dialog is presented asking if you want to create a recreation macro.
11.
Click the No Save button.
The data we just loaded is still available in Igor. A table is just a way of viewing data and is not nec-
essary for the data to exist.
The Load Delimited Text menu item that you used is a shortcut that uses default settings for loading delim-
ited text. Later, when you load your own data files, choose DataLoad WavesLoad Waves so you can 
see all of the options.
Appending to a Graph
1.
If necessary, click in Graph0 to bring it to the front.
The Graph menu is available only when the target window is a graph.
2.
Choose the GraphAppend Traces to Graph menu item.
The Append Traces dialog appears. It is very similar to the New Graph dialog that you used to create 
the graph.
3.
In the Y Waves list, select voltage_1 and voltage_2.
4.
In the X Wave list, select timeval2.
5.
Click Do It.
Two additional traces are appended to the graph. Notice that they are also appended to the Legend.
6.
Position the cursor over one of the traces in the graph and double-click.
The Modify Trace Appearance dialog appears with the trace you double-clicked already selected.
7.
If necessary, select voltage_1 in the list of traces.
