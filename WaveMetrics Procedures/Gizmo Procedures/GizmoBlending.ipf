#pragma rtGlobals=3		// Use modern global access method.
#pragma moduleName=GizmoBlending
#pragma Igorversion=6.2	// requires Igor 6.2
#pragma version=6.2		// shipped with Igor 6.2
#include <GizmoUtils>, version>=6.2

// Gizmo Blending - simply add the enable and attribute for normal blending.
// This makes updates slower but allows alpha values for objects to render properly.
// 18FEB05 , JP: Initial version
// 06OCT08 , JP: AddBlendingToGizmo is now a function, with all that that implies.
// 25MAR10 , JP: AddBlendingToGizmo takes optional gizmoName, includes GizmoUtils.ipf, requires Igor 6.2
// 04AUG10 , JP: AddBlendingToGizmo tells Gizmo to compile only if something changed, accepts optional atThisDisplayIndex and doRecompile parameters.
//				Added new MoveBlendingToDisplayIndex function.

Function AddBlendingToGizmo([gizmoName,atThisDisplayIndex,doRecompile])
	String gizmoName	// optional, defaults to top gizmo window
	Variable atThisDisplayIndex	// optional, defaults to 0 (first display position)
	Variable doRecompile		// optional, defaults to 1 (true). Use 0 to skip the compile command
	
	if( ParamIsDefault(gizmoName) )
		gizmoName= TopGizmo()
	endif
	if( ParamIsDefault(atThisDisplayIndex) )
		atThisDisplayIndex= 0
	endif
	if( ParamIsDefault(doRecompile) )
		doRecompile= 1
	endif
	if( ValidGizmoName(gizmoName) )
		String commands, cmd
		Variable didSomething= 0
		sprintf commands, "ModifyGizmo/N=%s startRecMacro;", gizmoName
		if( !NameIsInGizmoDisplayList(gizmoName,"enableBlend") )
		//	sprintf cmd,  "ModifyGizmo/N=%s insertDisplayList=%d, opName=enableBlend, operation=enable, data=GL_BLEND", gizmoName, atThisDisplayIndex	// GL_BLEND doesn't work
			sprintf cmd,  "ModifyGizmo/N=%s insertDisplayList=%d, opName=enableBlend, operation=enable, data=3042", gizmoName, atThisDisplayIndex
			commands += cmd+";"
			didSomething= 1
		endif
		if( !NameIsInGizmoAttributeList(gizmoName,"blendingFunction") )
			sprintf cmd, "AppendToGizmo/N=%s attribute blendFunc={GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA},name=blendingFunction", gizmoName
			commands += cmd+";"
			didSomething= 1
		endif
		if( !NameIsInGizmoDisplayList(gizmoName,"blendingFunction") )
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, attribute=blendingFunction", gizmoName, atThisDisplayIndex
			commands += cmd+";"
			didSomething= 1
		endif
		if( didSomething )
			if( doRecompile )
				sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
				commands += cmd+";"
			endif
			sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
			commands += cmd+";"
			String oldDF= SetWMGizmoDF()
			GizmoEchoExecute(commands, slashZ=1, slashQ=1)
			SetDataFolder oldDF
		endif
	endif
End

Function MoveBlendingToDisplayIndex(gizmoName, displayIndex [,doRecompile])
	String gizmoName
	Variable displayIndex	// 0 to move enableBlend and blendingFunction to the front. -1 is not a valid input.
	Variable doRecompile		// optional, defaults to 1 (true). Use 0 to skip the compile command
	
	if( ParamIsDefault(doRecompile) )
		doRecompile= 1
	endif

	if( ValidGizmoName(gizmoName)  && displayIndex >= 0 )
		Variable blendingFunctionIndex= GetDisplayIndexOfNamedObject(gizmoName,"blendingFunction")
		Variable enableBlendIndex= GetDisplayIndexOfNamedObject(gizmoName,"enableBlend")
		if( enableBlendIndex >= 0 && blendingFunctionIndex >= 0 )	// we have both, perhaps they're not in need of repositioning?
			if( enableBlendIndex <= displayIndex && blendingFunctionIndex <= displayIndex )
				return 0	// yep, nothing need be done
			endif
			// otherwise since we can't MOVE objects, we must delete and recreate them.
		endif
		RemoveMatchingGizmoDisplay(gizmoName,"blendingFunction;enableBlend;")	// remove them both, even though only one may be in the wrong place
		AddBlendingToGizmo(gizmoName=gizmoName,atThisDisplayIndex=displayIndex,doRecompile=doRecompile)
	endif
End