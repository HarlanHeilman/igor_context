# Notebook

Notebook
V-695
Flags
Examples
Note/K wave0
// remove existing note
Note wave0, "This is the first line of the note"
Note wave0, "This is the second line of the note"
Note/K wave0, "This is now the only line of the note"
See Also
To get the contents of a wave note, use the note function.
Notebook 
Notebook winName, keyword=value [, keyword=value]…
The Notebook operation sets various properties of the named notebook window. Notebook also inserts text 
and graphics. See Chapter III-1, Notebooks, for general information on notebooks.
Notebook returns an error if the notebook is open for read-only. Keywords that don't materially change the 
notebook, including findText, findPicture, selection, visible, magnification, userKillMode, showRuler and 
rulerUnits, are still permitted. See Notebook Read/Write Properties on page III-10 for further information.
Parameters
winName is either kwTopWin for the top notebook window, the name of a notebook window or a host-child 
specification (an hcSpec) such as Panel0#nb0. See Subwindow Syntax on page III-92 for details on host-
child specifications.
If winName is an hcSpec, the host window or subwindow must be a control panel. Graphs and page layouts 
are not supported as hosts for notebook subwindows.
The parameters to the Notebook operation are of the form keyword=value where keyword says what to do and 
value is a parameter or list of parameters. Igor limits the parameters that you specify to legal values before 
applying them to the notebook.
The parameters are classified into related groups of keywords.
See Also
To create or modify a notebook action special character, see NotebookAction.
To create a notebook subwindow in a control panel, see Notebooks as Subwindows in Control Panels on 
page III-91.
/K
Kills existing note for specified wave.
/NOCR
Appends note without a preceding carriage return (\r character). No effect when 
used with /K.
