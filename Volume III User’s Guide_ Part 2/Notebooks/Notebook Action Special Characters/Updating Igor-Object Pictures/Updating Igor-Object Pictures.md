# Updating Igor-Object Pictures

Chapter III-1 — Notebooks
III-18
you also need to assign a module name to the procedure file and use the module name when invoking the 
routines (see Regular Modules on page IV-236). For an example see the Notebook Actions Demo experiment.
Using Igor-Object Pictures
You create a picture from an Igor graph, table, page layout or Gizmo plot by choosing EditExport Graph-
ics to copy a picture to the clipboard. For graphs, layouts, and Gizmo plots, you can also choose 
EditCopy. When you do this, Igor puts on the clipboard information about the window from which the 
picture was generated. When you paste into a notebook, Igor stores the window information with the pic-
ture. We call this kind of picture an “Igor-object” picture.
The Igor-object information contains the name of the window from which the picture was generated, the 
date/time at which it was generated, the size of the picture and the export mode used to create the picture. 
Igor uses this information to automatically update the picture when you request it.
Because of backward compatibility issues, this feature works only if the name of the window is 31 bytes or 
less.
Igor can not link Igor-object pictures to a window in a different Igor experiment.
For good picture quality that works across platforms, we recommend that you use a high-resolution PNG 
format.
Updating Igor-Object Pictures
Before updating Igor object pictures, you must enable updating using the NotebookSpecialEnable 
Updating menu item. This is a per-notebook setting.
When you click an Igor-object picture, Igor displays the name of the object from which the picture was gen-
erated and the time at which it was generated in the notebook’s status area.
The first Graph0 shown in the status area is the name of the picture special character and the second Graph0 
is the name of the source graph for the picture. There is no requirement that these be the same but they 
usually will be.
If you change the Igor graph, table, layout or Gizmo plot, you can update the associated picture by selecting 
it and choosing Update Selection Now from the NotebookSpecial menu or by right-clicking and choosing 
Update Selection from the contextual menu. You can update all Igor-object pictures as well as any other 
special characters in the notebook by clicking anywhere so that nothing is selected and then choosing 
Update All Now from the NotebookSpecial menu.
An Igor object picture can be updated even if it was created on another platform using a platform-depen-
dent format. For example, you can create an EMF Igor object picture on Windows and paste it into a note-
