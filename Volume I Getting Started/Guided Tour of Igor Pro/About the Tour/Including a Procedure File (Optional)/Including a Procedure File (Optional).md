# Including a Procedure File (Optional)

Chapter I-2 — Guided Tour of Igor Pro
I-63
6.
Click the close button on the Append Residuals procedure window.
Igor asks if you want to kill or hide the file.
7.
Click the Kill button.
This removes the file from the current experiment, but it still exists on disk and you can open it as 
needed.
There are several ways to open the procedure file to use it in the future. One is to double-click it. 
Another is to choose the FileOpen FileProcedure menu item. A third is to put a #include state-
ment in the built-in procedure window, which is how we will open it in the next section.
Including a Procedure File (Optional)
The preferred way to open a procedure window that you intend to use from several different experiments 
is to use a #include statement. This section demonstrates how to do that.
Note:
If you are using the demo version of Igor Pro beyond the 30-day trial period, you did not create the Append 
Residuals.ipf file in the preceding section so you can’t do this section.
1.
In Igor, use the WindowsProcedure WindowsProcedure Window to open the built-in proce-
dure window.
2.
Near the top of the built-in procedure window, notice the line that says:
#pragma rtGlobals = 3
This is technical stuff that you can ignore.
3.
Under the rtGlobals line, leave a blank line and then enter:
#include "Append Residuals"
4.
Click the Compile button at the bottom of the built-in procedure window.
Igor compiles the procedure window. When it sees the #include statement, it looks for the “Append 
Residuals.ipf” procedure file in the User Procedures folder and opens it. You don't see it because it 
was opened hidden.
5.
Use the WindowsProcedure Windows menu to verify that the Append Residuals procedure file 
is in fact open.
To remove the procedure file from the experiment, you would remove the #include statement from 
the built-in procedure window.
#include is powerful because it allows procedure files to include other procedure files in a chain. Each 
procedure file automatically opens any other procedure files it needs.
User Procedures is special because Igor searches it to satisfy #include statements.
Another special folder is Igor Procedures. Any procedure file in Igor Procedures is automatically 
opened by Igor at launch time and left open till Igor quits. This is the place to put procedure files that 
you want to be open all of the time. It is the easiest way to make a procedure file available and is rec-
ommended for frequently-used files.
This concludes Guided Tour 3.
