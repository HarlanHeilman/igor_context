# Checking Links

Chapter IV-10 — Advanced Topics
IV-258
After entering the URL, select the entire URL, including the angle brackets, and choose Make Help Link 
from the notebook menu. Once the file is compiled and opened as a help file, clicking the link will open the 
user’s Web or FTP browser and display the specified URL.
For any other kind of URL, such as sftp or mailto, use a notebook action that calls BrowseURL instead of a 
help link.
It is currently not possible make ordinary text into a Web or FTP link. The text must be an actual URL in the 
format shown above or you can insert a notebook action which brings up a web page using the BrowseURL 
operation on page V-54. See Notebook Action Special Characters on page III-14 for details.
Checking Links
You can tell Igor to check your help links as follows:
1.
Open your Igor help file and compile it as a help file if necessary.
2.
Activate your help window.
3.
Right-click in the body of the help file and choose Check Help Links. Igor will check your links from 
where you clicked to the end of the file and note any problems by writing diagnostics to the history area 
of the command window.
4.
When Igor finishes checking, if it found bad links, kill the help file and open it as a notebook.
5.
Use the diagnostics that Igor wrote in the history to find and fix any link errors.
6.
Save the notebook and kill it.
7.
Open the notebook as a help file. Igor will compile it.
8.
Repeat the check by going back to Step 1 until you have no bad links.
During this process, Igor searches for linked topics and subtopics in open and closed help files and opens any 
closed help file to which a link refers. If a link is not satisfied by an already open help file, Igor searches closed 
help files in:
•
The Igor Pro Folder and subfolders
•
The Igor Pro User Files folder and subfolders
•
Files and folders referenced by aliases or shortcuts in one of those folders
You can abort the check by pressing the User Abort Key Combinations.
The diagnostic that Igor writes to the history in case of a bad link is in the form:
Notebook $nb selection={(33,292), (33,334)} …
This is set up so that you can execute it to find the bad link. At this point, you have opened the help file as 
a notebook. Assuming that it is named Notebook0, execute
String/G nb = "Notebook0"
Now, you can execute the diagnostic commands to find the bad link and activate the notebook. Fix the bad 
link and then proceed to the next diagnostic. It is best to do this in reverse order, starting with the last diag-
nostic and cutting it from the history after fixing the problem.
If you press the Shift key while right-clicking a help window, you can choose Check Help Links in All Open 
Help Files. Then Igor checks all help links all help files open at that time. While checking a help file, Igor 
may open a previously unopened help file. Such newly opened help files are not checked. Only those help 
files open when you chose Check Help Links in All Open Help Files are checked. However, if you repeat 
the process, help files opened during the previous iteration are checked.
When fixing a bad link, check the following:
•
A link is the name of a topic or subtopic in a currently open help file. Check spelling.
