# Numeric Type

Chapter IV-1 — Working with Commands
IV-8
Note that the double equal sign, ==, is used to mean equality while the single equal sign, =, is used to indicate 
assignment.
Because of roundoff error, using == to test two numbers for equality may give incorrect results. It is safer to 
use <= and >= to see if a number falls in a narrow range. For example, imagine that you want to compare a 
variable to see if it is equal to one-third. The expression:
(v1 == 1/3)
is subject to failure because of roundoff. It is safer to use something like
((v1 > .33332) && (v1 < .33334))
If the numbers are integers then the use of == is safe because integers smaller than 253 (approximately 1016) 
are represented precisely in double-precision floating point numbers.
The previous discussion on operators has assumed numeric operands. The + operator is the only one that works 
with both numeric and string operands. For example, if str1 is a string variable then the assignment statement
str1 = "Today is " + "a nice day"
assigns the value “Today is a nice day” to str1. The other string operator, $ is discussed in String Substitu-
tion Using $ on page IV-18.
Unless specified otherwise by parentheses, unary negation or complementation are carried out first fol-
lowed by exponentiation then by multiplication or division followed by addition or subtraction then by 
comparison operators. The wave assignment:
wave1 = ((1 + 2) * 3) ^ 2
assigns the value 81 to every point in wave1, but
wave1 = 1 + 2 * 3 ^ 2
assigns the value 19.
-a^b is an exception to this rule and is evaluated as -(a^b).
The precedence of string substitution, substrings, and wave indexing is somewhat complex. When in doubt, 
use parenthesis to enforce the precedence you want.
Obsolete Operators
As of Igor Pro 4.0, the old bitwise complement (%~), bitwise AND (%&), and bitwise OR (%|) operators 
have been replaced by new versions that omit the % character from the operator. These old bitwise opera-
tors can still be used interchangeably with the new versions but are not recommended for new code.
Operands
In addition to literal numbers like 3.141 or 27, operators can operate on variables and function values. In the 
assignment statement:
var1 = log(3.7) + var2
the operator + operates on the function value returned by log and on the variable var2. Functions and func-
tion values are discussed later in this chapter.
Numeric Type
In Igor, each numeric destination object (wave or variable) has its own numeric type. The numeric type con-
sists of the numeric precision (e.g., double precision floating point) and the number type (real or complex). 
Waves can be single or double precision floating point or various sizes of integer but variables are always 
double precision floating point.
The numeric precision of the destination does not affect the calculations. With the exception of a few oper-
ations that are done in place such as the FFT, all calculations are done in double precision.
