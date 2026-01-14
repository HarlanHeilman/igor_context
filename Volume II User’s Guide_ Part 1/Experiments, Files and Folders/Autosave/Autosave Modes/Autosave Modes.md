# Autosave Modes

Chapter II-3 — Experiments, Files and Folders
II-38
Autosave Modes
You control the mode of operation of autosave using the Autosave pane of the Miscellaneous Settings 
dialog.
Autosave supports three modes. Each has its strengths and weaknesses.
•
Off
Autosave is off when the Run Autosave checkbox is unchecked.
In this mode, Igor's autosave routine does not automatically run.
Strengths
Easy to understand.
Takes no time.
You are in complete control of when files are saved.
Weaknesses
You are in complete control of when files are saved.
You are responsible for saving when you have made important changes.
•
Indirect Mode
Saves the current experiment (if it is packed, not if it is unpacked) and/or standalone procedure and 
standalone notebook files to .autosave files alongside the original files. For example, "Experi-
ment.pxp" is autosaved to "Experiment.pxp.autosave" and "Proc0.ipf" is autosaved to 
"Proc0.ipf.autosave".
Saving the current experiment is the same as choosing FileSave Experiment Copy.
Saving a standalone procedure file is the same as choosing FileProcedure Copy.
Saving a standalone notebook is the same as choosing FileNotebook Copy.
You can choose whether to autosave the current experiment, standalone procedure files, and stand-
alone notebooks.
Indirect autosave of unpacked experiments is not supported.
Strengths
Does not risk overwriting your original files at the wrong time, for example just after you made a 
mistake.
Weaknesses
Saving the entire experiment can take a while for very large experiments.
If you do not elect to save the entire experiment, many things are not autosaved, including the built-
in procedure window, packed procedure files and notebooks, graphs, layouts and other windows, 
data folders and waves - see What Autosave Saves for details.
Can interfere with sharing of files by multiple users or by multiple instances of Igor launched by a 
single user.
Does not work with unpacked experiments.
The .autosave files represent more clutter relative to direct mode.
Recovering after a crash is more complicated compared to direct mode. Igor will ask if you want to 
use the .autosave file or the original file.
•
Direct Mode
Saves the current experiment and/or standalone procedure and standalone notebook files directly.
Saving the current experiment is the same as choosing FileSave Experiment.
Saving a standalone procedure file is the same as choosing FileProcedure.
Saving a standalone notebook is the same as choosing FileNotebook.
You can choose whether to autosave the current experiment, standalone procedure files, and stand-
alone notebooks.
Strengths
