# Procedure File Version Information

Chapter IV-7 — Programming Techniques
IV-166
Overview 
This chapter discusses programming techniques and issues that go beyond the basics of the Igor program-
ming language and which all Igor programmers should understand. Techniques for advanced program-
mers are discussed in Chapter IV-10, Advanced Topics.
The Include Statement
The include statement is a compiler directive that you can put in your procedure file to open another pro-
cedure file. A typical include statement looks like this:
#include <Split Axis>
This statement opens the file "Split Axis.ipf" in the WaveMetrics Procedures folder. Once this statement has 
been compiled, you can call routines from that file. This is the recommended way to access procedure files 
that contain utility routines.
The # character at the beginning specifies that a compiler directive follows. Compiler directives, except for 
conditional compilation directives, must start at the far left edge of the procedure window with no leading 
tabs or spaces. Include statements can appear anywhere in the file but it is conventional to put them near 
the top.
It is possible to include a file which in turn includes other files. Igor opens all of the included files.
Igor opens included files when it compiles procedures. If you remove an include statement from a proce-
dure file, Igor automatically closes the file on the next compile.
There are four forms of the include statement:
1.
Igor searches for the named file in "Igor Pro Folder/WaveMetrics Procedures" and in any subfolders:
#include <fileName>
Example:
#include <Split Axis>
2.
Igor searches for the named file in "Igor Pro Folder/User Procedures" and "Igor Pro User Files/User 
Procedures" and in any subfolders:
#include "fileName"
Example:
#include "Utility Procs"
3.
Igor looks for the file only in the exact location specified:
#include "full file path"
Example:
#include "Hard Disk:Procedures:Utility Procs"
4.
Igor looks for the file relative to the Igor Pro folder and the Igor Pro User Files folder and the folder 
containing the procedure file that contains the #include statement:
#include ":partial file path"
Example:
#include ":Spectroscopy Procedures:Voigt Procs"
Igor looks first relative to the Igor Pro Folder. If that fails, it looks relative to the Igor Pro User Files 
folder. If that fails it looks relative to the procedure file containing the #include statement or, if the 
#include statement is in the built-in procedure window, relative to the experiment file.
The name of the file being included must end with the standard “.ipf” extension but the extension 
is not used in the include statement.
Procedure File Version Information
If you create a procedure file to be used by other Igor users, it’s a good idea to add version information to 
the file. You do this by putting a #pragma version statement in the procedure file. For example:
#pragma version = 1.10
This statement must appear with no indentation and must appear in the first 50 lines of the file. If Igor finds 
no version pragma, it treats the file as version 1.00.
