# Inspecting Waves

Chapter IV-8 — Debugging
IV-224
Expressions Inspector
Selecting "Expressions" from the inspector popup shows a list of Expressions and their values:
Replace the "(dbl-click to enter expression)" invitation by clicking it, typing a numeric or string expression, 
and pressing Return.
Adding an expression adds a blank row at the end of the list that can be double-clicked to enter another 
expression. You can edit any of the expressions by double-clicking and typing.
The expression can be removed by selecting it and pressing Delete or Backspace.
The result of the expression is recomputed when stepping through procedures. The expressions are evalu-
ated in the context of the currently selected procedure.
Global expressions are evaluated in the context of the current data folder, though you can specify the data 
folder explicitly as in the example below.
If an expression is invalid the result is shown as “?” and the expression is changed to red:
The expressions are discarded when a new Igor experiment is opened or when Igor quits.
Inspecting Waves
You can "inspect" (view) the contents of a wave in either a table or a graph. They aren't full-featured tables 
or graphs, as there are no supporting dialogs for them. You can change their properties using contextual 
menus.
Select the Wave to be inspected by one of three methods:
