# Adopt All

Chapter II-3 — Experiments, Files and Folders
II-25
Adopting Waves
To adopt a wave file, select the wave in the Data Browser, right-click, and choose Adopt Wave. The Adopt 
Wave item is enabled only if the wave is shared. You can select multiple waves and adopt them in one step.
You can also adopt waves using FileAdopt All. See Adopt All below.
When you adopt a wave, Igor disconnects it from its original standalone file. The original file remains intact, 
but it is no longer referenced by the current experiment. The adoption is not final until you save the experi-
ment.
If the current experiment is stored in packed form then, when you adopt a wave, it is saved in the packed 
experiment file. For an unpacked experiment, it is saved in the disk folder corresponding the waves data 
folder in the experiment folder.
Adopting Notebook and Procedure Files
To adopt a notebook or procedure file, choose Adopt Notebook or Adopt Procedure from the File menu. 
This item will be available only if the active window is a notebook or procedure file that is stored separate 
from the current experiment and the current experiment has been saved to disk.
If the current experiment is stored in packed form then, when you adopt a file, Igor does a save-as to a tem-
porary file. When you subsequently save the experiment, the contents of the temporary file are stored in the 
packed experiment file. Thus, the adoption is not finalized until you save the experiment.
If the current experiment is stored in unpacked form then, when you adopt a file, Igor does a save-as to the 
experiment’s home folder. When you subsequently save the experiment, Igor updates the experiment’s rec-
reation procedures to open the new file in the home folder instead of the original file. Note that if you adopt 
a file in an unpacked experiment and then you do not save the experiment, the new file will still exist in the 
home folder but the experiment’s recreation procedures will still refer to the original file. Thus, you should 
save the experiment after adopting a file.
To “unadopt” a procedure or notebook file, choose Save Procedure File As or Save Notebook As from the 
File menu.
Adopt All
You can adopt all referenced notebooks, procedure files and waves by pressing Shift and choosing FileAdopt 
All. This is useful when you want to create a self-contained packed experiment to send to someone else.
After clicking Adopt, choose FileSave Experiment As to save the packed experiment.
