# AdoptFiles

AdoptFiles
V-23
Details
If your original AppendViolinPlot command included an X wave, the total number of waves in the violin 
plot trace cannot be greater than the number of points in your X wave.
If the violin plot trace is defined by a multicolumn wave, you cannot add additional waves using this 
operation.
See Also
Violin Plots on page II-337, AppendViolinPlot, ModifyViolinPlot
AdoptFiles 
AdoptFiles [flags]
The AdoptFiles operation adopts external files and waves into the current experiment.
When the experiment is next saved, the files and waves are saved in the experiment file for a packed 
experiment or in the experiment folder for an unpacked experiment. References to the external files are 
eliminated.
AdoptFiles cannot be called from a function except via Execute/P.
Flags
/INST=traceInstance
These flags specify the name and instance number of an existing violin plot trace 
to which waves will be added. You can use /T without /INST, in which case a trace 
with instance number zero will be used. Do not use /INST without /T.
See Creating Graphs on page II-277 for information about trace names and trace 
instance numbers.
In the absence of both /T and /INST, the default is to use the top violin plot trace 
found on the graph. That would be the most recently added violin plot trace.
/W=winName
Appends to the named graph window or subwindow. When omitted, 
AppendViolinPlot operates on the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
/A
Adopts all external notebooks and user procedure files and all waves in the 
experiment. WaveMetrics Procedure files are not adopted. /A is equivalent to 
/NB/UP/DF.
/DF
Adopts all waves saved external to the experiment.
/DF=dataFolderPathStr
Adopts all waves saved external to the experiment that are in the specified data 
folder.
/I
Shows the Adopt All dialog and adopts what the user selects there.
/NB
Adopts all external notebook files.
/UP
Adopts all external user procedure files.
/W=winTitleOrName
Adopts the specified notebook or procedure file. /W was added in Igor Pro 7.02.
winTitleOrName is a name, not a string, so you construct /W like this:
/W=$"New Polar Graph.ipf"
or:
/W=Notebook0
When working with independent modules, winTitleOrName is a procedure 
window title followed by a space and, in brackets, an independent module name. 
See Independent Modules on page IV-238 for details.
/WP
Adopts all WaveMetrics Procedure procedure files.
