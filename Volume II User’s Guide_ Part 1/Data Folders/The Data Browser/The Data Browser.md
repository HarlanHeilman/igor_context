# The Data Browser

Chapter II-8 — Data Folders
II-114
The recreated graph will have the same appearance, but use the data from the other data folder. The editing 
usually involves changing a command like:
SetDataFolder root:Run1:
to:
SetDataFolder root:Run2:
If the graph displays waves from more than one data folder, you may need to edit commands like:
Display rawData,::Run1:rawData
as well.
However, there is another way that doesn’t require you to edit recreation macros: use the ReplaceWave 
operation to replace waves in the graph with waves from the other folder.
•
Set the current data folder to the one containing the waves you want to view
•
Activate the desired graph
•
Execute in the command line:
ReplaceWave allinCDF
This replaces all the waves in the graph with identically named waves from the current data folder, if they 
exist. See the ReplaceWave for details. You can choose GraphReplace Wave to display a dialog in which 
you can generate ReplaceWave commands interactively.
Though we have only one wave per data folder, we can try it out:
•
Set the current data folder to Run1.
•
Select the graph showing data from Run2 only (CSTATIN.ASV).
•
Execute in the command line:
ReplaceWave allinCDF
The graph is updated to show the rawData wave from Run1.
For another Data Folder example, choose FileExample ExperimentsTutorialsData Folder Tutorial.
The Data Browser
The Data Browser lets you navigate through the data folder hierarchy, examine properties of waves and 
values of numeric and string variables, load data objects from other Igor experiments, and save a copy of 
data from the current experiment to an experiment file or folder on disk.
To open the browser choose Data Browser from the Data menu.
The user interface of the Data Browser is similar to that of the computer desktop. The basic Igor data objects 
(variables, strings, waves and data folders) are represented by icons and arranged in the main list based on 
their hierarchy in the current experiment. The browser also sports several buttons that provide you with 
additional functionality.
The main components of the Data Browser window are:
•
The main list which displays icons representing data folders, waves, and variables
•
The Display checkboxes which control the types of objects displayed in the main list
•
The buttons for manipulating the data hierarchy
•
The info pane which displays information about the selected item
•
The plot pane which displays a graphical representation of the selected wave
