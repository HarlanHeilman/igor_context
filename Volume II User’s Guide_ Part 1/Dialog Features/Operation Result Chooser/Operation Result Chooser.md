# Operation Result Chooser

Chapter II-11 — Dialog Features
II-229
To filter waves by name, type a name in the Filter edit box. Only waves whose name match the filter string 
are displayed. The filtering algorithm supports the following features:
Click the question mark icon at the bottom right corner of the browser to display a tooltip containing infor-
mation about the current filter. This tip shows you the filtering criteria currently in place and may help you 
to figure out why waves you expect to be able to select are not displayed in the browser.
Operation Result Chooser
In most Igor dialogs that perform numeric operations (Analysis menu: Integrate, Smooth, FFT, etc.) there is 
a group of controls allowing you to choose what to do with the result. Here is what the Result Chooser looks 
like in the Integrate dialog:
The Output Wave menu offers choices of a wave to receive the result of the operation:
The Where menu offers choices for the location of a new wave created when you choose Auto or Make New 
Wave. Usually you will want to choose Current Data Folder.
?
Matches any single character.
*
Matches zero or more of any characters. For example, "w*3" matches wave3, wave30 and wave300.
[...]
Matches a single character if it is included in the set of characters specified in square brackets. For 
example, [A-Z] matches any character from A to Z, case-insensitive. [0-9] matches any single digit.
Auto
Igor will create a new wave to receive the results. The source wave is not changed. 
The new wave will have a name derived from the source wave by adding a suffix 
that depends on the operation. choosing Auto makes the Where menu available.
Overwrite Source
The source wave (the wave that contains the input data) will be overwritten with 
the results of the operation. This will destroy the original data. The Where menu 
will not be available.
Make New Wave
This is like the Auto choice, but an edit box is presented that you use to type a 
name of your own choosing. Igor will make a new wave with this name to receive 
the results of the operation. This selection makes the Where menu available.
Select Existing Wave
A Wave Browser will be presented allowing you to choose any existing wave to 
be overwritten with the results. This choice preserves the contents of the source 
wave, but destroys the contents of the wave chosen to receive the results.
Current Data Folder
The new wave is created in the current data folder. If you don’t know about data 
folders, this is probably the best choice.
Source Wave Data Folder
The new wave is created in the same data folder as the source wave. It is 
quite likely that the source wave will be in the current data folder, in which 
case this choice is the same as choosing Current Data Folder.
Select Data Folder
This choice presents a Wave Browser in which you can choose a data folder 
where the new wave will be created.
