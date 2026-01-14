# Programming Notebooks

Chapter III-1 — Notebooks
III-25
4.
Press Command-G (Macintosh) or Ctrl+G (Windows) to find the next occurrence.
Notebook Names, Titles and File Names
This table explains the distinction between a notebook’s name, its title and the name of the file in which it 
is saved.
Igor automatically opens notebooks that are part of an Igor experiment when you open the experiment. If 
you change a notebook’s file name outside of the experiment, Igor will be unable to automatically open it 
and will ask for your help when you open the experiment.
A notebook file stored inside a packed experiment file does not exist separately from the experiment file, so 
there is no way or reason to change the notebook’s file name.
Notebook Info Dialog
You can get general information on a notebook by selecting the Info item in the Notebook menu or by click-
ing the icon in the bottom/left corner of the notebook. This displays the File Information dialog.
The File Information dialog shows you whether the notebook has been saved and if so whether it is stored 
in a packed experiment file, in an unpacked experiment folder or in a stand-alone file.
Programming Notebooks
Advanced users may want to write Igor procedures to automatically log results or generate reports using 
a notebook. The operations that you would use are briefly described here.
Item
What It Is For
How It Is Set
Notebook name
Used to identify a notebook from an 
Igor command.
Igor automatically gives new notebooks 
names of the form Notebook0. You can 
change it using the Window Control dialog 
or using the DoWindow/C operation.
Notebook title
For visually identifying the window. 
The title appears in the title bar at the 
top of the window and in the Other 
Windows submenu of the Windows 
menu.
Initially, Igor sets the title to the 
concatenation of the notebook name and 
the file name. You can change it using the 
Window Control dialog or using the 
DoWindow/T operation. 
File name
This is the name of the file in which the 
notebook is stored.
You enter this in the New Notebook dialog. 
Change it on the desktop.
Operation
What It Does
NewNotebook
Creates a new notebook window.
OpenNotebook
Opens an existing file as a notebook.
SaveNotebook
Saves an existing notebook to disk as a stand-alone file or packed into the 
experiment file.
PrintNotebook
Prints all of a notebook or just the selected text.
Notebook
Provides control of the contents and all of the properties of a notebook except 
for headers and footers. Also sets the selection and to search for text or 
graphics.
NotebookAction
Creates or modifies notebook action special characters.
