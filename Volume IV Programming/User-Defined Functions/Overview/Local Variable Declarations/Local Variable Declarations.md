# Local Variable Declarations

Chapter IV-3 — User-Defined Functions
IV-34
Local Variable Declarations
The parameter declarations are followed by the local variable declarations if the procedure uses local vari-
ables. Local variables exist only during the execution of the procedure. They are declared using one of these 
keywords:
double is a synonym for Variable and complex is a synonym for Variable/C.
Numeric and string local variables can optionally be initialized. For example:
Function Example(p1)
Variable p1
// Here are the local variables
Variable v1, v2
Variable v3=0
Variable/C cv1=cmplx(0,0)
String s1="test", s2="test2"
<Body code>
End
If you do not supply explicit initialization, Igor automatically initializes local numeric variables with the 
value zero. Local string variables are initialized with a null value such that, if you try to use the string before 
you store a value in it, Igor reports an error.
Initialization of other local variable types is discussed below. See Wave References on page IV-71, Data 
Folder References on page IV-78, Function References on page IV-107, and Structures in Functions on 
page IV-99.
The name of a local variable is allowed to conflict with other names in Igor, but they must be unique within 
the function. If you create a local variable named “sin”, for example, then you will be unable to use Igor’s 
built-in sin function within the function.
Variable
Numeric variable
Variable/C
Complex numeric variable
String
String variable
NVAR
Global numeric variable reference
NVAR/C
Global complex numeric variable reference
SVAR
Global variable reference
Wave
Wave reference
Wave/C
Complex wave reference
Wave/T
Text wave reference
DFREF
Data folder reference
FUNCREF
Function reference
STRUCT
Structure
int
Signed integer - requires Igor7 or later
int64
Signed 64-bit integer - requires Igor7 or later
uint64
Unsigned 32-bit integer - requires Igor7 or later
double
Numeric variable - requires Igor7 or later
complex
Complex numeric variable - requires Igor7 or later
