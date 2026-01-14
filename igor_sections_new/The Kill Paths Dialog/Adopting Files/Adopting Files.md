# Adopting Files

Chapter II-3 — Experiments, Files and Folders
II-24
Killing a path does nothing to the folder referenced by the symbolic path. It just deletes the symbolic path 
name from Igor’s list of symbolic paths.
A symbolic path is in use — and Igor won’t let you kill it — if the experiment contains a wave, notebook 
window or procedure window linked to a file in the folder the symbolic path points to.
References to Files and Folders
An experiment can reference files that are not stored with the experiment. This happens when you load an 
Igor binary data file which is stored with a different experiment or is not stored with any experiment. It also 
happens when you open a notebook or procedure file that is not stored with the current experiment. We 
say the current experiment is sharing the wave, notebook or procedure file.
For example, imagine that you open an existing text file as a notebook and then save the experiment. The 
data for this notebook is in the text file somewhere on your hard disk. It is not stored in the experiment. 
What is stored in the experiment is a reference to that file. Specifically, the experiment file contains a 
command that will reopen the notebook file when you next reopen the experiment.
Note:
When an experiment refers to a file that is not stored as part of the experiment, there is a potential 
problem. If you copy the experiment to an external drive to take it to another computer, for 
example, the experiment file on the external drive will contain a reference to a file on your hard 
disk. If you open the experiment on the other computer, Igor will ask you to find the referenced 
file. If you have forgotten to also copy the referenced file to the other computer, Igor will not be 
able to completely recreate the experiment.
For this reason, we recommend that you use references only when necessary and that you be aware of this 
potential problem.
If you transfer files between platforms file references can be particularly troublesome. See Experiments and 
Paths on page III-449.
Avoiding Shared Igor Binary Wave Files
When you load a wave from an Igor binary wave file stored in another experiment, you need to decide if 
you want to share the wave with the other experiment or copy it to the new experiment. Sharing creates a 
reference from the current experiment to the wave’s file and this reference can cause the problem noted 
above. Therefore, you should avoid sharing unless you want to access the same data from multiple exper-
iments and you are willing to risk the problem noted above.
If you load the wave via the Load Igor Binary dialog, Igor will ask you if you want to share or copy. You 
can use the Miscellaneous Settings dialog to always share or always copy instead of asking you.
If you load the wave via the LoadWave operation, from the command line or from an Igor procedure, Igor 
will not ask what you want to do. You should normally use LoadWave’s /H flag, tells Igor to “copy the wave 
to home” and avoids sharing.
If you use the Data Browser to transfer waves from one experiment to another, Igor always copies the waves.
For further discussion, see Home Versus Shared Waves on page II-87 and Home Versus Shared Text Files 
on page II-56.
Adopting Files
Adoption is a way for you to copy a shared wave, notebook, or procedure file into the current experiment and 
break the connection to its original file. Adoption makes an experiment less fragile by being more self-con-
tained. If you transfer it to another computer or send it to a colleague, all of the files needed to recreate the 
experiment will be stored in the experiment itself.
