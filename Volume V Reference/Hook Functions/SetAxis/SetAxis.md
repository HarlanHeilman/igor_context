# SetAxis

SetActiveSubwindow
V-835
Details
If whichOne is NaN, then "" is returned.
whichOne must always be a real value.
Unlike the ? : conditional operator, SelectString always evaluates all of the string expression parameters 
str1, str2, …
SelectString works in a macro, whereas the conditional operator does not.
Examples
Print SelectString(0,"hello","there")
// prints "hello"
Print SelectString(1,"hello","there")
// prints "there"
Print SelectString(-3,"hello","there","jack")
// prints "hello"
Print SelectString(0,"hello","there","jack")
// prints "there"
Print SelectString(100,"hello","there","jack")
// prints "jack"
See Also
The SelectNumber function and String Expressions on page IV-13. Also, Operators on page IV-6 for details 
about the ?: operator.
SetActiveSubwindow 
SetActiveSubwindow subWinSpec
The SetActiveSubwindow operation specifies the subwindow that is to be activated. This operation is 
mainly for use by recreation macros.
Parameters
subWinSpec specifies an existing subwindow. See Subwindow Syntax on page III-92 for details on 
subwindow specifications.
Use _endfloat_ for subWinSpec to make a newly-created floating panel not be the default target.
See Also
GetWindow with the activeSW keyword.
SetAxis 
SetAxis [flags] axisName [, num1, num2]
The SetAxis operation sets the extent (or “range”) of the named axis.
Parameters
axisName is usually “left”, “right”, “top” or “bottom”, but it can also be the name of a free axis, such as 
“vertCrossing”.
If axisName is a vertical axis such as “left” or “right” then num1 sets the bottom end of the axis and num2 
sets the top end of the axis.
If axisName is a horizontal axis such as “top” or “bottom” then num1 sets the left end of the axis and num2 
sets the right end of the axis.
You can flip the graph by reversing num1 and num2 (or by using /A/R). This is particularly useful for 
images, because Igor plots an image inverted.
If you pass * (asterisk) for num1 and/or num2 then the corresponding end of the axis will be autoscaled.
Flags
/A[=a]
Autoscale axis (when used, num1, num2 should be omitted).
a=0:
No autoscale. Same as no /A flag.
a=1:
Normal autoscale. Same as /A.
a=2:
Autoscale Y axis to a subset of the data defined by the current X axis 
range.
