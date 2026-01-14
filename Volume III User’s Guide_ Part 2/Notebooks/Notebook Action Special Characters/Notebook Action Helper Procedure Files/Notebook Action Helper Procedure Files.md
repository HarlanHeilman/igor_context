# Notebook Action Helper Procedure Files

Chapter III-1 — Notebooks
III-17
FileNotebook). After editing the action, save the changes, close the notebook, and reopen it as a help file 
(choose FileOpen FileHelp File).
Modifying the Action Frame
If the notebook action has a picture, you can frame the action by choosing a frame style from the Note-
bookSpecialFrame submenu.
Modifying the Action Picture Scaling
If the notebook action has a picture, you can scale the picture by choosing an item from the Note-
bookSpecialScale submenu.
Notebook Action Helper Procedure Files
In some instances you may want an action to call procedures in an Igor procedure file. The notebook action 
helper procedure file feature provides a convenient way to associate a notebook or help file with a procedure file.
Each formatted notebook (and consequently each help file) can designate only one procedure file as an 
action helper procedure file. Before choosing the helper file you must save the notebook as a standalone file 
on disk. Then choose NotebookSpecialAction Helper.
Click the File button to choose the helper procedure file for the notebook.
For most cases we recommend that you name your action helper procedure file with the same name as the 
notebook but with the .ipf extension. This indicates that the files are closely associated.
The helper file will usually be located in the same directory as the notebook file. Less frequently, it will be in a 
subdirectory or in a parent directory. It must be located on the same volume as the notebook file because Igor 
finds the helper using a relative path, starting from the notebook directory. If the notebook file is moved, the 
helper procedure file must be moved with it so that Igor will be able to find the helper using the relative path.
If Open Helper Procedure File When Notebook Is Opened is selected, the helper procedure file is opened along 
with the notebook. This checkbox can usually be left deselected. However, if you use Proc Pictures stored in the 
helper file, you should select it so that the pictures can be correctly rendered when the notebook is opened.
If Open Helper Procedure File When Action Is Clicked is selected, then, when you click an action, the pro-
cedure file loads, compiles, and executes automatically. This should normally be selected.
In both of these situations, the procedure file loads as a “global” procedure file, which means that it is not 
part of the current experiment and is not closed when creating a new experiment.
If Close Helper procedure File When Notebook Is Closed is selected and you kill a notebook or help file that 
has opened a helper file, the helper file is also killed. This should normally be selected.
To avoid unanticipated name conflicts between procedures in your helper file and elsewhere, it is a good idea 
to declare the procedures static (see Static Functions on page IV-105). In order to call such private routines
