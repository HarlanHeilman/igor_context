# How Experiments Are Saved

Chapter II-3 — Experiments, Files and Folders
II-29
If you click Skip This Path, Igor does not create the symbolic path. Igor then asks if you want to skip waves 
loaded using the symbolic path that is being skipped:
If you click Yes, Igor skips all LoadWave commands using the symbolic path associated with the missing 
folder. This will cause errors later in the experiment loading process if the waves are needed for graphs, 
tables or other windows.
If you click No and the folder contains wave files referenced by the experiment, you will get Missing File 
dialogs later in the process giving you a chance to locate the wave files.
For example, if the experiment loads two waves using the Data2 path then the experiment’s recreation com-
mands would contain two lines like this:
LoadWave/C/P=Data2 "wave0.ibw"
LoadWave/C/P=Data2 "wave1.ibw"
If you elected to skip creating the Data2 path and clicked Yes when asked if you want to skip waves from 
that path, then Igor skips these LoadWave commands altogether.
If you elected to skip creating the Data2 path and clicked No when asked if you want to skip waves from 
that path, then each of these LoadWave commands presents the Missing File dialog.
If you were unable to find the Data2 folder then each of these LoadWave commands will present the 
Missing Wave File dialog.
If you are unable to find the wave file and if the wave is used in a graph or table, you will get more errors later 
in the experiment recreation process, when Igor tries to use the missing wave to recreate the graph or table.
How Experiments Are Saved
When you save an experiment for the first time, Igor just does a straight-forward save in which it creates a 
new file, writes to it, and closes it. However, when you resave a pre-existing experiment, which overwrites 
the previous version of the experiment file, Igor uses a "safe save" technique. This technique is designed to 
preserve your original file in the event of an error while writing the new version.
For purposes of illustration, we will assume that we are resaving an experiment file named "Experiment.pxp". 
The safe save proceeds as follows:
1.
Rename the original file as "Experiment.pxp.T0.noindex". If an error occurs during this step, the 
save operation is stopped and Igor displays an error message.
2.
Write the new version of the file as "Experiment.pxp".
3.
If step 2 succeeds, delete the original file ("Experiment.pxp.T0.noindex").
If step 2 fails, delete the new version of the file and rename the original version with the original 
name.
The ".noindex" suffix tells Apple's Spotlight program not to interfere with the save by opening the temporary 
file at an inopportune time.
The next three subsections are for use in troubleshooting file saving problems only. If you are not having a 
problem, you can skip them.
