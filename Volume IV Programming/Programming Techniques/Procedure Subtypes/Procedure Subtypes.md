# Procedure Subtypes

Chapter IV-7 — Programming Techniques
IV-204
When a macro ends, the state of preferences reverts to what it was when that macro started. If you change 
the preference setting within a function, the preferences state does not revert when that function ends. You 
must turn preferences on, save the old preferences state, execute Igor operations, and then restore the pref-
erences state. For example:
Function DisplayWithPreferences(w)
Wave w
Variable oldPrefState
Preferences 1
// Turn preferences on
oldPrefState = V_Flag
// Save the old state
Display w
// Create graph using preferences
Preferences oldPrefState
// Restore old prefs state
End
Experiment Initialization Procedures
When Igor loads an experiment, it checks to see if there are any commands in the procedure window before 
the first macro, function or menu declaration. If there are such commands Igor executes them. This provides 
a way for you to initialize things. These initialization commands can invoke procedures that are declared 
later in the procedure window.
Also see BeforeFileOpenHook on page IV-287 and IgorStartOrNewHook on page IV-292 for other initial-
ization methods.
Procedure Subtypes
A procedure subtype identifies the purpose for which a particular procedure is intended and the appropri-
ate menu from which it can be chosen. For example, the Graph subtype puts a procedure in the Graph 
Macros submenu of the Windows menu.
Window Graph0() : Graph
PauseUpdate; Silent 1
// building window...
Display/W=(5,42,400,250) wave0,wave1,wave2
<more commands>
End
When Igor automatically creates a procedure, for example when you close and save a graph, it uses the appro-
priate subtype. When you create a curve fitting function using the Curve Fitting dialog, the dialog automati-
cally uses the FitFunc subtype. You usually don’t need to use subtypes for procedures that you write.
This table shows the available subtypes and how they are used.
Subtype
Effect
Available for
Graph
Displayed in Graph Macros submenu.
Macros
GraphStyle
Displayed in Graph Macros submenu and in Style pop-up 
menu in New Graph dialog.
Macros
GraphMarquee
Displayed in graph marquee. This keyword is no longer 
recommended. See Marquee Menu as Input Device on page 
IV-163 for details.
Macros and 
functions
CursorStyle
Displayed in Style Function submenu of cursor pop-up menu 
in graph info pane.
Functions
DrawUserShape
Marks a function as suitable for drawing a user-defined 
drawing object. See DrawUserShape.
Functions
GridStyle
Displayed in Grid-Style submenu of mover pop-up menu in 
drawing tool palette.
Functions
