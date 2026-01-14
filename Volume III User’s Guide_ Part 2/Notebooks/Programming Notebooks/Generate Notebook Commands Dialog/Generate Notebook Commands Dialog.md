# Generate Notebook Commands Dialog

Chapter III-1 — Notebooks
III-29
p += 1
while (p < numpnts($wave)) // break if we hit the end of the wave
End
More Notebook Programming Examples
For examples using notebook action special characters, see the Notebook Actions Demo example experiment.
These example experiments illustrate notebook programming:
Igor Pro Folder:Examples:Feature Demos:Notebook Actions Demo.pxp
Igor Pro Folder:Examples:Testing:Notebook Operations Test.pxp
Igor Pro Folder:Examples:Testing:Notebook Picture Tests.pxp
Igor Pro Folder:Examples:Feature Demos 2:Notebook in Panel.pxp
Generate Notebook Commands Dialog
The Generate Notebook Commands dialog automatically generates the commands required to reproduce 
a notebook or a section of a notebook. This is intended to make programming a notebook easier. To use it, 
start by manually creating the notebook that you want to later create automatically from an Igor procedure. 
Then choose Generate Commands from the Notebook menu to display the corresponding dialog:
After clicking Store Commands in Clipboard, open the procedure window and paste the commands into a 
procedure.
For a very simple formatted notebook, the commands generated look like this:
String nb = "Notebook2"
NewNotebook/N=$nb/F=1/V=1/W=(5,40,563,359) 
Notebook $nb defaultTab=36,pageMargins={54,54,54,54}
Notebook $nb showRuler=0,rulerUnits=1,updating={1,60}
Notebook $nb newRuler=Normal,justification=0,margins={0,0,504}
Notebook $nb spacing={0,0,0},tabs={}
Notebook $nb rulerDefaults={"Helvetica",10,0,(0,0,0)}
Notebook $nb ruler=Normal,text="This is a test."
To make it easier for you to modify the commands, Igor uses the string variable nb instead of repeating the 
literal name of the notebook in each command.
If the notebook contains an Igor-object picture, you will see a command that looks like
Notebook $nb picture={Graph0(0,0,360,144), 0, 1}
However, if the notebook contains a picture that is not associated with an Igor object, you will see a 
command that looks like
Notebook $nb picture={putGraphicNameHere, 1, 0}
