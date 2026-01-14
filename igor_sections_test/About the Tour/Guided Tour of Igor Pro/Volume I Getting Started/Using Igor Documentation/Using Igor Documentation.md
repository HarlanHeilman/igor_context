# Using Igor Documentation

Chapter I-2 — Guided Tour of Igor Pro
I-27
3.
Choose the WindowsProcedure WindowsProcedure Window menu item.
The procedure window is always present but is usually hidden to keep it out of the way. The window 
now contains the recreation macro for Graph0. You may need to scroll up to see the start of the macro. 
Because of the way it is declared:
Window Graph0() : Graph
this macro will be available from the Graph Macros submenu of the Windows main menu.
4.
Click the procedure window’s close button.
This hides the procedure window. Most other windows display a dialog asking if you want to kill or 
hide the window, but the built-in procedure window and the help windows simply hide themselves.
Recreating the Graph
1.
Choose the WindowsGraph MacrosGraph0 menu item.
Igor executes the Graph0 macro which recreates a graph of the same name.
2.
Repeat step 1.
The Graph0 macro is executed again but this time Igor gave the new graph a slightly different name, 
Graph0_1, because a graph named Graph0 already existed.
3.
While pressing Option (Macintosh) or Alt (Windows), click the close button of Graph0_1.
The window is killed without presenting a dialog.
Using the Data Browser
The Data Browser lets you navigate through the data folder hierarchy and examine properties of waves and 
values of numeric and string variables.
1.
Choose the DataData Browser menu item.
The Data Browser appears.
2.
Make sure all of the checkboxes in the top-left corner of the Data Browser are checked.
3.
Click the timeval wave icon to select it.
Note that the wave is displayed in the plot pane at the bottom of the Data Browser and the wave’s 
properties are displayed just above in the info pane.
If you don’t see this, click the info icon (
) half-way down the left side fo the Data Browser win-
dow.
4.
Control-click (Macintosh) or right-click (Windows) on the timeval wave icon.
A contextual menu appears with a number of actions that you can perform on the selection.
5.
Press Escape to dismiss the contextual menu.
You can explore that and other Data Browser features later on your own.
6.
Click the Data Browser’s close box to close it.
Saving Your Work - Tour 1B
7.
Choose the FileSave Experiment As menu item.
8.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
9.
Change the name to “Tour 1B.pxp” and click Save.
If you want to take a break, you can quit from Igor now.
Using Igor Documentation
Now we will take a quick look at how to find information about Igor.

Chapter I-2 — Guided Tour of Igor Pro
I-28
In addition to guided tours such as this one, Igor includes tooltips, general usage information, and reference 
information. The main guided tours, as well as the general and reference information, are available in both 
the online help files and in the Igor Pro PDF manual.
1.
Choose MiscMiscellaneous Settings, click the Help icon on the left side, and verify that the 
Show Tooltips checkbox is checked.
If it is unchecked, check it..
2.
Click Save Settings to close the Miscellaneous Settings dialog.
3.
Choose DataLoad WavesLoad Waves.
Igor displays the Load Waves dialog. This dialog provides an interface to the LoadWave operation 
which is how you load data into Igor from text data files.
4.
On Macintosh only, move the cursor over the Load Columns Into Matrix checkbox.
A tooltip appears in a yellow textbox. You can get a tip for most dialog items and icons this way.
5.
Click the Cancel button to quit the dialog.
Now let's see how to get reference help for a particular operation.
6.
Choose HelpCommand Help.
The Igor Help Browser appears with the Command Help tab displayed.
The information displayed in this tab comes from the Igor Reference help file - one of many help files 
that Igor automatically opens at launch. Open help files are directly accessible through HelpHelp 
Windows but we will use the Igor Help Browser right now.
7.
If there is a Show All link above the left-hand list, click it.
8.
Click any item in the list and then type "L".
Igor displays help for the first list item whose name starting with "L". We want the LoadWave oper-
ation.
9.
Press the down-arrow key until LoadWave is selected in the list.
Igor displays help for the LoadWave operation in the help area on the right.
Another way to get reference help is to Control-click (Macintosh) or right-click (Windows) the name 
of an operation or function and choose the "Help For" menu item. This works in the command win-
dow and in procedure, notebook and help windows.
10.
In the Filter edit box just below the left-hand list, type “Matrix”.
The list now shows only operations, functions, and keywords whose names include “matrix”.
11.
Click Show All above the left-hand list.
The list shows all operations, functions, and keywords again.
12.
Click the Advanced Filtering control to reveal additional checkboxes and pop-up menus.
These controls provide other ways to filter what appears in the left-hand list.
While we're in the Igor Help Browser, let's see what the other tabs are for.
13.
Click each of the Help Browser tabs and note their contents.
You can explore these tabs in more detail later.
Next we will take a quick trip to the Igor Pro PDF manual. If you are doing this guided tour using the 
PDF manual, you may want to just read the following steps rather than do them to avoid losing your 
place.
