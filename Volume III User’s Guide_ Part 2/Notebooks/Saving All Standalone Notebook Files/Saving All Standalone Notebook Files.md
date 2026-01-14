# Saving All Standalone Notebook Files

Chapter III-1 — Notebooks
III-3
All new notebook files should use UTF-8 text encoding. When you create a new notebook using Win-
dowsNewNotebook, Igor automatically uses UTF-8. Also, the NewNotebook operation defaults to 
UTF-8.
Igor must convert from the old text encodings to Unicode when opening old files. It is not always possible 
to get this conversion right. You may get incorrect characters or receive errors when opening files contain-
ing non-ASCII text.
For a discussion of these issues, see Text Encodings on page III-459, Plain Text File Text Encodings on page 
III-466, and Formatted Text Notebook File Text Encodings on page III-472.
Creating a New Notebook File
To create a new notebook, choose WindowsNewNotebook. This displays the New Notebook dialog.
The New Notebook dialog creates a new notebook window. The notebook file is not created until you save 
the notebook window or save the experiment.
Normally you should store a notebook as part of the Igor experiment in which you use it. This happens 
automatically when you save the current experiment unless you do an explicit Save Notebook As before 
saving the experiment. Save Notebook As stores a notebook separate from the experiment. This is appro-
priate if you plan to use the notebook in multiple experiments.
Note:
There is a risk in sharing notebook files among experiments. If you copy the experiment to 
another computer and forget to also copy the shared files, the experiment will not work on the 
other computer. See References to Files and Folders on page II-24 for more explanation.
If you do create a shared notebook file then you are responsible for copying the shared file when you copy 
an experiment that relies on it.
Opening an Existing File as a Notebook
You can create a notebook window by opening an existing file. This might be a notebook that you created 
in another Igor experiment or a plain text file created in another program. To do this, choose FileOpen 
FileNotebook.
Opening a File for Momentary Use
You might want to open a text file momentarily to examine or edit it. For example, you might read a Read Me 
file or edit a data file before importing data. In this case, you would open the file as a notebook, do your reading 
or editing and then kill the notebook. Thus the file would not remain connected to the current experiment.
Sharing a Notebook File Among Experiments
On the other hand, you might want to share a notebook among multiple experiments. For example, you 
might have one notebook in which you keep a running log of all of your observations. In this case, you could 
save the experiment with the notebook open. Igor would then save a reference to the shared notebook file 
in the experiment file. When you later open the experiment, Igor would reopen the notebook file.
As noted above, there is a risk in sharing notebook files among experiments. You might want to “adopt” 
the opened notebook. See References to Files and Folders on page II-24 for more explanation.
Saving All Standalone Notebook Files
When a notebook window is active, you can save all modified standalone notebook files at once by choosing 
FileSave All Standalone Notebook Files. This saves only standalone notebook files. It does not save 
packed notebook files, or notebook windows that were just created and never saved to disk; these are saved 
when you save the experiment.
