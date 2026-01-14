# NotebookAction

Notebook (Writing Text)
V-711
Notebook
(Writing Text) 
Writing notebook text parameters
This section of Notebook relates to inserting text at the current selection in the notebook.
NotebookAction 
NotebookAction [/W=winName] keyword = value [, keyword = value …]
The NotebookAction operation creates or modifies an “action” in a notebook. A notebook action is an object 
that executes commands when clicked.
See Chapter III-1, Notebooks, for general information about notebooks.
NotebookAction returns an error if the notebook is open for read-only. See Notebook Read/Write 
Properties on page III-10 for further information.
Parameters
The parameters are in keyword =value format. Parameters are automatically limited to legal values before 
being applied to the notebook.
text=textStr
Inserts the text at the current selection.
Before the text is inserted, Igor converts escape sequences in textStr as described in 
Escape Sequences in Strings on page IV-14.
Then, it checks for illegal characters. The only character code that is illegal is zero 
(ASCII NUL character). If it finds an illegal character, Igor generates an error and does 
not insert the text.
setData=dataStr
Inserts the data at the current selection.
dataStr is either a regular string expression or the result returned by Notebook 
getData.
zData=dataStr
This keyword is used by Igor during the recreation of a notebook subwindow in a 
control panel. dataStr is encoded binary data created by Igor when the recreation 
macro was generated. It represents the contents of the notebook subwindow in a 
format private to Igor.
zDataEnd=1
This keyword is used by Igor during the recreation of a notebook subwindow in a 
control panel. It marks the end of encoded binary data created by Igor when the 
recreation macro was generated.
bgRGB=(r, g, b)
Specifies the action background color. r, g, and b specify the amount of red, green, and 
blue as integers from 0 to 65535.
commands=str
Specifies the command string to be executed when clicking the action. For multiline 
commands, add a carriage return (\r) between lines.
enableBGRGB=enable
Uses the background color specified by bgRGB (enable=1). Background color is 
ignored for enable=0.
frame=f
helpText=helpTextStr
Specifies the frame enclosing the action.
f=0:
No frame.
f=1:
Single frame (default).
f=2:
Double frame.
f=3:
Triple frame.
f=4:
Shadow frame.

NotebookAction
V-712
Flags
Examples
String nb = WinName(0, 16, 1)
// Top visible notebook
NotebookAction name=Action0, title="Beep", commands="Beep"// Create action
NotebookAction name=Action0, enableBGRGB=1, padding={4,4,4,4,4}
Specifies the help string for the action. The text is limited to 255 bytes. On Macintosh, 
help appears when the cursor is over the action after choosing HelpShow Igor Tips. 
On Windows, help appears in the status line when the cursor is over the action.
ignoreErrors=ignore
Controls whether an error dialog will appear (ignore=0) or not (ignore is nonzero) if an 
error occurs while executing the action commands.
linkStyle=linkStyle
Controls the action title text style. If linkStyle=1, the style is the same as a help link (blue 
underlined). If linkStyle=0, the style properties are the same as the preceding text.
name=name
Specifies the name of the new or modified notebook action. This is a standard Igor 
name. See Standard Object Names on page III-501 for details.
padding={leftPadding, rightPadding, topPadding, bottomPadding, internalPadding}
Sets the padding in points. internalPadding sets the padding between the title and the 
picture when both elements are present.
picture=name
Specifies a picture for the action icon. name is the name of a picture in the picture 
gallery (see Pictures on page III-509).
If name is null ($""), it clears the picture parameter.
procPICTName=name
Specifies a Proc Picture for the action icon (see Proc Pictures on page IV-56). name is 
the name of a Proc Picture or null ($"") to clear it. This will be a name like 
ProcGlobal#myPictName or MyModuleName#myPictName. If you use a module 
name, the Proc Picture must be declared static.
If you specify both picture and procPICTName, picture will be used.
quiet=quiet
Displays action commands in the history area (quiet=0), otherwise (quiet=1) no 
commands will be recorded.
scaling={h, v}
Scales the picture in percent horizontally, h, and vertically, v.
showMode=mode
title=titleStr
Sets the action title to titleStr, which is limited to 255 bytes.
/W= winName
Specifies the notebook window of interest.
winName is either kwTopWin for the top notebook window, the name of a notebook 
window or a host-child specification (an hcSpec) such as Panel0#nb0. See 
Subwindow Syntax on page III-92 for details on host-child specifications.
If /W is omitted, NotebookAction acts on the top notebook window.
Determines if the title or picture are displayed.
Without a picture specification, the action will use title mode regardless of what 
you specify.
mode=1:
Title only.
mode=2:
Picture only.
mode=3:
Picture below title.
mode=4:
Picture above title.
mode=5:
Picture to left of title.
mode=6:
Picture to right of title.
