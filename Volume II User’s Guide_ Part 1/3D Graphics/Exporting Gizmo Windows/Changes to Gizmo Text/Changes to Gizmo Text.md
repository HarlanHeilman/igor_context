# Changes to Gizmo Text

Chapter II-17 — 3D Graphics
II-471
Gizmo Recreation Macro Changes
Prior to Igor7 every Gizmo recreation macro contained the line:
ModifyGizmo startRecMacro
In Igor7 and later the syntax includes a version number e.g.,
ModifyGizmo startRecMacro=700
For backward compatibility, the Gizmo XOP as of Igor Pro 6.30 accepts the new startRecMacro syntax.
In Igor7 and later Gizmo uses counter-clockwise as the front face default except when executing Gizmo rec-
reation macros from previous versions. This is unlikely to affect most you but if it does, you can override 
this default by specifying an explicit frontFace operation in the Gizmo display list.
Use of GL Constants in Gizmo Commands
Previous versions of Gizmo supported the use of OpenGL constants in commands. For example, you could 
write:
AppendToGizmo attribute blendFunc={GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA}, 
name=blend0
In Igor7 and later the GL constants, such as GL_SRC_ALPHA, are not recognized and you must use the 
numeric equivalent instead. For example:
AppendToGizmo attribute blendFunc={770,771}, name=blend0
You can execute GetGizmo to determine what numeric value represents a given constant. For example:
GetGizmo constant="GL_SRC_ALPHA"
This prints "770" to the history. You can copy the printed number and past it into your procedure.
Exporting Gizmo Graphics
In Igor7 and later you can export Gizmo graphics using FileSave Graphics which generates a SavePICT 
command. The ExportGizmo operation is only partially supported for some degree of backward compati-
bility. It can export to the clipboard or to an Igor wave and it can print but it can no longer export to a file. 
Use SavePICT instead.
Changes to Gizmo Text
Prior to Igor7 Gizmo displayed axis labels, tick mark labels, and string objects by composing a 3D filled 
polygon for each character. The polygon representation allowed Gizmo to handle each string as a true 3D 
object which could be drawn at any position in the display volume independent of the orientation of the 
axes. This approach had three disadvantages:
•
Labels were not always legible and could disappear completely in some orientations
•
The conversion into polygons made it impractical to use anti-aliasing to smooth the characters
•
Font sizes were inconsistent across platforms
In Igor7 we moved Gizmo to a new text rendering technology that generates 2D smooth text. While this 
technology addresses the three issues mentioned, it does not produce text objects that match those pro-
duced by previous versions. Consequently you will see differences when loading pre-Igor7 experiments 
that use text, such as axis labels, with offsets and rotations which are no longer supported.
In Igor7 and later you can use formatted text to construct complex axis labels. Double-click an axis item in 
the Display or object list to display the Axis Properties dialog and click the Axis Labels tab.
