# The Debugger

Chapter IV-8 — Debugging
IV-212
Debugging Procedures 
There are two techniques for debugging procedures in Igor:
•
Using print statements
•
Using the symbolic debugger
For most situations, the symbolic debugger is the most effective tool. In some cases, a strategically placed 
print statement is sufficient.
Debugging With Print Statements
This technique involves putting print statements at a certain point in a procedure to display debugging 
messages in Igor’s history area. In this example, we use Printf to display the value of parameters to a func-
tion and then Print to display the function result.
Function Test(w, num, str)
Wave w
Variable num
String str
Printf "Wave=%s, num=%g, str=%s\r", NameOfWave(w), num, str
<body of function>
Print result
return result
End
See Creating Formatted Text on page IV-259 for details on the Printf operation.
The Debugger
When a procedure doesn’t produce the results you want, you can use Igor’s built-in debugger to observe 
the execution of macros and user-defined functions while single-stepping through the lines of code.
The debugger is normally disabled. Select Enable Debugger in either the Procedure menu or the contextual 
menu shown by control-clicking (Macintosh) or by right-clicking (Windows) in any procedure window.
