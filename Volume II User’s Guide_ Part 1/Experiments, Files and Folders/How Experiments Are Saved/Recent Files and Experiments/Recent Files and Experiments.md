# Recent Files and Experiments

Chapter II-3 — Experiments, Files and Folders
II-34
Igor File-Handling
Igor has many ways to open and load files. The following sections discuss some of the ways Igor deals with 
the various files it is asked to open.
The Open or Load File Dialog
When you open a file using menu item, such as FileOpen FileNotebook, there is no question of how 
Igor should treat the file. This is not always the case when you drop a file onto the Igor icon or double-click 
a file on the desktop.
Often, Igor can determine how to open or load a file, and it will simply do that without asking the you about 
it. Sometimes Igor recognizes that a file (such as a plain text file or a formatted Igor notebook) can be appro-
priately opened several ways, and will ask you what to do by displaying the Open or Load File Dialog. The 
dialog presents a list of ways to open the file (usually into a window) or to load it as data.
Tip:
You can force this dialog to appear by holding down Shift when opening a file through the Recent 
Files or Recent Experiments menus, or when dropping a file onto the Igor icon.
This is especially useful for opening Igor help files as a notebook file for editing, or to open a 
notebook as a help file, causing Igor to compile it.
The list presents three kinds of methods for handling the file:
1.
Open the file as a document window or an experiment.
2.
Load the file as data without opening another dialog.
3.
Load the file as data through the Load Waves Dialog or a File Loader Extension dialog.
If you choose one of the list items marked with an asterisk, Igor displays the selected dialog as if you had 
chosen the corresponding item from the Load Waves submenu of the Data menu.
Information about the file, or about how it was most recently opened, is displayed to the right of the list. 
The complete path to the file is shown below the list.
If you change the text in the Rename file edit box, Igor changes the file name before opening or loading the 
file.
Recent Files and Experiments
When you use a dialog to open or save an experiment or a file, Igor adds it to the Recent Experiments or 
Recent Files submenu in the File menu. When you choose an item from these submenus, Igor opens the 
experiment or file the same way in which you last opened or saved it.
