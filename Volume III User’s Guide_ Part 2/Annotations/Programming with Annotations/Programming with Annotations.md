# Programming with Annotations

Chapter III-2 — Annotations
III-52
Each annotation has 10 text info variables, numbered 0 through 9. You can embed an escape sequence in an 
annotation’s text to store information about the insertion point in a particular variable. Later, you can 
embed an escape sequence to recall part or all of that information. In the Label Axis and Add Annotation 
dialogs, there are items in the Font, Font Size and Special pop-up menus to do this.
See Text Info Variable Escape Codes on page III-55 for list of escape sequences.
Text Info Variable Example
To get a feel for this, let’s look at a simple example. We want to create a textbox that shows the formula for 
the chemical compound ethanol: CH3CH2OH
To create a textbox showing this formula in 24 point type, we need to enter this, which consists of regular text 
plus escape codes (shown in red), in the Text tab of the Add Annotations dialog:
\Z24\[0CH\B3\MCH\B2\MOH
You can enter the escape codes by simply typing them or by making selections from the pop-up menus in the 
Insert section of the dialog. In this example, the font size escape code, \Z24, was generated using the Font Size 
pop-up menu and the rest of the escape codes were generated using the Special pop-up menu.
Here is what the escape codes mean:
One way to enter this is to enter the regular text first and then add the escape codes. Here is what the annota-
tion preview would show at each step of this process:
Programming with Annotations
You can create, modify and delete annotations with the TextBox, Tag, Legend, and ColorScale operations. 
The AnnotationInfo function returns information about one existing annotation. The AnnotationList 
returns a list of the names of existing annotations.
\Z24
Set font size to 24 points.
\[0
Capture the current state as text info variable 0.
(Text info variable 0 stores the “normal” state).
\B
Subscript.
\M
Return to normal state (as stored in text info variable 0).
\B
Subscript.
\M
Return to normal state (as stored in text info variable 0).
CH3CH2OH
CH3CH2OH
\Z24CH3CH2OH
CH3CH2OH (but in 24 point type)
\Z24\[0CH3CH2OH
CH3CH2OH (no visible change)
\Z24\[0CH\B3CH2OH
CH3CH2OH
\Z24\[0CH\B3\MCH2OH
CH3CH2OH
\Z24\[0CH\B3\MCH\B2OH
CH3CH2OH
\Z24\[0CH\B3\MCH\B2\MOH
CH3CH2OH
