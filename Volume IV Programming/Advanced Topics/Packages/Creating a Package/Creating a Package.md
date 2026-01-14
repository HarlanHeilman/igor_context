# Creating a Package

Chapter IV-10 — Advanced Topics
IV-247
A package usually adds one or more items to Igor's menus that allow the user to interactively load the pack-
age, access its functionality, and unload the package.
A package typically provides some level of user-interface, such as a menu item and a control panel, for 
accessing the added functionality. It may store settings in experiments or in global preferences.
A package is typically loaded into memory and unloaded at the user's request.
Igor comes pre-configured with numerous WaveMetrics packages accessed through the DataPackages, 
AnalysisPackages, MiscPackages, WindowsNewPackages and GraphPackages submenus as 
well as others. Take a peek at these submenus to see what packages are supplied with Igor.
Menu items for WaveMetrics packages are added to Igor's menus by the WMMenus.ipf procedure file 
which is shipped in the Igor Procedures folder. WMMenus.ipf is hidden unless you enable independent 
module development. See Independent Modules on page IV-238.
Creating a Package
This section shows how to create a package through a simple example. The package is called "Sample Pack-
age". It adds a Load Sample Package item to the Macros menu. When the user chooses Load Sample Pack-
age, the package's procedure file is loaded. This adds two additional items to the Macros menu: Hello From 
Sample Package and Unload Sample Package.
The package consists of two procedure files stored in a folder in the Igor Pro User Files folder. If you are not 
familiar with Igor Pro User Files, take a short detour and read Special Folders on page II-30 and Igor Pro 
User Files on page II-31.
The sample package is installed as follows:
Igor Pro User Files
Sample Package
Sample Package Loader.ipf
Sample Package.ipf
Igor Procedures
Alias or shortcut pointing to the "Sample Package Loader.ipf" file
User Procedures
Alias or shortcut pointing to the "Sample Package" folder
Putting the alias/shortcut for the "Sample Package Loader.ipf" in Igor Procedures causes Igor to load that 
file at launch time. The file adds the "Load Sample Package" item to the Macros menu. See Global Proce-
dure Files on page III-399 for details.
Putting the alias/shortcut for the "Sample Package" folder in User Procedures causes Igor to search that 
folder when a #include is invoked. See Shared Procedure Files on page III-400 for details.
A real package might include other procedure files and a help file in the "Sample Package" folder.
To try this out yourself, follow these steps:
1. 
Create the "Sample Package" folder in your Igor Pro User Files folder.
You can locate your Igor Pro User Files folder using the Help menu.
2.
Create a new procedure file named "Sample Package Loader.ipf" in the "Sample Package" folder and en-
ter the following contents in the file:
Menu "Macros"
"Load Sample Package", /Q, LoadSamplePackage()
End
Function LoadSamplePackage()
Execute/P/Q/Z "INSERTINCLUDE \"Sample Package\""
Execute/P/Q/Z "COMPILEPROCEDURES "// Note the space before final quote
End

Chapter IV-10 — Advanced Topics
IV-248
Save the procedure file.
3.
Create a new procedure file named "Sample Package.ipf" in the "Sample Package" folder and enter the 
following contents in the file:
Menu "Macros"
"Hello From Sample Package", HelloFromSamplePackage()
"Unload Sample Package", UnloadSamplePackage()
End
Function HelloFromSamplePackage()
DoAlert /T="Sample Package Wants to Say" 0, "Hello!"
End
Function UnloadSamplePackage()
Execute /P /Q /Z "DELETEINCLUDE \"Sample Package\""
Execute /P /Q /Z "COMPILEPROCEDURES "// Note the space before final quote
End
Save the procedure file.
4.
In the desktop, make an alias or shortcut for "Sample Package Loader.ipf" file and put it in the Igor Pro-
cedures folder in the Igor Pro User Files folder.
This causes Igor to load the "Sample Package Loader.ipf" file at launch time. This is how the Load Sam-
ple Package menu item gets into the Macros menu.
5.
In the desktop, make an alias or shortcut for the "Sample Package" folder and put it in the User Proce-
dures folder in the Igor Pro User Files folder.
This causes Igor to search the "Sample Package" folder when a #include is invoked. This allows Igor to 
find the "Sample Package.ipf" file when it is #included.
6.
Quit and restart Igor so that Igor will load the "Sample Package Loader.ipf" file.
If you prefer you can just manually make sure that "Sample Package Loader.ipf" is open and "Sample 
Package.ipf" is closed. This simulates the state of affairs after restarting Igor.
7.
Choose WindowsProcedure Windows and verify that Igor has loaded the "Sample Package Load-
er.ipf" file.
8.
Click the Macros menu and verify that the "Load Sample Package" item is present.
9.
Choose MacrosLoad Sample Package.
The LoadSamplePackage function runs, adds a #include statement to the built-in procedure window, 
and forces procedures to be recompiled. This cause Igor to load the "Sample Package.ipf" procedure file 
which contains the bulk of the package's procedures and adds items to the Macros menu.
10. Click the Macros menu and notice that the "Hello From Sample Package" and "Unload Sample Package" 
items have been added.
11. Choose MacrosHello From Sample Package.
The package displays an alert. A real package would do something more exciting.
12. Choose MacrosUnload Sample Package.
The UnloadSamplePackage function runs, removes the #include statement from the built-in procedure 
window, and forces procedures to be recompiled. This cause Igor to unload the "Sample Package.ipf" 
procedure.
13. Click the Macros menu and notice that the "Hello From Sample Package" and "Unload Sample Package" 
items have been removed.
Most real packages do not create Unload menu items. Instead they provide an Unload Package button in a 
control panel or automatically unload when a control panel is closed. Or they might not support unloading.
A real package typically does not include "Package" in its name or in its menu items.
