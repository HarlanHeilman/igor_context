# Updates During Macro Execution

Chapter IV-4 — Macros
IV-123
controls how much the lines are slowed down. Typically, you would execute something like “Slow 10” 
from the command line and then “Slow 0” when you are finished debugging.
You can also use the Slow operation from within a macro. You must explicitly invoke “Slow 0” to revert 
to normal behavior. It does not automatically revert at the end of the macro from which it was invoked.
We never use this feature. Instead, we generally use print statements for debugging or we use the Igor sym-
bolic debugger, described in Chapter IV-8, Debugging.
Accessing Variables Used by Igor Operations
A number of Igor’s operations return results via variables. For example, the WaveStats operation creates a 
number of variables with names such as V_avg, V_sigma, etc.
When you invoke these operations from the command line, they create global variables in the current data 
folder.
When you invoke them from a user-defined function, they create local variables.
When you invoke them from a macro, they create local variables unless a global variable already exists. If 
both a global variable and a local variable exist, Igor uses the local variable.
In addition to creating variables, a few operations, such as CurveFit and FuncFit, check for the existence of 
specific variables to provide optional behavior. The operations look first for a local variable with a specific 
name. If the local variable is not found, they then look for a global variable.
Updates During Macro Execution
An update is an action that Igor performs. It consists of:
•
Reexecuting assignments for dependent objects whose antecedents have changed (see Chapter IV-9, 
Dependencies);
•
Redrawing graphs and tables which display waves that have changed;
•
Redrawing page layouts containing graphs, tables, or annotations that have changed;
•
Redrawing windows that have been uncovered.
When no procedure is executing, Igor continually checks whether an update is needed and does an update 
if necessary.
During macro execution, Igor checks if an update is needed after executing each line. You can suspend 
checking using the PauseUpdate operation. This is useful when you want an update to occur when a macro 
finishes but not during the course of the macro’s execution.
PauseUpdate has effect only inside a macro. Here is how it is used.
Window Graph0() : Graph
PauseUpdate; Silent 1
Display /W=(5,42,400,250) w0,w1,w2
ModifyGraph gFont="Helvetica"
ModifyGraph rgb(w0)=(0,0,0),rgb(w1)=(0,65535,0),rgb(w2)=(0,0,0)
<more modifies here...>
End
Without the PauseUpdate, Igor would do an update after each modify operation. This would take a long time.
At the end of the macro, Igor automatically reverts the state of update-checking to what it was when this 
macro was invoked. You can use the ResumeUpdate operation if you want to resume updates before the 
macro ends or you can call DoUpdate to force an update to occur at a particular point in the program flow. 
Such explicit updating is rarely needed.
