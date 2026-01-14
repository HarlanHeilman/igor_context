# Search and Replace in Multiple Windows

Chapter II-4 — Windows
II-55
The Find Text in Multiple Windows Dialog
You can perform a Find on multiple help, procedure and notebook windows at one time by choosing 
EditFind in Multiple Windows or by pressing Command-Shift-F (Macintosh) or Ctrl+Shift+F (Windows). 
This invokes the Find Text in Multiple Windows dialog:
Enter text to be found in the Find box. Use the checkboxes to select the types of windows to search. To 
narrow the list of files to search, you can enter a filter string in the Filter box at the bottom of the window 
list. The list then shows only list items whose names contain the filter string.
When you click the Find All button, Igor commences searching all the text in the listed windows. During 
the search, Igor displays a small progress dialog showing how far through the window list the search has 
gotten. You can stop the search by clicking the Cancel button.
For each window in which the text is found, an entry appears in the panel at the bottom of the dialog. A 
number in parentheses indicates how many instances of the search text were found in that window.
Each of these window entries can be opened using the disclosure control at the left end of the item. Then a 
snippet of text around the search string is shown, with the search string highlighted. The number at the left 
end of the found text snippet is the line number within the searched window.
Double-clicking a text snippet item takes you to the found text in the window containing the text.
Search and Replace in Multiple Windows
After a search is finished, you can use the found text items to replace all instances of the text that were found 
in editable windows. Enter the replacement text in the Replace edit box.
Clicking the Replace All button replaces all the found instances with the replacement text.
NOTE: Replace All in multiple windows cannot be undone. Use it with great care.
If you make a mistake, choose FileRevert Experiment, FileRevert Notebook, or FileProcedure and 
make sure you have reverted all affected windows. This is the only way to recover.
