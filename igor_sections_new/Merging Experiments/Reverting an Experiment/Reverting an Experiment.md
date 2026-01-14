# Reverting an Experiment

Chapter II-3 — Experiments, Files and Folders
II-20
that copies will diverge, creating confusion about which is the “real” data or object. One way to avoid this 
problem is to discard the merged experiment after it has served its purpose.
The second problem has to do with Igor’s use of names to reference all kinds of data, procedures and other 
objects. When you merge experiment B into experiment A, there is a possibility of name conflicts.
Igor prevents name conflicts for data (waves, numeric variables, string variables) by creating a new data 
folder to contain the data from experiment B. The new data folder is created inside the current data folder 
of the current experiment (experiment A in this case).
For other globally named objects, including graphs, tables, page layouts, control panels, notebooks, Gizmo 
plots, symbolic paths, page setups and pictures, Igor renames objects from experiment B if necessary to avoid 
a name conflict.
During the merge experiment operation, Igor looks for conflicts between target windows, between window 
recreation macros and between a target window and a recreation macro. If any such conflict is found, the 
window or window macro from experiment B is renamed.
Because page layouts reference graphs, tables, Gizmo plots, and pictures by name, renaming any of these 
objects may affect a page layout. The merge experiment operation handles this problem for page layouts 
that are open in experiment B. It does not handle the problem for page layout recreation macros in experi-
ment B that have no corresponding open window.
If there are name conflicts in procedures other than window recreation macros, Igor will flag an error when 
it compiles procedures after finishing the merge experiment operation. You will have to manually resolve 
the name conflict by removing or renaming conflicting procedures.
Procedure windows have titles but do not have standard Igor names. The merge experiment operation 
makes no attempt to retitle procedure windows that have the same title.
The contents of the main procedure window from experiment B are appended to the contents of the main 
procedure window for experiment A.
During a normal experiment open operation, Igor executes experiment initialization commands. This is not 
done during an experiment merge.
Each experiment contains a default font setting that affects graphs and page layouts. When you do an exper-
iment merge, the default font setting from experiment B is ignored, leaving the default font setting for 
experiment A intact. This may affect the appearance of graphs and layouts in experiment B.
The history from experiment B is not merged into experiment A. Instead, a message about the experiment 
merge process is added to the history area.
The system variables (K0…K19) from experiment B are ignored and not merged into experiment A.
Although the merge experiment operation handles the most common name conflict problems, there are a 
number problems that it can not handle. For example, a procedure, dependency formula or a control from 
experiment B that references data using a full path may not work as expected because the data from exper-
iment B is loaded into a new data folder during the merge. Another example is a procedure that references 
a window, symbolic path or picture that is renamed by the merge operation because of a name conflict. 
There are undoubtedly many other situations where name conflicts could cause unexpected behavior.
Reverting an Experiment
If you choose Revert Experiment from the File menu, Igor asks if you’re sure that you want to discard 
changes to the current experiment. If you answer Yes, Igor reloads the current experiment from disk, restor-
ing it to the state it was in when you last saved it.
