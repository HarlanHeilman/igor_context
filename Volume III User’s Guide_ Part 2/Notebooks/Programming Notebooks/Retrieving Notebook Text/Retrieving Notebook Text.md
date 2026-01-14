# Retrieving Notebook Text

Chapter III-1 — Notebooks
III-28
Updating Igor-Object Pictures
The following command updates all pictures in the notebook made from Igor graphs, tables, layouts or 
Gizmo plots from the current experiment.
Notebook Notebook0 specialUpdate=0
More precisely, it will update all dynamic special characters, including date and time characters as well as 
Igor-object pictures.
This next fragment shows how to update just one particular Igor-object picture.
String nb = "Notebook0"
Notebook $nb selection={startOfFile, startOfFile}
Notebook $nb findPicture={"Graph0", 1}
if (V_Flag)
Notebook $nb specialUpdate=1
else
Beep
// can't find Graph0
endif
Igor will normally refuse to update special characters unless updating is enabled, via the Enable Updating 
dialog (Notebook menu). You can override this and force Igor to do the update by using 3 instead of 1 for 
the specialUpdate parameter.
Retrieving Notebook Text
Since you can retrieve text from a notebook, it is possible to use a notebook as an input mechanism for a 
procedure. To illustrate this, here is a procedure that tags each point of a wave in the top graph with a string 
read from the specified notebook. The do-loop in this example shows how to pick out each paragraph from 
the start to the end of the notebook.
#pragma rtGlobals=1
// Make V_Flag and S_Selection be local variables.
// TagPointsFromNotebook(nb, wave)
// nb is the name of an open notebook.
// wave is the name of a wave in the top graph.
// TagPointsFromNotebook reads each line of the notebook and uses it
// to tag the corresponding point of the wave.
Function TagPointsFromNotebook(nb, wave)
String nb
// name of notebook
String wave
// name of the wave to tag
String name
// name of current tag
String text
// text for current tag
Variable p
p = 0
do
// move to current paragraph
Notebook $nb selection={(p, 0), (p, 0)}
if (V_Flag)
// no more lines in file?
break
endif
// select all characters in paragraph up to trailing CR
Notebook $nb selection={startOfParagraph, endOfChars}
GetSelection notebook, $nb, 2
// Get the selected text
text = S_Selection
// S_Selection is set by GetSelection
if (strlen(text) > 0)
// skip if this line is empty
name = "tag" + num2istr(p)
Tag/C/N=$name/F=0/L=0/X=0/Y=8 $wave, pnt2x($wave, p), text
endif
