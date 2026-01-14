# Accessing Global Variables and Waves Using Liberal Names

Chapter IV-3 — User-Defined Functions
IV-68
Accessing Complex Global Variables and Waves
You must specify if a global numeric variable or a wave is complex using the /C flag:
NVAR/C gc1 = gc1
WAVE/C gcw1 = gcw1
Accessing Text Waves
Text waves must be accessed using the /T flag:
WAVE/T tw= MyTextWave
Accessing Global Variables and Waves Using Liberal Names
There are two ways to initialize a reference an Igor object: using a literal name or path or using a string vari-
able. For example:
Wave w = root:MyDataFolder:MyWave
// Using literal path
String path = "root:MyDataFolder:MyWave"
Wave w = $path
// Using string variable
Things get more complicated when you use a liberal name rather than a standard name. A standard name 
starts with a letter and includes letters, digits and the underscore character. A liberal name includes other 
characters such as spaces or punctuation.
In general, you must quote liberal names using single quotes so that Igor can determine where the name 
starts and where it ends. For example:
Wave w = root:'My Data Folder':'My Wave'
// Using literal path
String path = "root:'My Data Folder':'My Wave'"
Wave w = $path
// Using string variable
However, there is an exception to the quoting requirement. The rule is:
You must quote a literal liberal name and you must quote a liberal path stored in a 
string variable but you must not quote a simple literal liberal name stored in a string 
variable.
The following functions illustrate this rule:
// Literal liberal name must be quoted
Function DemoLiteralLiberalNames()
NewDataFolder/O root:'My Data Folder'
Make/O root:'My Data Folder':'My Wave' // Literal name must be quoted
SetDataFolder root:'My Data Folder'
// Literal name must be quoted
Wave w = 'My Wave'
// Literal name must be quoted
w = 123
SetDataFolder root:
End
// String liberal PATH must be quoted
Function DemoStringLiberalPaths()
String path = "root:'My Data Folder'"
NewDataFolder/O $path
path = "root:'My Data Folder':'My Wave'"
// String path must be quoted
Make/O $path
Wave w = $path
