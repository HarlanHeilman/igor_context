# Long Object Names

Chapter III-17 — Miscellany
III-502
Namespaces
When you refer to an object by name, in a user function for example, each object must be referenced unam-
biguously. In general, an object must have a unique name so. Sometimes the object type can be inferred 
from the context, in which case the name can be the same as objects of other types. Objects whose names 
can be the same are said to be in different namespaces.
Data folders are in their own name space. Therefore the name of a data folder can be the same as the name 
of any other object, except for another data folder at the same level of the hierarchy.
Waves and variables (numeric and string) are in the same name space and so Igor will not let you create a 
wave and a variable in a single data folder with the same name.
An annotation is local to the window containing it. Its name must be unique only among annotations in the 
same window. The same applies for controls and rulers. Data folders, waves, variables, windows, symbolic 
paths and pictures are global objects, not associated with a particular window.
The names of global objects, except for data folders, are required to be distinct from the names of macros, 
functions (built-in, external or user-defined) and operations (built-in or external).
Here is a summary of the four global namespaces:
Object Name Functions
These functions are useful for programmatically generating object names: CreateDataObjectName, Check-
Name, CleanupName, UniqueName.
Long Object Names
Prior to Igor Pro 8.00, names were limited to 31 bytes. Now names can be up to 255 bytes in length.
The following types of objects support long names in Igor Pro 8.00 or later:
•
Data folders
•
Waves
•
Variables
•
Windows
•
Axes
•
Annotations
•
Controls
•
Special characters in formatted notebooks
•
Symbolic paths
•
XOPs, external operations, external functions
In addition, in Igor8, wave dimension labels and procedure names can be up to 255 bytes in length.
The following types of objects are still limited to names of 31 bytes or less:
•
Rulers in formatted notebooks
Name Space
Requirements
Data folders
Names must be distinct from other data folders at the same level of the 
hierarchy.
Waves, variables, windows
Names must be distinct from other waves, variables (numeric and string), 
windows.
Pictures
Names must be distinct from other pictures.
Symbolic paths
Names must be distinct from other symbolic paths.
