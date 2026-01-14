# Overview

Chapter II-8 — Data Folders
II-108
Overview
Using data folders, you can store your data within an experiment in a hierarchical manner. Hierarchical 
storage is useful when you have multiple sets of similar data. By storing each set in its own data folder, you 
can organize your data in a meaningful way and also avoid name conflicts.
Data folders contain four kinds of data objects:
•
Waves
•
Numeric variables
•
String variables
•
Other data folders
Igor’s data folders are very similar to a computer’s hierarchical disk file system except they reside wholly 
in memory and not on disk. This similarity can help you understand the concept of data folders but you 
should take care not to confuse them with the computer’s folders and files.
Data folders are particularly useful when you conduct several runs of an experiment. You can store the data 
for each run in a separate data folder. The data folders can have names like “run1”, “run2”, etc., but the 
names of the waves and variables in each data folder can be the same as in the others. In other words, the 
information about which run the data objects belong to is encoded in the data folder name, allowing the 
data objects themselves to have the same names for all runs. You can write procedures that use the same 
wave and variable names regardless of which run they are working on.
Data folders are very handy for programmers who need to store private data between one invocation of 
their procedures and the next. This use of data folders is discussed under Managing Package Data on page 
IV-249.
The Data Browser window allows you to examine the data folder hierarchy. You display it by choosing 
DataData Browser.
One data folder is designated as the “current” data folder. Commands that do not explicitly target a partic-
ular data folder operate on the current data folder. You can see and set the current data folder using the 
Data Browser or using the GetDataFolder and GetDataFolderDFR functions and the SetDataFolder oper-
ation.
You can use the Data Browser not only to see the hierarchy and set the current data folder but also to:
•
Create new data folders.
•
Move, duplicate, rename and delete objects.
•
Browse other Igor experiment files and load data from them into memory.
•
Save a copy of data in the current experiment to an experiment file or folder on disk.
•
See and edit the contents of variables, strings, and waves in the info pane by selecting an object
•
See a simple plot of 1D or 2D waves by selecting one wave at a time in the main list while the plot 
pane is visible.
•
See a simple plot of a wave while browsing other Igor experiments.
•
See variable, string and wave contents by double-clicking their icons.
•
See a simple histogram or wave statistics for one wave at a time.
A similar browser is used for wave selection in dialogs. For details see Dialog Wave Browser on page II-228.
Before using data folders, be sure to read Using Data Folders on page II-112.
Programmers should read Programming with Data Folders on page IV-169.
