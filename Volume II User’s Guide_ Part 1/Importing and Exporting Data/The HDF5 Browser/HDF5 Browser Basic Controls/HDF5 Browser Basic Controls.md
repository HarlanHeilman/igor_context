# HDF5 Browser Basic Controls

Chapter II-10 — Igor HDF5 Guide
II-194
•
A graph displaying the selected dataset or attribute
•
A table displaying the selected dataset or attribute
•
A notebook window containing a dump of the selected group, dataset or attribute
Using The HDF5 Browser
To browse HDF5 files, choose DataLoad WavesNew HDF5 Browser. This creates an HDF5 browser 
control panel. You can create additional browsers by choosing the same menu item again.
Each browser control panel lets you browse one HDF5 file at a time. For most users, one browser will be 
sufficient.
After creating a new browser, click the Open HDF5 File button to choose the file to browse.
The HDF5 browser contains four lists which display the groups, group attributes, datasets and dataset attri-
butes in the file being browsed.
HDF5 Browser Basic Controls
Here is a description of the basic controls in the HDF5 browser that most users will use.
Create HDF5 File
Creates a new HDF5 file and opens it for read/write.
Open HDF5 File
Opens an existing HDF5 file for read-only or read/write, depending on the state of the Read Only checkbox.
Close HDF5 File
Closes the HDF5 file.
Show Graph
If you click the Show Graph button, the browser displays a preview graph of subsequent datasets or attri-
butes that you select.
Show Table
If you click the Show Table button, the browser displays a preview table of subsequent datasets or attributes 
that you select.
Load Dataset
The Load Dataset button loads the currently selected dataset into the current data folder.
Load Dataset Options
This section of the browser contains two popup menus that determine if data that you load by clicking the 
Load Dataset button is displayed in a table or graph.
The Table popup menu contains three items: No Table, Display in New Table, and Append To Top Table. 
If you choose Append To Top Table and there are no tables, it acts as if you chose Display in New Table.
The Graph popup menu contains three items: No Graph, Display in New Graph, and Append To Top 
Graph. If you choose Append To Top Graph and there are no graphs, it acts as if you chose Display in New 
Graph. Appending is useful when you are loading 1D data but of little use when appending multi-dimen-
sional data. Multi-dimensional data is appended as an image plot which obscures anything that was 
already in the graph.
Text waves are not displayed in graphs even if Display in New Graph or Append To Top Graph is selected.
Save Waves
