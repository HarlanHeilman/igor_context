# Wave Reference Counting

Chapter IV-7 — Programming Techniques
IV-205
Memory Considerations
Running out of memory is usually not an issue unless you load gigabytes of data into memory at one time. 
If this is true in your case, make sure to run IGOR64 (the 64-bit version of Igor) rather than IGOR32 (the 32-
bit version). IGOR32 is provided only for users who rely on 32-bit XOPs that have not yet been ported to 64 
bits and is available on Windows only.
On most systems, IGOR32 can access 4 GB of virtual memory. The limits for IGOR64 are much higher and 
depend on your operating system.
If memory becomes fragmented, you may get unexpected out-of-memory errors. This is much more likely 
in IGOR32 than IGOR64.
See Memory Management on page III-512 for further information.
Wave Reference Counting
Igor uses reference counting to determine when a wave is no longer referenced anywhere and memory can be 
safely deallocated.
Table
Displayed in Table Macros submenu.
Macros
TableStyle
Displayed in Table Macros submenu and in Style pop-up 
menu in New Table dialog.
Macros
Layout
Displayed in Layout Macros submenu.
Macros
LayoutStyle
Displayed in Layout Macros submenu and in Style pop-up 
menu in New Layout dialog.
Macros
LayoutMarquee
Displayed in layout marquee. This keyword is no longer 
recommended. See Marquee Menu as Input Device on page 
IV-163 for details.
Macros and 
functions
ListBoxControl
Displayed in Procedure pop-up menu in ListBox Control 
dialog.
Macros and 
functions
Panel
Displayed in Panel Macros submenu.
Macros
GizmoPlot
Displayed in Other Macros submenu.
Macros
CameraWindow
Displayed in Other Macros submenu.
Macros
FitFunc
Displayed in Function pop-up menu in Curve Fitting dialog.
Functions
ButtonControl
Displayed in Procedure pop-up menu in Button Control dialog.
Macros and 
functions
CheckBoxControl
Displayed in Procedure pop-up menu in Checkbox Control 
dialog.
Macros and 
functions
PopupMenuControl
Displayed in Procedure pop-up menu in PopupMenu 
Control dialog.
Macros and 
functions
SetVariableControl
Displayed in Procedure pop-up menu in SetVariable Control 
dialog.
Macros and 
functions
SliderControl
Displayed in Procedure pop-up menu in Slider Control 
dialog.
Macros and 
functions
TabControl
Displayed in Procedure pop-up menu in Tab Control dialog.
Macros and 
functions
CDFFunc
Displayed in the Kolmogorov-Smirnov Test dialog. See 
StatsKSTest for details.
Functions
Subtype
Effect
Available for
