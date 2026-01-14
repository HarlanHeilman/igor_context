# Saving a Procedure File (Optional)

Chapter I-2 — Guided Tour of Igor Pro
I-62
26.
Click Continue.
The graph should once again contain the residuals plotted on an axis above the main data.
Next we will add a menu item to the Macros menu.
27.
Choose WindowsProcedure WindowsAppend Residuals to show the Append Residuals proce-
dure window.
28.
Enter the following code before the AppendResiduals function:
Menu "Macros"
"Append Residuals...", AppendResidualsDialog()
End
29.
Click the Compile button.
Igor compiles procedures and adds the menu item to the Macros menu.
30.
Shift-click the close button to hide the procedure window. Then activate Graph1.
31.
Control-click (Macintosh) or right-click (Windows) the residual trace at the top of the graph and 
select “Remove histResids” from the pop-up menu.
32.
Click the Macros menu and choose the “Append Residuals” item
The procedure displays a dialog to let you choose parameters.
33.
Choose histResids from the Residuals Data pop-up menu.
34.
Leave the X Wave pop-up menu set to “_calculated_”.
35.
Click the Continue button.
The graph should once again contain the residuals plotted on a new axis above the main data.
Saving a Procedure File (Optional)
Note:
If you are using the demo version of Igor Pro beyond the 30-day trial period, you cannot save a procedure file.
Now that we have a working procedure, let’s save it so it can be used in the future. We will save the file in 
the "Igor Pro User Files" folder - a folder created by Igor for you to store your Igor files.
More precisely, we will save the procedure file in the "User Procedures" subfolder of the Igor Pro User Files 
folder. You could save the file anywhere on your hard disk, but saving in the User Procedures subfolder 
makes it easier to access the file as we will see in the next section.
1.
Choose HelpShow Igor Pro User Files.
Igor opens the "Igor Pro User Files" folder on the desktop.
By default, this folder has the Igor Pro major version number in its name, for example, "Igor Pro 9 User 
Files", but it is generically called the "Igor Pro User Files" folder.
Note where in the file system hierarchy this folder is located as you will need to know this in a sub-
sequent step. The default locations are:
Macintosh:
/Users/<user>/Documents/WaveMetrics/Igor Pro 9 User Files
Windows:
C:\Users\<user>\Documents\WaveMetrics\Igor Pro 9 User Files
Note the "User Procedures" subfolder of the Igor Pro User Files folder. This is where we will save the 
procedure file.
2.
Back in Igor, choose WindowsProcedure WindowsAppend Residuals to show the Append Resid-
uals procedure window.
3.
Choose FileSave Procedure As.
4.
Enter the file name “Append Residuals.ipf”.
5.
Navigate to your User Procedures folder inside your Igor Pro User Files folder and click Save.
The Append Residuals procedure file is now saved in a standalone file.
