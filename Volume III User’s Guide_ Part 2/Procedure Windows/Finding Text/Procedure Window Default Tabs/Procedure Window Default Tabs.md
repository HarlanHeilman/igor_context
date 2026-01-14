# Procedure Window Default Tabs

Chapter III-13 — Procedure Windows
III-405
Replacing Text
To replace text in the active window, press Command-R (Macintosh) or Ctrl+R (Windows). This displays the 
Find bar in replace mode. See Find and Replace on page II-53 for details.
The Search Selected Text Only option is handy for limiting the replacement to a particular procedure.
While replacing text is undoable, the potential for unintended and wide-ranging consequences is such that 
we recommend saving the file before doing a mass replace so you can revert-to-saved if necessary.
Another method for searching and replacing consists of repeating Command-F or Ctrl-F (Find) followed by 
Command-V or Ctrl-V (Paste). This has the virtue of allowing you to inspect each occurrence of the target 
text before replacing it.
Printing Procedure Text
To print the active procedure window, first deselect all text and then choose FilePrint Procedure 
Window.
To print part of the active procedure window, select the text you want to print and choose FilePrint Pro-
cedure Selection.
Indentation
We use indentation to indicate the structure of a procedure. This is described in Indentation Conventions 
on page IV-26.
To make it easy to use the indentation conventions, Igor maintains indentation when you press Return or 
Enter in a procedure window. It automatically inserts enough tabs in the new line to have the same inden-
tation as the previous line.
To indent more, as when going into the body of a loop, press Return or Enter and then Tab. To indent less, 
as when leaving the body of a loop, press Return or Enter and then Delete. When you don’t want to change 
the level of indentation, just press Return.
Included in the Edit menu for Procedure windows, is the Adjust Indentation item, which adjusts indenta-
tion of all selected lines of text to match Igor standards. The Edit menu also contains Indent Left and Indent 
Right commands that add or remove indentation for all selected lines.
Procedure Window Document Settings
The Document Settings dialog controls settings that affect the procedure window as a whole. You can 
summon it via the Procedure menu.
Igor does not store document settings for plain text files. When you open a procedure file, these settings are 
determined by preferences. You can capture preferences by choosing ProcedureCapture Procedure 
Prefs.
Procedure Window Default Tabs
The default tab width setting controls the location of tabs stops in procedure windows. You set this using 
the Document Settings dialog in the Procedure menu or using a DefaultTab pragma. In a procedure 
window the default tab width setting controls the location of all tab stops which affect indentation and 
alignment of comments.
Igor does not store document settings for procedure files, so your preferred default tab width settings apply 
to all procedure files subsequently opened unless they include a DefaultTab pragma.
