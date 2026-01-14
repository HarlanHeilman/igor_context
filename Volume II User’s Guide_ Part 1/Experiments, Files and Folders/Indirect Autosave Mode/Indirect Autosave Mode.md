# Indirect Autosave Mode

Chapter II-3 — Experiments, Files and Folders
II-39
Simplicity.
Weaknesses
Saving the entire experiment can take a while for very large experiments.
Autosave may save a file at the wrong time, for example just after you made a mistake.
If you do not elect to save the entire experiment, many things are not autosaved, including the built-
in procedure window, packed procedure files and notebooks, graphs, layouts and other windows, 
data folders and waves - see What Autosave Saves for details.
Can interfere with sharing of files by multiple users or by multiple instances of Igor launched by a 
single user.
Changes That Tee Up Autosaving the Entire Experiment
If you check the Autosave Entire Experiment checkbox and make a substantive change then Igor autosaves 
the entire experiment on the next autosave run.
Changes that are considered substantive include creating, killing or modifying waves and data folders, 
changing the content of a graph, table, layout, panel or Gizmo plot, and editing a procedure file or note-
book.
Autosaving the entire experiment can be time-consuming. To prevent autosaving the entire experiment too 
often, some relatively minor changes do not tee up an experiment autosave. Among these are moving and 
resizing windows, changes to the history area that don’t cause other objects to substantively change, and 
changes to global variables.
If the FileRun Autosave Now menu item is disabled, this indicates that no changes considered substan-
tive were made since the last experiment save or last autosave.
Forcing Autosave to Run
You can force Igor to run its autosave routine when it is turned off or before it normally would run by choos-
ing FileRun Autosave Now.
If the FileRun Autosave Now menu item is disabled, this means that there are no autosaveable files at 
present. This typically occurs because no autosaveable files were modified since the last time the autosave 
routine ran.
The Run Autosave Now menu command runs Igor's autosave procedure regardless of the state of the Run 
Autosave checkbox in the Autosave pane of the Miscellaneous Settings dialog. It does respect the other set-
tings in that pane.
Saving Standalone Files Without Autosave
You can save all modified standalone procedure files or all modified standalone notebooks at once whether 
autosave is on or off. See Saving All Standalone Files on page II-26 for details.
Indirect Autosave Mode
The indirect autosave mode is more complicated than the direct mode. We will illustrate how indirect 
autosave works assuming the following settings in the Autosave pane of the Miscellaneous Settings dialog:
