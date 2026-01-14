# A Plain Text File Has Been Modified Externally and In Igor

Chapter II-4 — Windows
II-57
file is no longer valid. In this case Igor notices that the file has disappeared and gives you options 
for dealing with it.
The following sections explain how Igor deals with these issues in more detail.
A Plain Text File Has Been Modified Externally
Once per second Igor checks every procedure and plain text notebook window to see if its file has been 
modified externally. If so then it either automatically reloads the file into memory or notifies you about the 
external modification and allows you to reload the file at your leisure. The factory default behavior is to 
automatically reload externally modified files and to check for modified files only when Igor is the active 
application.
You can control Igor's behavior using the Miscellaneous Settings Dialog. Choose MiscMiscellaneous Set-
tings, click Text Editing in the lefthand pane, and click the External Editor tab.
If you select Ask Before Reloading, two things happen when the file is modified externally:
•
Igor displays a Reload button in the status area at the bottom of the document window:
The Reload button will be visible only if the window is visible.
•
Igor displays a small floating notification window:
Clicking the Reload button causes Igor to reload the file's text.
Clicking the Review button in the notification window displays a dialog in which you can review all the 
files that are currently modified externally:
Click Resolve Checked Items to reload the file into memory.
A Plain Text File Has Been Modified Externally and In Igor
When a file has been modified both in an external editor and by editing in an Igor window, we say it is "in 
conflict". Igor never automatically reloads a file that is in conflict.
When a file is in conflict, Igor displays a Resolve Conflict button in the status area in the Igor document 
window. Clicking that button brings up a dialog giving four choices to deal with the conflict:
