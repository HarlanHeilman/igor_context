# Put WAVE Declaration After Wave Is Created

Chapter IV-3 — User-Defined Functions
IV-66
num1 = 1.234
w = 0
End
If you use a local name that is the same as the global name, and if you want to refer to a global in the current 
data folder, you can omit the <path to …> part of the declaration:
Function GoodExample3()
SVAR gStr1
// Refers to gStr1 in current data folder.
NVAR gNum1
// Refers to gNum1 in current data folder.
WAVE wave0
// Refers to wave0 in current data folder.
gStr1 = "The answer is:"
gNum1 = 1.234
wave0 = 0
End
GoodExample3 accesses globals in the current data folder while GoodExample2 accesses globals in a spe-
cific data folder.
If you use <path to …>, it may be a simple name (gStr1) or it may include a full or partial path to the name.
The following are valid examples, referencing a global numeric variable named gAvg:
NVAR gAvg= gAvg
NVAR avg= gAvg
NVAR gAvg
NVAR avg= root:Packages:MyPackage:gAvg
NVAR avg= :SubDataFolder:gAvg
NVAR avg= $"gAvg"
NVAR avg= $("g"+ "Avg")
NVAR avg= ::$"gAvg"
As illustrated above, the local name can be the same as the name of the global object and the lookup expres-
sion can be either a literal name or can be computed at runtime using $<string expression>.
If your function creates a global variable and you want to create a reference to it, put the NVAR statement 
after the code that creates the global. The same applies to SVARs and, as explained next, to WAVEs.
Put WAVE Declaration After Wave Is Created
A wave declaration serves two purposes. At compile time, it tells Igor the local name and type of the wave. 
At runtime, it connects the local name to a specific wave. In order for the runtime purpose to work, you 
must put wave declaration after the wave is created.
Function BadExample()
String path = "root:Packages:MyPackage:wave0"
Wave w = $path
// WRONG: Wave does not yet exist.
Make $path
w = p
// w is not connected to any wave.
End
Function GoodExample()
String path = "root:Packages:MyPackage:wave0"
Make $path
Wave w = $path
// RIGHT
w = p
End
Both of these functions will successfully compile. BadExample will fail at runtime because w is not associ-
ated with a wave, because the wave does not exist when the "Wave w = $path" statement executes.
This rule also applies to NVAR and SVAR declarations.
