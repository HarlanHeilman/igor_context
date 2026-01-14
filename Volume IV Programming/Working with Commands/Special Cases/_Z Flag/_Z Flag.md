# /Z Flag

Chapter IV-1 — Working with Commands
IV-21
Indexes start from zero. For graphs, the object index refers to traces starting from the first trace placed in 
the graph. For tables the index refers to columns from left to right. For page layouts, the index refers to 
objects starting from the first object placed in the layout.
/Z Flag
The ModifyGraph marker command above works fine if you know that there are three waves in the graph. 
It will, however, generate an error if you use it on a graph with fewer than 3 waves. The ModifyGraph oper-
ation supports a flag that can be used to handle this:
ModifyGraph/Z marker[0]=1, marker[1]=2, marker[2]=3
The /Z flag ignores errors if the command tries to modify an object that doesn’t exist. The /Z flag works with 
the SetAxis and Label operations as well as with the ModifyGraph, ModifyTable and ModifyLayout oper-
ations. Like object indexing, the /Z flag is primarily of use in creating style macros, which is done automat-
ically, but it may come in handy for other uses.

Chapter IV-1 — Working with Commands
IV-22
