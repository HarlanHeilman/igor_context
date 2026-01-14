# For Loop

Chapter IV-3 — User-Defined Functions
IV-46
While Loop
This fragment will execute the body of the loop zero or more times, like the while loop in C.
do
if (i > lim)
break
// This breaks out of the loop.
endif
<loop body>
i += 1
while(1)
// This would loop forever without the break.
...
// Execution continues here after the break.
In this example, the loop increment is 1 but it can be any value.
For Loop
The basic syntax of a for loop is:
for(<initialize loop variable>; <continuation test>; <update loop variable>)
<loop body>
endfor
Here is a simple example:
Function Example1()
Variable i
for(i=0; i<5; i+=1)
print i
endfor
End
The beginning of a for loop consists of three semicolon-separated expressions. The first is usually an assign-
ment statement that initializes one or more variables. The second is a conditional expression used to deter-
mine if the loop should be terminated — if true, nonzero, the loop is executed; if false, zero, the loop 
terminates. The third expression usually updates one or more loop variables.
When a for loop executes, the initialization expression is evaluated only once at the beginning. Then, for each 
iteration of the loop, the continuation test is evaluated at the start of every iteration, terminating the loop if 
needed. The third expression is evaluated at the end of the iteration and usually increments the loop variable.
All three expressions in a for statement are optional and can be omitted independent of the others; only the 
two semicolons are required. The expressions can consist of multiple assignments, which must be separated 
by commas.
In addition to the continuation test expression, for loops may also be terminated by break or return state-
ments within the body of the loop.
A continue statement executed within the loop skips the remaining body code and execution continues 
with the loop’s update expression.
Here is a more complex example:
Function Example2()
Variable i,j
for(i=0,j=10; ;i+=1,j*=2)
if (i == 2)
continue
endif
Print i,j
if (i == 5)
break
endif
