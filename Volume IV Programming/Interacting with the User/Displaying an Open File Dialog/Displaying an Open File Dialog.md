# Displaying an Open File Dialog

Chapter IV-6 — Interacting with the User
IV-148
Prompt s,"Enter a string", popup "red;green;blue"
DoPrompt "Enter Values",a,s,ca
if(V_Flag)
Abort "The user pressed Cancel"
endif
Print "a= ",a,"s= ",s,"ca=",ca
Prompt a,"Enter a again please"
Prompt s,"Type a string"
DoPrompt "Enter Values Again", a,s
if(V_Flag)
Abort "The user pressed Cancel"
endif
Print "Now a=",a," and s=",s
End
When this function is executed, it produces two simple input dialogs, one after the other after the user clicks 
Continue.
Help For Simple Input Dialogs
You can create, for each simple input dialog, custom help that appears when the user clicks the Help button. 
You do so by providing a custom help file with topics that correspond to the titles of your dialogs as spec-
ified in the DoPrompt commands.
If there is no exactly matching help topic or subtopic for a given dialog title, Igor munges the presumptive 
topic by replacing underscore characters with spaces and inserting spaces before capital letters in the inte-
rior of the topic. For example, if the dialog title is “ReallyCoolFunction”, and there is no matching help topic 
or subtopic, Igor looks for a help topic or subtopic named “Really Cool Function”.
See Creating Your Own Help File on page IV-255 for information on creating custom help files.
Displaying an Open File Dialog
You can display an Open File dialog to allow the user to choose a file to be used with a subsequent com-
mand. For example, the user can choose a file which you will then use in a LoadWave command. The Open 
File dialog is displayed using an Open/D/R command. Here is an example:
Function/S DoOpenFileDialog()
Variable refNum
String message = "Select a file"
String outputPath
String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
fileFilters += "All Files:.*;"
Open /D /R /F=fileFilters /M=message refNum
outputPath = S_fileName
return outputPath
// Will be empty if user canceled
End
Here the Open operation does not actually open a file but instead displays an Open File dialog. If the user 
chooses a file and clicks the Open button, the Open operation returns the full path to the file in the S_file-
Name output string variable. If the user cancels, Open sets S_fileName to "".
The /M flag is used to set the prompt message. As of OS X 10.11, Apple no longer shows the prompt message 
in the Open File dialog. It continues to work on Windows.
