# Inserting Graphics

Chapter III-1 — Notebooks
III-26
There is currently no way to set headers and footers from Igor procedures. A workaround is to create a sta-
tionery (Macintosh) or template (Windows) notebook file with the headers and footers that you want and to 
open this instead of creating a new notebook.
In addition, the SpecialCharacterList function (see page V-895) and SpecialCharacterInfo function (see 
page V-893) may be of use.
The Notebook Demo #1 experiment, in the Examples:Feature Demos folder, provides a simple illustration 
of generating a report notebook using Igor procedures.
See Notebooks as Subwindows in Control Panels on page III-91 for information on using a notebook as a 
user-interface element.
Some example procedures follow.
Logging Text
This example shows how to add an entry to a log. Since the notebook is being used as a log, new material 
is always added at the end.
// Function AppendToLog(nb, str, stampDateTime)
// Appends the string to the named notebook.
// If stampDateTime is nonzero, appends date/time before the string.
Function AppendToLog(nb, str, stampDateTime)
String nb
// name of the notebook to log to
String str
// the string to log
Variable stampDateTime
// nonzero if we want to include stamp
Variable now
String stamp
Notebook $nb selection={endOfFile, endOfFile}
if (stampDateTime)
now = datetime
stamp = Secs2Date(now,0) + ", " + Secs2Time(now,0) + "\r"
Notebook $nb text=stamp
endif
Notebook $nb text= str+"\r"
End
You can test this function with the following commands:
NewNotebook/F=1/N=Log1 as "A Test"
AppendToLog("Log1", "Test #1\r", 1)
AppendToLog("Log1", "Test #2\r", 1)
The sprintf operation (see page V-902) is useful for generating the string to be logged.
Inserting Graphics
There are two kinds of graphics that you can insert into a notebook under control of a procedure:
•
A picture generated from a graph, table, layout or Gizmo plot (an “Igor-object” picture).
•
A copy of a named picture stored in the current experiment’s picture gallery.
GetSelection
Retrieves the selected text.
SpecialCharacterList
Returns a list of the names of special characters in the notebook.
SpecialCharacterInfo
Returns information about a specific special character.
KillWindow
Kills a notebook.
Operation
What It Does
