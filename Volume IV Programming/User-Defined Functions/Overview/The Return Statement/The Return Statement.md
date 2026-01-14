# The Return Statement

Chapter IV-3 — User-Defined Functions
IV-35
You can declare local variables anywhere in the function after the parameter declarations.
Body Code
This table shows what can appear in body code of a function.
Statements are limited to 2500 bytes per line except for assignment statements which, in Igor Pro 7 or later, 
can be continued on subsequent lines.
Line Continuation
In user-defined functions in Igor Pro 7 or later, you can use arbitrarily long expressions by including a line 
continuation character at the very end of a line. The line continuation character is backslash. For example:
Function Example1(double v1)
return v1 + \
2
End
Line continuation is supported for any numeric or string expression in a user-defined function. Here is an 
example using a string expression:
Function/S Example2(string s1)
return s1 + \
" " + \
"there"
End
Line continuation is supported for numeric and string expressions only. It is not supported on other types 
of commands. For example, this generates a compile error:
Function Example3(double v1)
Make wave0
\
 wave1
End
The Return Statement
A return statement often appears at the end of a function, but it can appear anywhere in the function body. 
You can also have more than one return statement.
The return statement immediately stops executing the function and returns a value to the calling function. 
The type of the returned value must agree with the type declared in the function declaration.
If there is no return statement, or if a function ends without hitting a return statement, then the function 
returns the value NaN (Not a Number) for numeric functions and null for other types of functions. If the 
calling function attempts to use the null value, Igor reports an error.
What
Allowed in Functions?
Comment
Assignment statements
Yes
Includes wave, variable and string assignments.
Built-in operations
Yes, with a few exceptions.
See Operations in Functions on page IV-111 for 
exceptions.
Calls to user functions
Yes
Calls to macros
No
External functions
Yes
External operations
Yes, with exceptions.
