# Renaming Objects

Chapter III-17 — Miscellany
III-504
In Igor Pro 6.38 and Igor Pro 7.01, a bug was fixed that cause Igor to crash if you load a formatted notebook 
file containing a long special action name and you attempt to modify that special action.
Programming With Long Object Names
If your code must run with Igor7 or before, the best strategy is to avoid using long object names. Attempting 
to conditionally support long object names will make your code complex and fragile. A better approach is 
to freeze your Igor7 code and add new features to an Igor8 or later branch.
If you must use conditional programming, you can test whether the running version of Igor supports long 
object names like this:
Variable maxObjectNameLength = 31
if (IgorVersion() >= 8.00)
maxObjectNameLength = 255
endif
The names of functions, constants, variables and other programming entities can be up to 255 bytes, but if 
you use names longer than 31 bytes, your procedures will require Igor Pro 8.00 or later.
Package names can be up to 255 bytes, but if you use a name longer than 31 bytes, your package will require 
Igor Pro 8.00 or later.
Long Object Names and XOPs
For most of recorded history, XOPs supported a maximum object name length of 31. Igor now support long 
object names but pre-existing XOPs continue to work as before. However, if you attempt to use a long object 
name with a pre-existing XOP, you will get an error. For example:
NewPath SymbolicPathWithANameThatExceeds31Bytes, <path>
OldFileLoader /P=SymbolicPathWithANameThatExceeds31Bytes <path>
This returns an error because the hypothetical OldFileLoader XOP has not been updated to work with long 
object names. It continues to work with short object names.
If a pre-existing XOP attempts to retrieve the name of a wave or data folder which has a long name, Igor 
returns an error to the XOP. If the XOP is properly written, it will generate a "name too long" error and Igor 
will report the error.
As of XOP Toolkit 8, the XOP Toolkit supports creating XOPs that work with long object names. Supporting 
long names requires that the XOP programmer modify and recompile the XOP. XOPs compiled to support 
long object names will require Igor Pro 8 or later. Consequently, many XOPs will not support them.
As of this writing, if the name of the XOP itself, without the ".xop" extension, exceeds 31 bytes in length, the 
XOP will not be able to save settings using the SAVESETTINGS message or load settings using the LOAD-
SETTINGS message. Consequently it is best to avoid creating an XOP whose name exceeds 31 bytes.
Renaming Objects
You can use MiscRename Objects or DataRename to rename waves, variables, strings, symbolic paths, 
and pictures. Both of these invoke the Rename Objects dialog.
Graphs, tables, page layouts, notebooks, control panels, Gizmo windows, and XOP target windows are 
renamed using the DoWindow operation (see page V-168) which you can build using the Window Control 
dialog (see The Window Control Dialog on page II-49).
You can use the Data Browser to rename data folders, waves, and variables. See The Data Browser on page 
II-114.
