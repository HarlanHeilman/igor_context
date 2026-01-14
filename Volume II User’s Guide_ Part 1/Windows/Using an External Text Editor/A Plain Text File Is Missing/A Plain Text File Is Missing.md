# A Plain Text File Is Missing

Chapter II-4 — Windows
II-58
•
Reload External Changes
Loads the contents of the file into memory, discarding changes made in Igor.
•
Adopt Document
Severs the tie between the document and the file, keeping the Igor changes and discarding the 
changes to the file. To learn more about adopting a file, see Adopting Notebook and Procedure 
Files on page II-25.
•
Close the Window
Closes the procedure or notebook window in Igor, discarding changes made in Igor.
•
Save Igor Changes
Writes changes made in Igor to the file. This resolves the conflict in Igor and creates a conflict in the 
external editor. Different external editors have different approaches to such conflicts.
Files that are in conflict also cause the notification window to appear. Clicking the Review button in the 
notification window displays a dialog which gives you the same options for resolving the conflict.
Editing a File with External Modifications
If a file has been modifed externally and not re-loaded in Igor, typing in the Igor window creates a conflict 
even if there wasn't one previously. This may be undesirable, so when Igor detects this situation, it displays 
a dialog, similar to the Resolve Conflict dialog, asking you what should be done. The choices are:
•
Allow Typing
This choice tells Igor that you want to be allowed to modify the document in Igor. You are putting off 
resolving the conflict for later. You will have to decide at some point to resolve the conflict in one of the 
ways described above.
•
Reload External Changes
The external modifications will be loaded into the Igor window. Modifications in Igor's copy are discarded.
•
Adopt Document
Severs the tie between the document and the file. To learn more about adopting a file, see Adopting Note-
book and Procedure Files.
You also have the option of clicking the Cancel button. In that case, the situation is not resolved, and any 
further attempt to type in the window will cause the dialog to be displayed again.
A Plain Text File Is Missing
If the file associated with an Igor plain text document window is moved, renamed or deleted, Igor will note 
that the file is missing. In this case, Igor displays a File Missing button in the status area in the Igor docu-
ment window. Clicking that button displays a File Missing dialog giving four choices to deal with the con-
flict:
•
Adopt Document
Severs the tie between the document and the file. To learn more about adopting a file, see Adopting 
Notebook and Procedure Files.
•
Close the Window
Closes the procedure or notebook window in Igor.
•
Find Missing File
Displays an Open File dialog allowing you to locate the moved or renamed file.
•
Save As
Displays a Save As dialog allowing you to save the document to a new file.
