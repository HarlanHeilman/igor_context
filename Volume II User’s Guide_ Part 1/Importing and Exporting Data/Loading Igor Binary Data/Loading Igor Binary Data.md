# Loading Igor Binary Data

Chapter II-9 — Importing and Exporting Data
II-154
Loading Text Waves from Igor Text Files
Loading text waves from Igor Text files is similar to loading them from delimited text files except that in an 
Igor Text file you declare a wave’s name and type. Also, text strings are quoted in Igor Text files as they are 
in Igor’s command line. Here is an example of Igor Text that defines a text wave:
IGOR
WAVES/T textWave0, textWave1
BEGIN
"This"
"Hello"
"is"
"out"
"a test"
"there"
END
All of the waves in a block of an Igor Text file must have the same number of points and data type. Thus, you 
can not mix numeric and text waves in the same block. You can have any number of blocks in one Igor Text file.
As this example illustrates, you must use double quotes around each string in a block of text data. If you 
want to embed a quote, tab, carriage return or linefeed within a single text value, use the escape sequences 
\", \t, \r or \n. Use \\ to embed a backslash. For less common escape sequences, see Escape Sequences in 
Strings on page IV-14.
Loading Igor Binary Data
This section discusses loading Igor Binary data into memory.
Igor stores Igor Binary data in two ways: one wave per Igor binary wave file in unpacked experiments and 
multiple waves within a packed experiment file.
When you open an experiment, Igor automatically loads the Igor Binary data to recreate the experiment’s 
waves. The main reason to explicitly load an Igor binary wave file is if you want to access the same data from 
multiple experiments. The easiest way to load data from another experiment is to use the Data Browser (see 
The Data Browser on page II-114).
Warning: You can get into trouble if two Igor experiments load data from the same Igor binary wave file. 
See Sharing Versus Copying Igor Binary Wave Files on page II-156 for details.
There are a number of ways to load Igor Binary data into the current experiment in memory. Here is a sum-
mary. For most users, the first and second methods — which are simple and easy to use — are sufficient.
Method
Loads
Action
Purpose
Open 
Experiment
Packed and 
unpacked files
Restores the experiment to the state 
in which it was last saved.
To restore experiment.
Data Browser
Packed and 
unpacked files
Copies data from one experiment to 
another.
See The Browse Expt Button on 
page II-117 for details.
To collect data from different 
sources for comparison.
Desktop Drag 
and Drop
Unpacked files 
only
Copies data from one experiment 
to another or shares between 
experiments.
To collect data from different 
sources for comparison.
Load Waves 
Dialog
Unpacked files 
only
Copies data from one experiment 
to another or shares between 
experiments.
To create a LoadWave command 
that can be used in an Igor 
procedure.
LoadWave 
Operation
Unpacked files 
only
Copies data from one experiment 
to another or shares between 
experiments.
See LoadWave on page V-508 for 
details.
To automatically load data using 
an Igor Procedure.
