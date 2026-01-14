# Numeric and String Variable Dependencies

Chapter IV-9 — Dependencies
IV-231
The Status area indicates any dependency status:
•
“No dependency” means that the current object does not depend on anything.
•
“Dependency is OK” means that the dependency formula successfully updated the current object.
•
“Update failed” means that the dependency formula used to compute the current object’s value 
failed.
An update may fail because there is a syntax error in the formula or one of the objects referenced in the 
formula does not exist or has been renamed. If the formula includes a call to a user-defined function then 
the update will fail if the function does not exist or if procedures are not compiled.
If an update fails, then the objects that depend on that update are broken. See Broken Dependent Objects 
on page IV-233 for details.
You can create a new dependency formula with the New Formula button, which appears only if the current 
object is not the target of a dependency formula.
You can delete a dependency formula using the Delete Formula button.
You can change an existing dependency formula by typing in the Dependency Formula window, and click-
ing the Change Formula button.
For further details on the Object Status dialog, click the Help button in the dialog.
Numeric and String Variable Dependencies
Dependencies can also be created for global user-defined numeric and string variables. You can not create 
a dependency that uses a local variable on either side of the dependency assignment statement.
Here is a user-defined function that creates a dependency. The global variable recalculateThis is made 
to depend on the global variable dependsOnThis:
Function TestRecalculation()
Variable/G recalculateThis
Variable/G dependsOnThis = 1
// Create dependency on global variable
SetFormula recalculateThis, "dependsOnThis"
Print recalculateThis
// Prints original value
dependsOnThis = 2
// Changes something recalculateThis
