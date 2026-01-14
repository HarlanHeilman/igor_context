# Entering Data

Chapter I-2 — Guided Tour of Igor Pro
I-13
Guided Tour 1 - General Tour
In this exercise, we will generate data in three ways (typing, loading, and synthesizing) and we will gener-
ate graph, table, and page layout windows. We will jazz up a graph and a page layout with a little drawing 
and some text annotation. At the end, we will explore some of the more advanced features of Igor Pro.
Creating an Igor64 Alias or Shortcut
The 64-bit Igor Pro application is typically located at:
/Applications/Igor Pro 9 Folder/Igor64.app (Macintosh)
C:\Program Files\WaveMetrics\Igor Pro 9 Folder\IgorBinaries_x64\Igor.exe (Windows)
The “.app” and “.exe” extensions may be hidden on your system.
1.
Make an alias (Macintosh) or shortcut (Windows) for your Igor64 application file and put the alias 
or shortcut on your desktop. Name it Igor64.
Launching Igor Pro
1.
Double-click your Igor64 alias or shortcut.
Igor starts up.
On Windows, you an also launch Igor64 using the Start menu.
2.
Choose MiscPreferences Off.
Turning preferences off ensures that the tour works the same for everyone.
Entering Data
1.
If a table window is showing, click it to bring it to the front.
When Igor starts up, it creates a new blank table unless this feature is turned off in the Miscellaneous 
Settings dialog. If the table is not showing, perform the following two steps:
2.
Choose the WindowsNew Table menu item.
The New Table dialog appears.
3.
Click the Do It button.
A new blank table is created.
4.
Type “0.1” (without the quotes) and then press Return or Enter on your keyboard.
This creates a wave named “wave0” with 0.1 for the first point. Entering a value in the first row (point 
0) of the first blank column automatically creates a new wave.

Chapter I-2 — Guided Tour of Igor Pro
I-14
5.
Type the following numbers, pressing Return or Enter after each one:
1.2
1.9
2.6
4.5
5.1
5.8
7.8
8.3
9.7
The table should look like this:
6.
Click in the first cell of the first blank column.
7.
Enter the following numbers in the same way:
-0.12
-0.08
1.3
1
0.54
0.47
0.44
0.2
0.24
0.13
8.
Choose DataRename.
9.
Click “wave0” in the list and then click the arrow icon.
10.
Replace “wave0” with “time”.
Notice that you can’t use the name “time” because it is the name of a built-in string function. We apol-
ogize for usurping such a common name.
11.
Change the name to “timeval”.
12.
Click “wave1” in the list, click the arrow icon, and replace “wave1” with “yval”.
13.
Click Do It.
The column headers in the table change to reflect the name changes.
