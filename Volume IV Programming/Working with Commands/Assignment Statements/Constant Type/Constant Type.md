# Constant Type

Chapter IV-1 — Working with Commands
IV-9
Although waves can have integer numeric types, wave expressions are always evaluated in double preci-
sion floating point. The floating point values are converted to integers by rounding as the final step before 
storing the value in the wave. If the value to be stored exceeds the range of values that the given integer 
type can represent, the results are undefined.
Starting with Igor Pro 7, Igor supports integer local variables and 64-bit integer waves. When one of these 
is the destination of an assignment statement, Igor performs calculations using integer arithmetic. See 
Expression Evaluation on page IV-38 for details.
The number type of the destination determines the initial number type (real or complex) of the assignment 
expression. This is important because Igor can not deal with “surprise” or “runtime” changes in number 
type. An example would be taking the square root of a negative number requiring that all following arith-
metic be done using complex numbers.
Here are some examples:
Variable a, b, c, var1
Variable/C cvar1
Make wave1
var1= a*b
cvar1= c*cmplx(a+1,b-1)
wave1= var1 + real(cvar1)
The first expression is evaluated using the real number type. The second expression contains a mixture of 
two types. The multiplication of c with the result of the cmplx function is evaluated as complex while the 
arguments to the cmplx function are evaluated as real. The third example is evaluated as real except for the 
argument to the real function which is evaluated as complex.
Constant Type
You can define named numeric and string constants in Igor procedure files and use them in the body of 
user-defined functions.
Constants are defined in procedure files using following syntax:
Constant <name1> = <literal number> [, <name2> = <literal number>]
StrConstant <name1> = <literal string> [, <name2> = <literal string>]
You can use the static prefix to limit the scope to the given source file. For debugging, you can use the Over-
ride keyword as with functions.
These declarations can be used in the following ways:
Constant kFoo=1,kBar=2
StrConstant ksFoo="hello",ksBar="there"
static Constant kFoo=1,kBar=2
static StrConstant ksFoo="hello",ksBar="there"
Override Constant kFoo=1,kBar=2
Override StrConstant ksFoo="hello",ksBar="there"
Programmers may find that using the “k” and “ks” prefixes will make their code easier to read.
Names for numeric and string constants can conflict with all other names. Duplicate constants of a given 
type are not allowed except for static constants in different files and when used with Override. The only 
true conflict is with variable names and with certain built-in functions that do not take parameters such as 
pi. Variable names override constants, but constants override functions such as pi.
