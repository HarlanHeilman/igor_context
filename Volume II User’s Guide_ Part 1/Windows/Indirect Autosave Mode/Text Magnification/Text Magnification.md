# Text Magnification

Chapter II-4 — Windows
II-53
On Macintosh, you can search for the next occurrence of a string by selecting the string and choosing 
EditUse Selection For Find or pressing Command-E to enter the selected text as the find string and Command-
G to find it.
On Windows, you can search for the next occurrence of a string by selecting the string and choosing 
EditFind Selection or pressing Ctrl+H to enter the selected text as the find string and find it.
Find and Replace
You can find and replace text by choosing EditReplace Text or by pressing Command-R (Macintosh) or 
Ctrl+R (Windows). This displays the Find and Replace bar.
Here is another method for finding and replacing text:
1.
Move the selection to the top of the active window.
2.
Use EditFind to find the first instance of the target string.
3.
Manually change the first instance, then copy the new text to the Clipboard.
4.
Press Command-G (Macintosh) or Ctrl+G (Windows) to find the next occurrence.
5.
Press Command-V (Macintosh) or Ctrl+V (Windows) to paste.
6.
Repeat steps 4 and 5 until done.
Finding Text in Multiple Windows
You can find text in multiple windows by choosing EditFind Text in Multiple Windows. This displays the 
Find Text in Multiple Windows window which allows you to search all help windows, all procedure windows, 
and all notebooks.
You can also use the Igor Help Browser to search in multiple files, including files that are not open in your 
current experiment. See The Igor Help Browser on page II-2 for details.
Text Magnification
You can magnify the text in any window to make it bigger or smaller to suit your taste.
In help windows, procedure windows, plain text notebooks, and formatted text notebooks, you can use the 
magnifying glass icon in the bottom-left corner of the window. You can also use the Magnification submenu 
in the contextual menu for the window. To display the contextual menu, Control-click (Macintosh) or right-
click (Windows) in the body of the window.
You can also set the magnification for the command line, history area, and the debugger. These areas do not 
display the magnifying glass icon so you must use the contextual menu.
You may notice some anomalies when you use text magnification. For example, in a formatted text note-
book, text may wrap at a different point in the paragraph and may change in relation to tab stops. This 
happens because fonts are not available in fractional sizes and because the actual width of text does not 
scale linearly with font size.
You can set the default magnification for each type of text area by choosing a magnification from the Mag-
nification popup menu and then choosing Set As Default from the same popup menu. Any text areas whose 
magnification is set to Default will use the newly specified default magnification. For example, if you want 
text in all help files to appear larger, open any help file, choose a larger magnification, 125% for example, 
and then choose Set As Default For Help Files. All help files whose current magnification is set to Default 
will be updated to use the new default.
The default magnification for the command line and history area controls the magnification that will be 
used the next time you launch Igor Pro.
The magnification setting is saved in formatted notebooks and help files only. If you change the magnifica-
tion setting for one of these files and then save and close the file, the magnification setting will be restored 
when you reopen the file. For all other types of text areas, including procedure windows and plain text
