# Finding Text

Chapter III-13 — Procedure Windows
III-404
To adopt a file, open its associated window and choose FileAdopt Window. This item is available only if 
the active window is a notebook or procedure file that is stored separate from the current experiment and 
the current experiment has been saved to disk.
If the current experiment is stored in packed form then, when you adopt a file, Igor does a save-as to a tem-
porary file. When you subsequently save the experiment, the contents of the temporary file are stored in the 
packed experiment file.
If the current experiment is stored in unpacked form then, when you adopt a file, Igor does a save-as to the 
experiment’s home folder. When you subsequently save the experiment, Igor updates the experiment’s rec-
reation procedures to open the new file in the home folder instead of the original file. If you adopt a file in 
an unpacked experiment and then you do not save the experiment, the new file will still exist in the home 
folder but the experiment’s recreation procedures will still refer to the original file. Thus, you should nor-
mally save the experiment soon after adopting a file.
Adoption does not cause the original file to be deleted. You can delete it from the desktop if you want.
To “unadopt” a procedure file, choose Save Procedure File As from the File menu.
It is possible to do adopt multiple files at one time. For details see Adopt All on page II-25.
Auto-Compiling
If you modify a procedure window and then activate a non-procedure window other than a help window, 
Igor automatically compiles the procedures.
If you have a lot of procedures and compiling takes a long time, you may want to turn auto-compiling off. 
You can do this by deselecting the Auto-compile item in the Macros menu. This item appears only when 
the procedures need to be compiled (you have modified a procedure file or opened a new one). If you 
uncheck it item, Igor will not auto-compile and compilation will be done only when you click the Compile 
button or choose Compile from the Macros menu.
Debugging Procedures
Igor includes a symbolic debugger. This is described in The Debugger on page IV-212.
Finding Text
To find text in the active window, choose EditFind or press Command-F (Macintosh) or Ctrl+F (Windows). 
This displays the Find bar. See Finding Text in the Active Window on page II-52 for details.
To search multiple windows for text, choose EditFind in Multiple Windows. See Finding Text in Multi-
ple Windows on page II-53 for details.
On Macintosh, you can search for the next occurrence of a string by selecting the string, pressing Command-
E (Use Selection for Find in the Edit menu), and pressing Command-G (Find Same in the Edit menu).
On Windows, you can search for the next occurrence of a string by selecting the string and pressing Ctrl+H 
(Find Selection in the Edit menu).
After doing a find, you can search for the same text again by pressing Command-G (Macintosh) or Ctrl+G 
(Windows) (Find Same in the Edit menu). You can search for the same text but in the reverse direction by 
pressing Command-Shift-G (Macintosh) or Shift+Ctrl+G (Windows).
You can search back and forth through a procedure window by repeatedly pressing Command-G and 
Command-Shift-G (Macintosh) or Ctrl+G and Shift-Ctrl+G (Windows).
