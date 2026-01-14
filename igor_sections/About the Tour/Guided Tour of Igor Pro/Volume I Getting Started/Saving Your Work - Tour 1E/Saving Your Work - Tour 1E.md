# Saving Your Work - Tour 1E

Chapter I-2 — Guided Tour of Igor Pro
I-44
30.
Set both values back to 1 and click the Update button.
You can edit a value by typing in the SetVariable control and enter it by pressing Return or Enter.
Creating a Dependency
A dependency is a rule that relates the value of an Igor wave or variable to the values of other waves or 
variables. By setting up a dependency you can cause Igor to automatically update a wave when another 
wave or variable changes.
1.
Click the command window to bring it to the front.
2.
Execute the following commands in the command line:
spiralY := x*sin(ymult*x)
spiralX := x*cos(xmult*x)
This is exactly what you entered before except here := is used in place of =. The := operator creates a 
dependency formula. In the first expression, the wave spiralY is made dependent on the variable 
ymult. If a new value is stored in ymult then the values in spiralY are automatically recalculated from 
the expression.
3.
Click Graph0 to bring it to the front.
4.
Adjust the ymult and xmult controls but do not click the Update button.
When you change the value of ymult or xmult using the SetVariable control, Igor automatically exe-
cutes the dependency formula. The spiralY or spiralX waves are recalculated and both graphs are 
updated.
5.
On the command line, execute this:
ymult := 3*xmult
The ymult SetVariable control as well as the graphs are updated.
6.
Adjust the xmult value.
Again notice that ymult as well as the graphs are updated.
7.
Choose the MiscObject Status menu item.
The Object Status dialog appears. You can use this dialog to examine dependencies.
8.
Click the the Current Object pop-up and choose spiralY from the Data Objects list.
The list on the right indicates that spiralY depends on the variable ymult.
9.
Double-click the ymult entry in the right-hand list.
ymult becomes the current object. The list on the right now indicates that ymult depends on xmult.
10.
Click the Delete Formula button.
Now ymult no longer depends on xmult.
11.
Click Done.
12.
Adjust the xmult setting.
The ymult value is no longer automatically recalculated but the spiralY and spiralX waves still are.
13.
Click the Update button.
14.
Adjust the xmult and ymult settings.
The spiralY and spiralX waves are no longer automatically recalculated. This is because the Button-
Proc function called by the Update button does a normal assignment using = rather than := and that 
action removes the dependency formulae.
In real work, you should avoid using dependencies because they are hard to keep track of and debug. If a 
button can do the job then use it rather than the dependency.
Saving Your Work - Tour 1E
1.
Choose the FileSave Experiment As menu item.
