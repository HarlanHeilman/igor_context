# Using Data Folders Example

Chapter II-8 — Data Folders
II-112
See Chapter III-14, Controls and Control Panels, for details about controls.
Data Folders and Traces
You cannot tell by looking at a trace in a graph which data folder it resides in.
The easiest way to find out what data folder a trace’s wave resides in is to use the trace info help. Choose 
GraphShow Trace Info Tags and then hover the mouse over the trace to get trace info.
Another method is to use the Modify Trace Appearance dialog. Double-click the trace to display the dialog. 
The Traces list shows the full data folder path for each trace.
Finally, you can create and examine the graph window recreation macro. See Saving a Window as a 
Recreation Macro on page II-47 for details.
Using Data Folders
You can use data folders for many purposes. Here are two common uses of data folders.
Hiding Waves, Strings, and Variables
Sophisticated Igor procedures may need a large number of global variables, strings and waves that aren’t 
intended to be directly accessed by the user. The programmer who creates these procedures should keep all such 
items within data folders they create with unique names designed not to conflict with other data folder names.
Users of these procedures should leave the current data folder set to the data folder where their raw data 
and final results are kept, so that the procedure’s globals and waves won’t clutter up the dialog lists.
Programmers creating procedures should read Managing Package Data on page IV-249.
Separating Similar Data
One situation that arises during repeated testing is needing to keep the data from each test run separate 
from the others. Often the data from each run is very similar to the other runs, and may even have the same 
name. Without data folders you would need to choose new names after the first run.
By making one data folder for each test run, you can put all of the related data for one run into each folder. 
The data can use identical names, because other identically named data is in different data folders.
Using data folders also keeps the data from various runs from being accidently combined, since only the data in 
the current data folder shows up in the various dialogs or can be used in a command without a data folder name.
The WaveMetrics-supplied “Multipeak Fitting” example experiment’s procedures work this way: they 
create data folders to hold separate peak curve fit runs and global state information.
Using Data Folders Example
This example will use data folders to:
•
Load data from two test runs into separate data folders
•
Create graphs showing each test run by itself
•
Create a graph comparing the two test runs
First we’ll use the Data Browser to create a data folder for each test run.
Open the Data Browser, and set the current data folder to root by right-clicking the root icon and choosing 
Set as Current Data Folder.
Click the root data folder, and click the New Data Folder button. Enter “Run1” for the new data folder’s 
name and click OK.

Chapter II-8 — Data Folders
II-113
Click New Data Folder again. Enter “Run2” for the new data folder’s name and click OK.
The Data Browser window should look like this:
Now let’s load sample data into each data folder, starting with Run1.
Set the current data folder to Run1, then choose DataLoad WavesLoad Delimited. Select the CSTA-
TIN.ASH file from the Sample Data subfolder of the Learning Aids folder, and click Open. In the resulting 
Loading Delimited Text dialog, name the loaded wave “rawData” and click Load. We will pretend this data 
is the result of Run 1. Type “Display rawData” on the command line to graph the data.
Set the current data folder to Run2, and repeat the wave loading steps, selecting the CSTATIN.ASV file 
instead. In the resulting Loading Delimited Text dialog, name the loaded wave “rawData”. We will pretend 
this data is the result of Run 2. Repeat the “Display rawData” command to make a graph of this data.
Notice that we used the same name for the loaded data. No conflict exists because the other rawData wave 
is in another data folder.
In the Data Browser, set the current data folder to root.
In the Data Browser, uncheck the Variables and Strings checkboxes in the Display section. Open the Run1 
and Run2 icons by clicking the disclosure icons next to them. At this point, the Data Browser should look 
something like this:
You can easily make a graph displaying both rawData waves to compare them better. Choose Windows-
New Graph to display the New Graph dialog. Use the dialog wave browser controls (see Dialog Wave 
Browser on page II-228) to select both root:Run1:rawData and root:Run2:rawData. Click Do It.
You can change the current data folder to anything you want and the graphs will continue to display the 
same data. Graphs remember which data folder the waves belong to, and so do graph recreation macros. 
This is often what you want, but not always.
Suppose you have many test runs in your experiment, each safely tucked away in its own data folder, and 
you want to “visit” each test run by looking at the data using a single graph which displays data from the 
test run’s data folder only. When you visit another test run, you want the graph to display data from that 
other data folder only.
Additionally, suppose you want the graph characteristics to be the same (the same axis labels, annotations, 
line styles and colors, etc.). You could:
•
Create a graph for the first test run
•
Kill the window, and save the graph window macro.
•
Edit the recreation macro to reference data in another data folder.
•
Run the edited recreation macro.
