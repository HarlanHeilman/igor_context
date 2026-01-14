# Modes of Operation

Chapter III-14 — Controls and Control Panels
III-414
Overview
We use the term controls for a number of user-programmable objects that can be employed by Igor program-
mers to create a graphical user interface for Igor users. We call them controls even though some of the objects 
only display values. The term widgets is sometimes used by other application programs.
Here is a summary of the types of controls available.
The programmer can specify a procedure to be called when the user clicks on or types into a control. This 
is called the control’s action procedure. For example, the action procedure for a button may interrogate values 
in PopupMenu, Checkbox, and SetVariable controls and then perform some action.
Control panels are simple windows that contain these controls. These windows have no other purpose. You 
can also place controls in graph windows and in panel panes embedded into graphs. Controls are not 
available in any other window type such as tables, notebooks, or layouts. When used in graphs, controls are 
not considered part of the presentation and thus are not included when a graph is printed or exported.
Nonprogrammers will want to skim only the Modes of Operation and Using Controls sections, and skip the 
remainder of the chapter. Igor programmers should study the entire chapter.
Modes of Operation
With respect to controls, there are two modes of operation: one mode to use the control and another to 
modify it. To see this, choose Show Tools from the Graph or Panel menu. Two icons will appear in the top-
left corner window. When the top icon is selected, you are able to use the controls. When the next icon is 
selected, the draw tool palette appears below the second icon. To modify the control, select the arrow tool 
from the draw tool palette.
When the top icon is selected or when the icons are hidden, you are in the use or operate mode. You can 
momentarily switch to the modify or draw mode by pressing Command-Option (Macintosh) or Ctrl+Alt (Win-
dows). Use this to drag or resize a control as well as to double-click it. Double-clicking with the Command-
Option (Macintosh) or Ctrl+Alt (Windows) pressed brings up a dialog that you use to modify the control.
Control Type
Control Description
Button
Calls a procedure that the programmer has written.
Chart
Emulates a mechanical chart recorder. Charts can be used to monitor data acquisition 
processes or to examine a long data record. Programming a chart is quite involved.
CheckBox
Sets an off/on value for use by the programmer’s procedures.
CustomControl
Custom control type. Completely specified and modified by the programmer.
GroupBox
An organizational element. Groups controls with a box or line.
ListBox
Lists items for viewing or selecting.
PopupMenu
Used by the user to choose a value for use by the programmer’s procedures.
SetVariable
Sets and displays a numeric or string global variable. The user can set the variable by 
clicking or typing. For numeric variables, the control can include up/down buttons for 
incrementing/decrementing the value stored in the variable.
Slider
Duplicates the behavior of a mechanical slider. Selects either discrete or continuous values.
TabControl
Selects between groups of controls in complex panels.
TitleBox
An organizational element. Provides explanatory text or message.
ValDisplay
Presents a readout of a numeric expression which usually references a global variable. 
The readout can be in the form of numeric text or a thermometer bar or both.
