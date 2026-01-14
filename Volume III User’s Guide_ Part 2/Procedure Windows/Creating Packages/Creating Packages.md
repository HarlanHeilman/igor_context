# Creating Packages

Chapter III-13 — Procedure Windows
III-401
Saving Shared Procedure Files
If you modify a shared procedure file, Igor saves it when you save the experiment that is sharing it. How-
ever, you might want to save the procedure file without saving the experiment. For this, choose FileSave 
Procedure.
Including a Procedure File
You can put an include statement in any procedure file. An include statement automatically opens another 
procedure file. This is the recommended way of accessing files that contain utility routines which you may 
want to use in several experiments. Using an include statement is preferable to opening a procedure file 
explicitly because it doesn’t rely on the exact location of the file in the file system hierarchy.
Here is a typical include statement:
#include <MatrixToXYZ>
This automatically opens the MatrixToXYZ.ipf file supplied by WaveMetrics in "Igor ProFolder/WaveMet-
rics Procedures/Data Manipulation". The angle brackets tell Igor to search the "Igor Pro Folder/WaveMetrics 
Procedures" hierarchy.
To see what WaveMetrics procedure files are available, choose HelpHelp WindowsWM Procedures Index.
You can include your own utility procedure files by using double-quotes instead of the angle-brackets 
shown above:
#include "Your Procedure File"
The double-quotes tell Igor to search the "Igor Pro Folder/User Procedures" and "Igor Pro User Files/User 
Procedures" hierarchies (see Igor Pro User Files on page II-31 for details) for the named file. Igor searches 
those folders and subfolders and files or folders referenced by aliases/shortcuts in those folders.
These are the two main variations on the include statement. For details on less frequently used variations, 
see The Include Statement on page IV-166.
Included procedure files are not considered part of the experiment but are automatically opened by Igor 
when it compiles the experiment’s procedures.
To prevent accidental alteration of an included procedure file, Igor opens it either write-protected (User 
Procedures) or read-only (WaveMetrics Procedures). See Write-Protect Icon on page III-397.
A #include statement must omit the file’s “.ipf” extension:
#include <Strings as Lists>
// RIGHT
#include <Strings as Lists.ipf>
// WRONG
Creating Packages
A package is a set of procedure files, help files and other support files that add significant functionality to 
Igor.
Igor comes pre-configured with numerous WaveMetrics packages accessed through the DataPackages, 
AnalysisPackages, MiscPackages, WindowsNewPackages and GraphPackages submenus as 
well as others.
Intermediate to advanced programmers can create their own packages. See Packages on page IV-246 for 
details.
