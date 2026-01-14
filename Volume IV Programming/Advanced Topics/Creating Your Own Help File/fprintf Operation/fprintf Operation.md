# fprintf Operation

Chapter IV-10 — Advanced Topics
IV-260
The conversion specifications are very flexible and make printf a powerful tool. They can also be quite 
involved. The simplest specifications are:
Here are some examples:
printf "%g, %g, %g\r", PI, 6.022e23, 1.602e-19
prints:
3.14159, 6.022e+23, 1.602e-19
printf "%e, %e, %e\r", PI, 6.022e23, 1.602e-19
prints:
3.141593e+00, 6.022000e+23, 1.602000e-19
printf "%f, %f, %f\r", PI, 6.022e23, 1.602e-19
prints:
3.141593, 602200000000000027200000.000000, 0.000000
printf "%d, %d, %d\r", PI, 6.022e23, 1.602e-19
prints:
3, 9223372036854775807, 0
printf "%s, %s\r", "Hello, world", "The time is " + Time()
prints:
Hello, world, The time is 11:43:40 AM
Note that the output for 6.022e23 when printed using the %d conversion specification is wrong. This is 
because 6.022e23 is too big a number to represent as an 64-bit integer.
If you want better control of the output format, you need to know more about conversion specifications. It 
gets quite involved. See the printf operation on page V-770.
sprintf Operation
The sprintf operation is very similar to printf except that it prints to a string variable instead of to Igor’s 
history. The syntax of the sprintf operation is:
sprintf stringVariable, format [, parameter [, parameter ]. . .]
where stringVariable is the name of the string variable to print to and the remaining parameters are as for 
printf. sprintf is useful for generating text to use as prompts in macros, in axis labels and in annotations.
fprintf Operation
The fprintf operation is very similar to printf except that it prints to a file instead of to Igor’s history. The 
syntax of the fprintf operation is:
fprintf variable, format [, parameter [, parameter ]. . .]
Specification
What It Does
%g
Converts a number to text using integer, floating point or exponential notation 
depending on the number’s magnitude.
%e
Converts a number to text using exponential notation.
%f
Converts a number to text using floating point notation.
%d
Converts a number to text using integer notation.
%s
Converts a string to text.
