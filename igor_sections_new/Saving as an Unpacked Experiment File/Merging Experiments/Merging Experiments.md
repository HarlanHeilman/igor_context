# Merging Experiments

Chapter II-3 — Experiments, Files and Folders
II-19
Note that there is one file for each wave. These are Igor Binary data files and store the wave data in a compact 
format. For the benefit of programmers, the Igor binary wave file format is documented in Igor Technical Note 
#003.
The “procedure” file holds the text in the experiment’s built-in procedure window. In this example, the 
experiment has an additional procedure window called Proc0 and a notebook.
The “variables” file stores the experiment’s numeric and string variables in a binary format.
The “miscellaneous” file stores pictures, page setup records, XOP settings, and other data.
The advantages of the unpacked experiment format are:
•
Igor can save the experiment faster because it does not need to update files for waves, procedures 
or notebooks that have not changed.
•
You can share files stored in one experiment with another experiment. However, sharing files can 
cause problems when you move an experiment to another disk. See References to Files and Folders 
on page II-24 for an explanation.
The disadvantages of the unpacked experiment format are:
•
It takes more disk space, especially for experiments that have a lot of small waves.
•
You need to keep the experiment file and folder together when you move the experiment to another disk.
Opening Experiments
You can open an experiment stored on disk by choosing Open Experiment from the File menu. You can first 
save your current experiment if it has been modified. Then Igor presents the Open File dialog.
When you select an experiment file and click the Open button, Igor loads the experiment, including all waves, 
variables, graphs, tables, page layouts, notebooks, procedures and other objects that constitute the experiment.
See How Experiments Are Loaded on page II-26 for details on how experiments are loaded.
Getting Information About the Current Experiment
You can see summary information about the current experiment by choosing FileExperiment Informa-
tion. This displays the Experiment Information dialog.
The dialog shows when the current was last saved, whether it was modified since the last save, and other 
general information.
The dialog also shows whether the experiment uses long wave, variable, data folder, target window or sym-
bolic path names. Experiments that use long names require Igor Pro 8.00 or later. See Long Object Names 
on page III-502 for details.
Merging Experiments
Normally Igor closes the currently opened experiment before opening a new one. But it is possible to merge 
the contents of an experiment file into the current experiment. This is useful, for example, if you want to 
create a page layout that contains graphs from two or more experiments. To do this, press Option (Macin-
tosh) or Alt (Windows) and choose Merge Experiment from the File menu.
Note:
Merging experiments is an advanced feature that has some inherent problems and should be used 
judiciously. If you are just learning to use Igor Pro, you should avoid merging experiments until 
you have become proficient. You may want to skim the rest of this section or skip it entirely. It 
assumes a high level of familiarity with Igor.
The first problem is that the merge operation creates a copy of data and other objects (e.g., graphs, proce-
dure files, notebooks) stored in a packed experiment file. Whenever you create a copy there is a possibility
