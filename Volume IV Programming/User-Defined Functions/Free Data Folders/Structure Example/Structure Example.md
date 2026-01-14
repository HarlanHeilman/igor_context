# Structure Example

Chapter IV-3 — User-Defined Functions
IV-102
Structures, including substructures, can be copied using simple assignment from one structure to the other. 
The source and destination structures must defined using the same structure name.
The Print operation can print individual elements of a structure or can print a summary of the entire 
STRUCT variable.
Structure Example
Here is a contrived example using structures. Try executing foo(2):
Constant kCaSize = 5
Structure substruct
Variable v1
Variable v2
EndStructure
Structure mystruct
Variable var1
Variable var2[10]
String s1
WAVE fred
NVAR globVar1
SVAR globStr1
FUNCREF myDefaultFunc afunc
STRUCT substruct ss1[3]
char ca[kCaSize+1]
EndStructure
Function foo(n)
Variable n
Make/O/N=20 fred
Variable/G globVar1 = 111
String/G aGlobStr="a global string var"
STRUCT mystruct ms
ms.var1 = 11
ms.var2[n] = 22
ms.s1 = "string s1"
WAVE ms.fred
// could have =name if want other than waves named fred
NVAR ms.globVar1
SVAR ms.globStr1 = aGlobStr
FUNCREF myDefaultFunc ms.afunc = anotherfunc
ms.ss1[n].v1 = ms.var1/2
ms.ss1[0] = ms.ss1[n]
ms.ca = "0123456789"
bar(ms,n)
Print ms.var1,ms.var2[n],ms.s1,ms.globVar1,ms.globStr1,ms.ss1[n].v1
Print ms.ss 1[n].v2,ms.ca,ms.afunc()
Print "a whole wave",ms.fred
Print "the whole ms struct:",ms
STRUCT substruct ss
ss = ms.ss1[n]
Print "copy of substruct",ss
End
Function bar(s,n)
STRUCT mystruct &s
Variable n
s.ss1[n].v2 = 99
s.fred = sin(x)
Display s.fred
End
Function myDefaultFunc()
return 1
End
Function anotherfunc()
return 2
End
