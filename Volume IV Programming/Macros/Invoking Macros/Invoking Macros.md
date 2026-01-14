# Invoking Macros

Chapter IV-4 — Macros
IV-120
Body Code
The local variable declarations are followed by the body code. This table shows what can appear in body 
code of a macro.
Conditional Statements in Macros
The conditional if-else-endif statement is allowed in macros. It works the same as in functions. See If-Else-
Endif on page IV-40.
Loops in Macros
The do-while loop is supported in macros. It works the same as in functions. See Do-While Loop on page IV-45.
Return Statement in Macros
The return keyword immediately stops executing the current macro. If it was called by another macro, 
control returns to the calling macro.
A macro has no return value so return is used just to prematurely quit the macro. Most macros will have 
no return statement.
Invoking Macros
There are several ways to invoke a macro:
•
From the command line
What
Allowed in Macros?
Comments
Assignment statements
Yes
Includes wave, variable and string assignments.
Built-in operations
Yes
External operations
Yes
External functions
Yes
Calls to user functions
Yes
Calls to macros
Yes
if-else-endif
Yes
if-elseif-endif
No
switch-case-endswitch
No
strswitch-case-endswitch
No
try-catch-endtry
No
structures
No
do-while
Yes
for-endfor
No
Comments
Yes
Comments start with //.
break
Yes
Used in loop statements.
continue
No
default
No
return
Yes, but with no 
return value.
