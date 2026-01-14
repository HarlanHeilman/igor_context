# BeforeUncompiledHook

Chapter IV-10 — Advanced Topics
IV-289
FSetPos refNum, 0
// rewind to start of file
handledOpen= LoadMyFile(refNum)
// returns 1 if loaded OK
endif
endif
return handledOpen
// 1 tells Igor not to open the file
End
See Also
AfterFileOpenHook, SetIgorHook.
BeforeUncompiledHook
BeforeUncompiledHook(changeCode, procedureWindowTitleStr, textChangeStr)
BeforeUncompiledHook is a user-defined function that Igor calls before procedures enter the uncompiled 
state after a change to the procedures.
You can use BeforeUncompiledHook to shut down background tasks or threads before the user functions 
they depend on go away. You can use AfterCompiledHook to restart them.
BeforeUncompiledHook was added in Igor Pro 8.03.
Parameters
changeCode is one of the following values:
procedureWindowTitleStr contains the title of the procedure window whose text is about to change. If the 
procedure window is in an independent module, the title is followed by
[<nameOfIndependentModule>]
as described in documentation for the WinList function.
The content of textChangeStr depends on changeCode:
Details
In most cases your BeforeUncompiledHook function should return 0.
Pending Change
changeCode
Scenarios
Text deletion
1
Delete/backspace key, cut, saved recreation macro, 
merge experiment
Text insertion
2
User typing, paste insert, Execute/P 
"INSERTINCLUDE "
Text replacement
3
User typing, paste over selected text
Open procedure file
4
FileOpen Procedure, OpenProc
Close procedure file
5
Procedure close icon click, CloseProc
SetIgorOption poundDefine
6
SetIgorOption poundDefine causes a recompile
SetIgorOption poundUndefine
7
SetIgorOption poundUndefine causes a recompile
changeCode
textChangedStr
1
""
2
Inserted text
3
Replacement text
4
""
5
""
6
name defined by SetIgorOption poundDefine=name
7
name undefined by SetIgorOption poundUndefine=name
