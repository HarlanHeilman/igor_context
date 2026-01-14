# Missing or Modified Text Files Dialog

Chapter II-4 — Windows
II-59
Missing or Modified Text Files Dialog
A plain text file (procedure file or plain text notebook) may be missing because you deleted it, renamed it, 
or moved it, or it was deleted, renamed or moved by a program.
A plain text file may have been modified by another program if you edited it in an external editor, for exam-
ple.
If you try to do a save while a plain text file is missing or modified, Igor displays the Missing or Modified 
file dialog which asks if you want to cancel the save or continue it. Usually you should cancel the save and 
use the Files Were Modified Externally window, which appears in the top/right corner of the screen, to 
review and address the situation.
If you elect to continue the save, it is likely that an error will occur.
To prevent an unattended procedure from hanging, the check for missing or modified files is not done if 
the save is invoked from a procedure.
