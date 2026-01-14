# Modifying Action Special Characters

Chapter III-1 — Notebooks
III-16
If you specify both a Proc Picture and a regular picture, the regular picture is displayed. If you specify no 
regular picture and your Proc Picture name is incorrect or the procedure file that supplies the Proc Picture 
is not open or not compiled, "???" is displayed in place of the picture.
In order for a picture to display correctly on both Macintosh and Windows, it must be in a cross-platform 
format such as PNG. You can convert a picture to PNG by clicking the Convert To PNG button. This affects 
the regular picture only.
Pictures and Proc Picture in actions are drawn transparently. The background color shows through white 
parts of the picture unless the picture explicitly erases the background.
The action can display one of six things as determined by the Show popup menu:
•
The title
•
The picture
•
The picture below the title
•
The picture above the title
•
The picture to the left of the title
•
The picture to the right of the title
If there is no picture and you choose one of the picture modes, just the title is displayed.
You can add padding to any external side of the action content (title or picture). The Internal Padding value 
sets the space between the picture and the title when both are displayed. All padding values are in points.
If you enable the background color, the rectangle enclosing the action content is painted with the specified color.
You can enter any number of commands to be executed in the Commands area. When you click the action, 
Igor sends each line in the Commands area to the Operation Queue, as if you called the Execute/P operation, 
and the commands are executed.
In addition to regular commands, you can enter special operation queue commands like INSERTINCLUDE, 
COMPILEPROCEDURES, and LOADFILE. These are explained under Operation Queue on page IV-278.
For sophisticated applications, the commands you enter can call functions that you define in a companion 
“helper procedure file” (see Notebook Action Helper Procedure Files on page III-17).
If the Quiet checkbox is selected, commands are not sent to the history area after execution.
If the Ignore Errors checkbox is selected then command execution errors are not reported via error dialogs.
The Generate LoadFile Command button displays an Open File dialog and then generates an Execute/P 
command to load the file into Igor. This is useful for generating a command to load a demo experiment, for 
example. This button inserts the newly-generated command at the selection point in the command area so, 
if you want the command to replace any pre-existing commands, delete any text in the command area 
before clicking the button. If the selected file is inside the Igor Pro Folder or any subdirectory, the generated 
path will be relative to the Igor Pro Folder. Otherwise it will be absolute.
Creating a Hyperlink Action
You can use a notebook action to create a hyperlink that displays a web page by calling the BrowseURL 
operation from the action's command.
Modifying Action Special Characters
You can modify an existing action by Control-clicking (Macintosh) or right-clicking (Windows) on it and 
choosing Modify Action from the pop-up menu, or by selecting the action special character, and nothing 
else, and then choosing NotebookSpecialModify Action.
If you have opened a notebook as a help file and want to modify an action, you must close the help file 
(press Option or Alt and click the close button) and reopen it as a notebook (choose FileOpen
