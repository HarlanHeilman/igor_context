# Dependencies and the Object Status Dialog

Chapter IV-9 — Dependencies
IV-230
Dependency Formulas
Igor Pro supports “dependent objects”. A dependent object can be a wave, a global numeric variable or a 
global string variable that has been linked to an expression. The expression to which an object is linked is 
called the object’s “dependency formula” or “formula” for short.
The value of a dependent object is updated whenever any other global object involved in the formula is 
modified, even if its value stays the same. We say that the dependent object depends on these other global 
objects through the formula.
You might expect that an assignment such as:
Variable var0 = 1
Make wave0
wave0 = sin(var0*x/16)
meant that wave0 would be updated whenever var0 changed. It doesn’t. Values are computed for wave0 
only once, and the relationship between wave0 and var0 is forgotten.
However, if the equal sign in the above assignment is replaced by a colon followed by an equal sign:
wave0 := sin(var0*x/16)
then Igor does create just such a dependency. Now whenever var0 changes, Igor reevaluates the assignment 
statement and updates wave0. In this example, wave0 is a dependent object. It depends on var0, and 
“sin(var0*x/16)” is wave0’s dependency formula.
You can also establish a dependency using the SetFormula operation, like this:
SetFormula wave0, "sin(var0*x/16)"
Wave1 depends on var0 because var0 is a changeable variable. Wave1 also depends on the function x which 
returns the X scaling of the destination wave (wave0). When the X scaling of wave0 changes, the values that 
the x function returns change, so this dependency assignment is reevaluated. The remaining terms (sin and 
16) are not changeable, so wave0 does not depend on them.
From the command line, you can use either a dependency assignment statement or SetFormula to establish 
a dependency. In a user-defined function, you must use SetFormula.
Like other assignment statements, the data folder context for the right-hand side is that of the destination 
object. Therefore, in the following example, wave2 and var1 must be in the data folder named foo, var2 
must be in root, and var3 must be in root:bar.
root:foo:wave0 := wave2*var1 + ::var2 + root:bar:var3
Data Folders are described in Chapter II-8, Data Folders.
A dependency assignment is often used in conjunction with SetVariable controls and ValDisplay controls.
Here’s a simple example. Execute these commands on the command line:
Variable/G var0 = 1
Make/O wave0:=sin(var0*x/16)
Display /W=(4,53,399,261) wave0
ControlBar 23
SetVariable setvar0,size={60,15},value=var0
Click the SetVariable control’s up and down arrows to adjust var0 and observe that wave0 is automatically 
updated.
Dependencies and the Object Status Dialog
You can use the Object Status dialog, which you can access via the the Misc menu, to check dependencies. 
After executing the commands in the preceding section, the dialog looks like this:
