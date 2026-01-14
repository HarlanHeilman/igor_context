# Notebook Action Special Characters

Chapter III-1 — Notebooks
III-14
Saving Pictures
You can save a picture in a formatted text notebook as a standalone picture file. Select one picture and one 
picture only. Then choose FileSave Graphics. You can also save a picture using the Notebook savePicture 
operation.
Special Character Names
Each special character has a name. For most types, the name is automatically assigned by Igor when the 
special character is created. However for action special characters you specify the name through the Spe-
cialNew Action dialog. When you click a special character, you will see the name in the notebook status 
area. Special character names must be unique within a particular notebook.
The special character name is used only for specialized applications and usually you can ignore it. You can 
use the name with the Notebook findSpecialCharacter operation to select special characters. You can get a 
list of special character names from the SpecialCharacterList function (see page V-895) and get information 
using the SpecialCharacterInfo function (see page V-893).
When you copy a graph, table, layout, or Gizmo plot and paste it into a notebook, an Igor-object picture is 
created (see Using Igor-Object Pictures on page III-18). The Igor-object picture, like any notebook picture, 
is a special character and thus has a special character name, which, whenever possible, is the same as the 
source window name. However, this may not always possible such as when, for example, you paste Graph0 
twice into a notebook, the first special character will be named Graph0 and the second Graph0_1.
The Special Submenu
Using the Special submenu of the Notebook menu you can:
•
Frame or scale pictures
•
Insert special characters
•
Control updating of special characters
•
Convert a picture to cross-platform PNG format
•
Specify an action character that executes commands
Scaling Pictures
You can scale a picture by choosing NotebookSpecialScale or by using the Notebook command line 
operation. There is currently no way to scale a picture using the mouse.
Updating Special Characters
The window title, page number and total number of pages are dynamic characters—Igor automatically 
updates them when you print a notebook. These are useful for headers and footers. All other kinds of 
special characters are not dynamic but Igor makes it easy for you to update them if you need to, using the 
Update Selection Now or Update All Now items in the Special menu.
To prevent inadvertent updating, Igor disables these items until you enable updating, using the Enable 
Updating item in the Special menu. This enables updating for the active notebook.
If you are using a notebook as a form for generating reports, you will probably want to enable updating. How-
ever, if you are using it as a log of what you have done, you will want to leave updating in the disabled state.
Notebook Action Special Characters
An action is a special character that runs commands when clicked. Use actions to create interactive note-
books, which can be used for demonstrations or tutorials. Help files are formatted notebook files so actions 
can also be used in help files.
You create actions in a formatted text notebook. You can invoke actions from formatted text notebooks or 
from help files.

Chapter III-1 — Notebooks
III-15
For a demonstration of notebook actions, see the Notebook Actions Demo experiment.
To create an action use the NotebookAction operation (see page V-711) or choose Note-
bookSpecialNew Action to invoke the Notebook Action dialog:
Each action has a name that is unique within the notebook.
The title is the text that appears in the notebook. The text formatting of the notebook governs the default 
text formatting of the title.
If the Link Style checkbox is selected, the title is displayed like an HTML link — blue and underlined. This 
style overrides the color and underline formatting applied to the action through the Notebook menu.
The help text is a tip that appears when the cursor is over an action, if tips are enabled in the Help section of 
the Miscellaneous Settings dialog.
An action can have an associated picture that is displayed instead of or in addition to the title. There are two 
ways to specify a picture. You can paste one into the dialog using the Paste button or you can reference a 
Proc Picture stored in a procedure file. The latter source may be useful for advanced programmers (see Proc 
Pictures on page IV-56 for details).
For most purposes it is better to use a picture rather than a Proc Picture. One exception is if you have to use 
the same picture many times in the notebook, in which case you can save disk space and memory by using 
a Proc Picture.
If you designate a Proc Picture using a module name (e.g., MyProcPictures#MyPicture), then the Proc 
Picture must be declared static.
