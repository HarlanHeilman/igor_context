#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.2	// Requires Igor 6.2
#pragma version=7.0		// shipped with Igor 7.0
#pragma IndependentModule=WMGP

// 19JUN15 Removed GizmoOrthoZoom (JP)
// 3AUG10 Added GizmoAnnotations (JP)
// 5MAR10 IndependentModule always used, added GizmoOrthoZoom, requires Igor 6.2 or later. (JP)
// 22SEP08 IndependentModule used only for Igor 6.1 or later. (JP)
// 10SEP08 Added WM_GizmoProcVersion() to test for the presence of compiled Gizmo procedures.
// 05MAY06 removed Axis Labels; these are now supported internally from axes dialog.
// 10JAN05  

#include <AppendContourToGizmo>
#include <AppendImageToGizmo>
#include <BoxLimitPanel>
#include <GizmoAnnotations>
#include <Gizmo Box Axes>
#include <Gizmo3DBarChart>
#include <GizmoBlending>
#include <GizmoExtrude>
#include <GizmoMovie>
#if IgorVersion()<7
#include <GizmoOrthoZoom>
#endif
#include <GizmoRotation>
#include <GizmoSlicer>
#include <GizmoUtils>

Function WM_GizmoProcVersion()
	Print "Why are you asking me this?"
End
