# The Kill Paths Dialog

Chapter II-3 — Experiments, Files and Folders
II-23
The NewPath operation can also accept Windows-style paths with backslash characters, but this can cause 
problems and is not recommended. For details, see Path Separators on page III-451.
Once you have created it, you can select the Data path in dialogs where you need to choose a file. For exam-
ple, in the Load Waves dialog, you can select Data from the Path list. You then click the File button and 
choose the file to be loaded. Igor generates a command like:
LoadWave /J /P=Data "Data1.txt"
LoadWave /J /P=Data "Data2.txt"
LoadWave /J /P=Data "Data3.txt"
These commands load data files from the June folder.
By using a symbolic path instead of the full path to the file to be loaded, you have isolated the location of 
the data files in one object - the symbolic path itself. This makes it easy to redirect commands or procedures 
that use the symbolic path. For example, you can re-execute the NewPath command replacing June with 
July:
NewPath/O Data, "hd:Users:Jack:Documents:Data:2016:July"
// Macintosh
NewPath/O Data, "C:Users:Jack:Documents:Data:2016:July"
// Windows
Now, if you re-execute the LoadWave commands, they will load data from July instead of June.
Isolating a specific location on disk in a symbolic path also simplifies life when you move from one user to 
another or from one machine to another. Instead of needing to change the full path in many commands, you 
can simply change the symbolic path.
Automatically Created Paths
Igor automatically creates a symbolic path named Igor which refers to the “Igor Pro 9 Folder”. The Igor sym-
bolic path is useful only in rare cases when you want to access a file in the Igor Pro folder.
Igor also automatically creates a symbolic path named IgorUserFiles which refers to the Igor Pro User Files 
folder - see Special Folders for details. The IgorUserFiles symbolic path was added in Igor Pro 7.00.
Igor also automatically creates the home symbolic path. This path refers to the home folder for the current 
experiment. For unpacked experiments, this is the experiment folder. For packed experiments, this is the 
folder containing the experiment file. For new experiments that have never been saved, home is undefined.
Finally, Igor automatically creates a symbolic path if you do something that causes the current experiment 
to reference a file not stored as part of the experiment. This happens when you:
•
Load an Igor binary wave file from another experiment into the current experiment
•
Open a notebook file not stored with the current experiment
•
Open a procedure file not stored with the current experiment
Creating these paths makes it easier for Igor to find the referenced files if they are renamed or moved. See 
References to Files and Folders on page II-24 for more information.
Symbolic Path Status Dialog
The Symbolic Path Status dialog shows you what paths exist in the current experiment. To invoke it, choose 
Path Status from the Misc menu.
The dialog also shows waves, notebook files, and procedure files referenced by the current experiment via 
a given symbolic path.
The Kill Paths Dialog
The Kill Symbolic Paths dialog removes from the current experiment symbolic paths that you no longer 
need. To invoke the dialog, choose Kill Paths from the Misc menu.
