# WaveMetrics Procedure Files

Chapter IV-2 — Programming Overview
IV-25
At first you will find it convenient to do all of your Igor programming in the built-in Procedure window. In 
the long run, however, it will be useful to organize your procedures into categories so that you can easily 
find and access general-purpose procedures and keep them separate from special-case procedures.
This table shows how we categorize procedures and how we store and access the different categories.
Following this scheme, you will know where to put procedure files that you get from colleagues and where 
to look for them when you need them.
Utility and global procedures should be general-purpose so that they can be used from any experiment. Thus, 
they should not rely on specific waves, global variables, global strings, specific windows or any other objects spe-
cific to a particular experiment. See Writing General-Purpose Procedures on page IV-167 for further guidelines.
After they are debugged and thoroughly tested, you may want to share your procedures with other Igor 
users via IgorExchange.
WaveMetrics Procedure Files
WaveMetrics has created a large number of utility procedure files that you can use as building blocks. These 
files are stored in the WaveMetrics Procedures folder. They are described in the WM Procedures Index help 
file, which you can access through the HelpHelp Windows menu.
You access WaveMetrics procedure files using include statements. Include statements are explained under 
The Include Statement on page IV-166.
Using the Igor Help Browser, you can search the WaveMetrics Procedures folder to find examples of par-
ticular programming techniques.
Category
What 
Where
How
Experiment 
Procedures
These are specific to a single Igor 
experiment.
They include procedures you 
write as well as window recreation 
macros created automatically 
when you close a graph, table, 
layout, control panel, or Gizmo 
plot.
Usually experiment procedures 
are stored in the built-in 
Procedure window.
You can optionally create 
additional procedure windows 
in a particular experiment but 
this is usually not needed.
You create an experiment 
procedure by typing in the 
built-in Procedure window.
Utility 
Procedures
These are general-purpose and 
potentially useful for any Igor 
experiment.
WaveMetrics supplies utility 
procedures in the WaveMetrics 
Procedures folder. You can also 
write your own procedures or get 
them from colleagues.
WaveMetrics-supplied utility 
procedure files are stored in the 
WaveMetrics Procedures folder.
Utility procedure files that you or 
other Igor users create should be 
stored in your own folder, in the 
Igor Pro User Files folder (see 
Igor Pro User Files on page 
II-31 for details) or at another 
location of your choosing. Place 
an alias or shortcut for your folder 
in "Igor Pro User Files/User 
Procedures".
Use an include statement to use 
a WaveMetrics or user utility 
procedure file.
Include statements are 
described in The Include 
Statement on page IV-166.
Global 
Procedures
These are procedures that you 
want to be available from all 
experiments.
Store your global procedure files 
in "Igor Pro User Files/Igor 
Procedures" (see Igor Pro User 
Files on page II-31 for details).
You can also store them in 
another folder of your choice and 
place an alias or shortcut for your 
folder in "Igor Pro User Files/Igor 
Procedures".
Igor automatically opens any 
procedure file in "Igor Pro 7 
Folder/Igor Procedures" and 
"Igor Pro User Files/Igor 
Procedures" and subfolders or 
referenced by an alias or shortcut 
in those folders, and leaves it 
open in all experiments.
