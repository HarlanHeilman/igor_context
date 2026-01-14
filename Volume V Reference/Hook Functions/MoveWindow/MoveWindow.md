# MoveWindow

MoveWindow
V-666
Wave w = root:wave0
MoveWave w, root:DF0:
End
// 3. Dest path with trailing colon and name: Moves wave0 and renames as wave1
Function Demo3()
Setup()
Wave w = root:wave0
MoveWave w, root:DF0:wave1
End
// 4. DFREF dest without trailing colon: Moves wave0 without renaming
Function Demo4()
Setup()
Wave w = root:wave0
DFREF dfr = root:DF0
MoveWave w, dfr
End
// 5. DFREF dest with trailing colon: Generates error
Function Demo5()
Setup()
Wave w = root:wave0
DFREF dfr = root:DF0
MoveWave w, dfr:// Error - trailing colon not allowed
End
// 6. Dest path with trailing colon and name: Moves wave0 and renames as wave1
Function Demo6()
Setup()
Wave w = root:wave0
DFREF dfr = root:DF0
MoveWave w, dfr:wave1
End
// 7. Null DFREF as destination; moves to current data folder
Function Demo7()
Setup()
Wave w = root:wave0
SetDataFolder root:DF0
// make DF0 the current data folder
DFREF noDF = $"Doesnotexist"
MoveWave w, noDF
// moves to current DF
end
// 8. Use MoveWave to make a wave free (move it to no data folder)
Function Demo8()
Setup()
Wave w = root:wave0
// Doesn't do it:
//DFREF noDF = $"Doesnotexist"
//MoveWave w, noDF
// moves to current DF
DFREF freedf = NewFreeDataFolder()
MoveWave w, freedf
KillDataFolder freedf
// as long as wave reference w remains,
// the wave will continue to exist, and is a free wave
end
See Also
The MoveString, MoveVariable, and Rename operations; and Chapter II-8, Data Folders.
MoveWindow 
MoveWindow [flags] left, top, right, bottom
The MoveWindow operation moves the target or specified window to the given coordinates.
Flags
/C
Moves Command window instead of the target window.
/F
Windows: Moves the Igor Pro application “frame” and the frame is then adjusted so 
that no part is offscreen.
Macintosh: Moves nothing.
