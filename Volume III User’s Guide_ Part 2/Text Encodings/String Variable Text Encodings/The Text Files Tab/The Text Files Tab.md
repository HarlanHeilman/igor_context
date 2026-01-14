# The Text Files Tab

Chapter III-16 — Text Encodings
III-489
To prevent confusion, it is usually best to examine these two classes of strings separately. Display the 
strings that do not need conversion only and examine them. When you are satisfied that they are correct, 
display the strings that need conversion only and proceed.
All string variables are stored as part of the current experiment so there are no "shared" string variables. 
Consequently, the Home and Shared checkboxes that appear in the Waves and Text Files tabs are not 
present in the Strings tab.
Inspect the text in the Contents column. If it appears correct, click the Convert Strings button to convert the 
strings to UTF-8. If it appears incorrect, choose a different text encoding from the pop-up menu and inspect 
the Contents column again.
Below the checkboxes, Igor displays an explanation of what strings need conversion.
When you click Convert Strings, Igor converts text strings from the selected text encoding to UTF-8. It skips 
strings that do not need conversion, if they are displayed in the table.
If no items in the list are selected, clicking the Convert Strings button converts all of the strings in the list 
that need to be converted. If items are selected in the list, the button changes to Convert Selected Strings 
and clicking it converts the selected strings only and only if they need to be converted. Strings that do not 
need to be converted are skipped in either case.
The Text Files Tab
The Text Files tab lists all of the text files (plain text notebooks and procedure files) in the experiment that 
are marked as using a non-UTF-8 text encoding, whether they contain non-ASCII text or not. It also lists 
"History" if the history area of the command window is marked as using a non-UTF-8 text encoding.
Global procedure files and #included procedure files are not considered part of the current experiment and 
are not displayed in the list of text files. The programmer responsible for these files should convert them to 
UTF-8.
The list in the Text Files tab comprises five columns:
Window Title: The title of the notebook or procedure window, or "History" for the history area of the 
command window.
Window Name: The window name for notebooks. The history area of the command window and procedure 
windows have no names.
Window Type: The type of window: procedure, notebook, or history.
This column also indicates if the text file is a "home" text file, meaning that it is part of the current experi-
ment, or a "shared" text file, meaning that it is stored outside of the current experiment. See Home Versus 
Shared Text Files on page II-56 for background information.
File Name: The name of the file associated with the window if it has been saved to a standalone file.
Text Encoding: The text encoding currently associated with the window.
Two checkboxes under the list of text files control whether home text files and shared text files are displayed 
in the list. Converting shared text files increases the possiblity that the conversion may adversely affect 
other experiment but this is usually a concern only if you need Igor6 compatibility.
If no items in the list are selected, clicking the Convert Text Files button converts all of the files in the list, 
except for files open for read-only which are skipped. If items are selected in the list, the button changes to 
Convert Selected Text Files and clicking it converts the selected files only, except for files open for read-only 
which are skipped.
Unlike read-only files, write-protected files are converted, because write-protect is intended to protect 
against inadvertent manual editing only.
