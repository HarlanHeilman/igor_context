# Creating Procedure Windows

Chapter III-13 — Procedure Windows
III-397
Compiling the Procedures
When you modify the text in the procedure window, you will notice that a Compile button appears at the bottom 
of the window.
Clicking the Compile button scans the procedure window looking for macros, functions and menu defini-
tions. Igor compiles user-defined functions, generating low-level instructions that can be executed quickly.
Igor also compiles the code in the procedure window if you choose Compile from the Macros menu or if 
you activate any window other than a procedure or help window.
Templates Pop-Up Menu
The Templates pop-up menu lists all of the built-in and external operations and functions in alphabetical 
order and also lists the common flow control structures.
If you choose an item from the menu, Igor inserts the corresponding template in the procedure window.
If you select, click in, or click after a recognized operation, function or flow-control keyword in the proce-
dure window, two additional items are listed at the top of the menu. The first item inserts a template and 
the second takes you to help.
In addition to templates, procedure windows also support Command Completion.
Procedure Navigation Bar
The procedure navigation bar appears at the top of each procedure window. It consists of a menu and a 
settings button. The menu provides a quick way to find procedures in the active procedure window.
Certain syntax errors prevent Igor from parsing procedures. In that case, the menu shows no procedures.
You can hide the navigation bar by choosing Misc-Miscellaneous Settings, selecting the Text Editing sec-
tion, and unchecking the Show Navigation Bar checkbox.
Write-Protect Icon
Procedure windows have a write-enable/write-protect icon which appears in the lower-left corner of the 
window and resembles a pencil. If you click this icon, Igor Pro displays an icon indicating that the proce-
dure window is write-protected. The main purpose of this is to prevent accidental alteration of shared pro-
cedure files.
Igor opens included user procedure files for writing but turns on the write-protect icon so that you will get 
a warning if you attempt to change them. If you do want to change them, simply click the write-protect icon 
to turn protection off. You can turn this default write-protection off via the Text Encoding section of the Mis-
cellaneous Settings dialog.
If a procedure file is opened for reading only, you will see a lock icon instead of the pencil icon. A file 
opened for read-only can not be modified.
WaveMetrics procedures, in the WaveMetrics Procedures folder, are assumed to be the same for all Igor users 
and should not be modified by users. Therefore, Igor opens included WaveMetrics procedures for reading 
only.
Magnifier Icon
You can magnify procedure text to make it more readable. See Text Magnification on page II-53 for details.
Creating Procedure Windows
There are three ways to create procedures:
•
Automatically by Igor
