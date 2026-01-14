# Proc Pictures in Regular Modules

Chapter IV-3 — User-Defined Functions
IV-57
=U!7FG,5u`*!m?g0PK.mR"U!k63rtBW)]$T)Q*!=Sa1TCDV*V+l:Lh^NW!fu1>;(.<VU1bs4L8&@Q_
<4e(%"^F50:Jg6);j!CQdUA[dh6]%[OkHSC,ht+Q7ZO#.6U,IgfSZ!R1g':oO_iLF.GQ@RF[/*G98D
bjE.g?NCte(pX-($m^\_FhhfL`D9uO6Qi5c[r4849Fc7+*)*O[tY(6<rkm^)/KLIc]VdDEbF-n5&Am
2^hbTu:U#8ies_W<LGkp_LEU1bs4L8&?fqRJ[h#sVSSz8OZBBY!QNJ
ASCII85End
End
Function Demo()
NewPanel
DrawPict 0,0,1,1,ProcGlobal#MyGlobalPicture
End
The ASCII text in the MyGlobalPicture procedure between the ASCII85Begin and ASCII85End is 
similar to output from the Unix btoa command, but with the header and trailer removed.
You can create proc pictures in Igor Pro from normal, global pictures using the Pictures dialog (Misc menu) 
which shows the experiment’s picture gallery. Select a picture in the dialog and click the Copy Proc Picture 
button to place the text on the dlipboard. Then paste it in your procedure file. If the existing picture is not a JPEG 
or PNG, it is converted to PNG.
Proc pictures can be either global or local in scope. Global pictures can be used in all procedure files. Local 
pictures can be used only within the procedure file in which they are defined. Proc pictures are global by 
default and the picture name must be unique for all open procedure files.
Proc pictures can be defined in global procedure files (not in a regular module or independent module), in 
regular modules (see Regular Modules on page IV-236), or independent modules (see Independent 
Modules on page IV-238).
Proc Pictures in Global Procedure Files
Here is an example of a proc picture in a global procedure file:
Picture MyGlobalPicture
ASCII85Begin
...
ASCII85End
End
To draw a proc picture defined in a global procedure file you must qualify the picture name with the Proc-
Global keyword:
DrawPICT 0,0,1,1,ProcGlobal#MyGlobalPicture
A proc picture defined in a global procedure file can be used in any procedure file using the qualified name.
Proc Pictures in Regular Modules
Here is an example of a proc picture in a regular module:
#pragma ModuleName = MyRegularModule
static Picture MyRegularPicture
ASCII85Begin
...
ASCII85End
End
Notice the use of the static keyword. The puts the picture name in the namespace of the regular module.
To draw a proc picture defined in a regular module you must qualify the picture name with the name of 
the regular module:
DrawPICT 0,0,1,1,MyRegularModule#MyRegularPicture
