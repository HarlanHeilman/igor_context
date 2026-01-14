# Showing Procedure Windows

Chapter III-13 — Procedure Windows
III-398
•
Manually, when you type in a procedure window
•
Semiautomatically, when you use various dialogs
Igor offers to automatically create a window recreation macro when you close a target window. A window 
recreation macro is a procedure that can recreate a graph, table, page layout or control panel window. See 
Saving a Window as a Recreation Macro on page II-47 for details.
You can add procedures by merely typing them in a procedure window.
You can create user-defined controls in a graph or control panel. Each control has an optional action pro-
cedure that runs when the control is used. You can create a control and its corresponding action procedure 
using dialogs that you access through the Add Controls submenu in the Graph or Panel menus. These 
action procedures are initially stored in the built-in procedure window.
You can create user-defined curve fitting functions via the Curve Fitting dialog. These functions are initially 
stored in the built-in procedure window.
Creating New Procedure Files
You create a new procedure file if you want to write procedures to be used in more than one experiment.
Note:
There is a risk in sharing procedure files among experiments. If you copy the experiment to 
another computer and forget to also copy the shared files, the experiment will not work on the 
other computer. See References to Files and Folders on page II-24 for further details.
If you do create a shared procedure file then you are responsible for copying the shared file when you copy 
an experiment that relies on it.
To create a new procedure file, choose WindowsNewProcedure. This creates a new procedure window. 
The procedure file is not created until you save the procedure window or save the experiment.
You can explicitly save the procedure window by choosing FileSave Procedure As or by closing it and 
choosing to save it in the resulting dialog. This saves the file as an auxiliary procedure file, separate from 
the experiment.
If you don’t save the procedure window explicitly, Igor saves it as part of the current experiment the next 
time you save the experiment.
Opening an Auxiliary Procedure File
You can open a procedure file using the FileOpen FileProcedure menu item.
When you open a procedure file, Igor displays it in a new procedure window. The procedures in the 
window can be used in the current experiment. When you save the current experiment, Igor will save a ref-
erence to the shared procedure file in the experiment file. When you later open the experiment, Igor will 
reopen the procedure file.
For procedure files that you use from a large number of experiments, it is better to configure the files as 
global procedure files. See Global Procedure Files on page III-399.
For commonly used auxiliary files, it is better to use the include statement. See Including a Procedure File 
on page III-401.
Showing Procedure Windows
We usually show procedure windows when we are doing programming and hide them for normal use.
To show the built-in procedure window, choose WindowsProcedure WindowsProcedure Window or 
press Command-M (Macintosh) or Ctrl+M (Windows). To show auxiliary procedure windows, use the Win-
dowsProcedure Windows submenu.
