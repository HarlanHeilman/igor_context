# Destination Wave Reference Issues

Chapter IV-3 — User-Defined Functions
IV-86
In the last technique, the destination wave parameter is a wave reference. This technique works properly 
only if the referenced wave already exists. Otherwise the destination wave is a wave with the name of the 
wave reference itself (w in this case) in the current data folder. This situation is further explained below 
under Destination Wave Reference Issues on page IV-86.
Wave Reference as Destination Wave
Here are the rules for wave references when used as destination waves:
1. If a simple name (not a wave reference) is passed as the destination wave parameter, the destination 
wave is a wave of that name in the current data folder whether it exists or not.
2. If a path or $ followed by a string containing a path is passed as the destination wave parameter, the 
destination wave is specified by the path whether the specified wave exists or not.
3. If a wave reference is passed as the destination wave parameter, the destination wave is the refer-
enced wave if it exists. See Destination Wave Reference Issues on page IV-86 for what happens if 
it does not exist.
Exceptions To Destination Wave Rules
The Make operation is an exception in regard to wave references. The following statements make a wave 
named w in the current data folder whether root:FolderA:jack exists or not:
Wave/Z w = root:FolderA:jack
Make/O w
Prior to Igor Pro 6.20, many operations behaved like Make in this regard. In Igor Pro 6.20 and later, most 
operations behave like Differentiate.
Updating of Destination Wave References
When a simple name is provided as the destination wave parameter in a user-defined function, Igor auto-
matically creates a wave reference variable of that name at compile time if one does not already exist. This 
is an implicit automatic wave reference variable.
When a wave reference variable exists, whether implicit or explicit, during the execution of the command, 
the operation stores a reference to the destination wave in that wave reference variable. You can use the 
wave reference to access the destination wave in subsequent commands.
Similarly, when the destination is specified using a wave reference field in a structure, the operation 
updates the field to refer to the destination wave.
Inline Wave References With Destination Waves
When the destination wave is specified using a path or a string containing a path, you can use an inline 
wave reference to create a reference to the destination wave. For example:
String dest = "root:FolderA:jack"
Differentiate input /D=$dest/WAVE=wDest
Display wDest
Here the Igor compiler creates a wave reference named wDest. The Differentiate operation stores a refer-
ence to the destination wave (root:FolderA:jack in this case) in wDest which can then be used to access the 
destination wave in subsequent commands.
Inline wave references do not determine which wave is the destination wave but merely provide a wave 
reference pointing to the destination wave when the command finishes.
Destination Wave Reference Issues
You will get unexpected behavior when a wave reference variable refers to a wave with a different name or 
in a different data folder and the referenced wave does not exist. For example, if the referenced wave does 
not exist:
