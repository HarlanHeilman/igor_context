# GetIndexedObjName

GetFormula
V-303
GetFormula 
GetFormula(objName)
The GetFormula function returns a string containing the named object’s dependency formula. The named 
object must be a wave, numeric variable or string variable.
Details
Normally an object will have an empty dependency formula and GetFormula will return an empty string 
(""). If you assign a expression to an object using the := operator or the SetFormula operation, the text on 
the right side of the := or the parameter to SetFormula is the object’s dependency formula and this is what 
GetFormula will return.
Examples
Variable/G dependsOnIt
Make/O wave0 := dependsOnIt*2
//wave0 changes when dependsOnItdoes
Print GetFormula(wave0)
Prints the following in the history area:
dependsOnIt*2
See Also
See Dependency Formulas on page IV-230, and the SetFormula operation.
GetGizmo 
GetGizmo [flags] keyword [=value]
The GetGizmo operation provides information about a Gizmo display window.
Documentation for the GetGizmo operation is available in the Igor online help files only. In Igor, execute:
DisplayHelpTopic "GetGizmo"
GetIndependentModuleName 
GetIndependentModuleName()
The GetIndependentModuleName function returns the name of the currently running Independent 
Module. If no independent module is running, it returns “ProcGlobal”.
See Also
 Independent Modules on page IV-238.
IndependentModuleList.
GetIndexedObjName 
GetIndexedObjName(sourceFolderStr, objectType, index)
The GetIndexedObjName function returns a string containing the name of the indexth object of the 
specified type in the data folder specified by the string expression.
GetIndexedObjNameDFR is preferred.
Parameters
sourceFolderStr can be either ":" or "" to specify the current data folder. You can also use a full or partial 
data folder path. index starts from zero. If no such object exists a zero length string ("") is returned. 
objectType is one of the following values: 
objectType 
What You Get
1
Waves
2
Numeric variables
3
String variables
4
Data folders
