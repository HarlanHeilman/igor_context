# Object Name Conflicts and HDF5 Files

Chapter III-17 — Miscellany
III-505
Object Name Conflicts
In general, Igor does not allow two objects in the same namespace to have the same name. (To see a list of Igor 
namespaces, see Namespaces on page III-502.) The rest of this section discusses some exceptions to this rule 
and related issues. Most users will not need to know this material.
Object Name Conflicts That Igor Allows
Igor allows you to create name conflicts between waves, variables, and data folders with certain exceptions 
listed below. For example:
Function DemoAllowedNameConflicts()
// Execute this in a new experiment
Make/O root:test
// to demonstrate that Igor allows
Variable/G root:test
// name conflicts in some cases
NewDataFolder/O root:test
End
This shows that Igor allows you to create a wave and a global variable with the same name and to create a 
data folder with the same name as a wave or a global variable.
Allowing a wave and a global variable to have the same name is a historical accident that should not have 
been allowed because waves and variables are in the same namespace, called the "main namespace". This may 
be disallowed in a future version of Igor.
Allowing a data folder to have the same name as a wave or variable is intended because data folders are in 
their own namespace.
The following exceptions specify the name conflicts in the main namespace that are not allowed:
1.
It is an error to create a variable with the same name as an existing wave from a macro, proc, or from 
the command line (but it is not an error from a user-defined function as shown above).
2.
It is an error to create a wave with the same name as an existing variable from any context (function, 
macro, proc, or from the command line).
The table below expresses those rules. The left column shows the type of object created first and the top row 
shows the type of object created second.
F means that Igor returns an error if you attempt to create the objects in a function.
M means that Igor returns an error if you attempt to create the objects in a macro, proc, or from the command 
line.
--- means Igor returns no error from a function, macro, proc, or from the command line.
Object Name Conflicts and HDF5 Files
When saving an experiment in packed or unpacked format, these name conflicts do not cause a problem. If 
you save and reload the experiment, you get back to where you started.
However, name conflicts do cause problems with HDF5 files, saved via Save Experiment or via the 
HDF5SaveGroup operation, because HDF5 does not allow a group and a dataset to have the same name.
•
If there is a conflict between a wave or variable and a data folder, you get an error when you at-
Wave
Variable
Data Folder
Wave
N/A
M
---
Variable
F, M
N/A
---
Data Folder
---
---
N/A
