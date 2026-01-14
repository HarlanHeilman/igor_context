# Writing General-Purpose Procedures

Chapter IV-7 — Programming Techniques
IV-167
Igor looks for the version information when the user invokes the File Information dialog from the Proce-
dure menu. If the file has version information, Igor displays the version next to the file name in the dialog.
Igor also looks for version information when it opens an included file. An include statement can require a 
certain version of the included file using the following syntax:
#include <Bivariate Histogram> version>=1.02
If the required version of the procedure file is not available, Igor displays a warning to inform the user that 
the procedure file needs to be updated.
In Igor Pro 9.01 and later, you can programmatically determine the procedure file’s version using the Pro-
cedureVersion function.
Turning the Included File’s Menus Off
Normally an included procedure file’s menus and menu items are displayed. However, if you are including 
a file merely to call one of its procedures, you may not want that file’s menu items to appear. To suppress 
the file’s menus and menu items, use:
#include <Decimation> menus=0
To use both the menus and version options, you must separate them with a comma:
#include <Decimation> menus=0, version>=1.1
Optionally Including Files
Compilation usually ceases and returns an error if the included file isn't found. On occasion it is advanta-
geous to allow compilation to proceed if an included file isn't present or is the wrong version. Optionally 
including a procedure file is appropriate only if the file truly isn't needed to make procedures compile or 
operate.
Use the "optional" keyword to optionally include a procedure file:
#include <Decimation> version>=1.1, optional
Writing General-Purpose Procedures
Procedures can be placed on a scale ranging from general to specific. Usually, the high-level procedures of 
a program are specific to the task at hand and call on more general, lower-level procedures. The most 
general procedures are often called “utility” procedures.
You can achieve a high degree of productivity by building a library of utility procedures that you reuse in 
different programs. In Igor, you can think of the routines in an experiment’s built-in Procedure window as 
a program. It can call utility routines which should be stored in a separate procedure file so that they are 
available to multiple experiments.
The files stored in the WaveMetrics Procedures folder contain general-purpose procedures on which your 
high-level procedures can build. Use the include statement (see The Include Statement on page IV-166) to 
access these and other utility files.
When you write utility routines, you should keep them as general as possible so that they can be reused as 
much as possible. Here are some guidelines.
•
Avoid the use of global variables as inputs or outputs. Using globals hard-wires the routine to spe-
cific names which makes it difficult to use and limits its generality.
•
If you use globals to store state information between invocations of a routine, package the globals 
in data folders.
WaveMetrics packages usually create data folders inside “root:Packages”. We use the prefix “WM” for 
data folder names to avoid conflict with other packages. Follow this lead and should pick your own 
data folder names so as to minimize the chance of conflict with WaveMetrics packages or with others. 
See Managing Package Data on page IV-249 for details.
