# AddMovieFrame

AddMovieAudio
V-21
Print AddListItem("z", "b,c,", ",", Inf)
// prints "b,c,z,"
Print AddListItem("", "b-c-", "-")
// prints "-b-c-"
See Also
The FindListItem, FunctionList, ItemsInList, RemoveByKey, RemoveFromList, RemoveListItem, 
StringFromList, StringList, TraceNameList, VariableList, and WaveList functions.
AddMovieAudio 
AddMovieAudio soundWave
The AddMovieAudio operation adds audio samples to the audio track of the currently open movie.
In Igor Pro 7.00 and later, this operation is not supported on Macintosh.
Parameters
soundWave contains audio samples with an amplitude from -128 to +127 and with the same time scale as the 
prototype soundWave used to open the movie.
Flags 
Details
You can create movies with 16-bit and stereo sound by providing a sound wave in the appropriate format. 
To specify 16-bit sound, the wave type must be signed 16-bit integer (/W flag in Make or Redimension). To 
specify stereo, use a wave with two columns (or any other number of channels as desired).
Output Variables
See Also
Movies on page IV-245, NewMovie, AddMovieFrame
AddMovieFrame 
AddMovieFrame [/PICT=pictName]
The AddMovieFrame operation adds the top graph, page layout, Gizmo window, or the specified picture 
to the currently open movie.
Support for page layout and Gizmo windows was added in Igor Pro 7.00.
When you write a procedure to generate a movie, you need to call the DoUpdate operation after all 
modifications to the target window and before calling AddMovieFrame. This allows Igor to process any 
changes you have made to the window.
In Igor7 or later, the target window at the time you call NewMovie is remembered and is used by 
AddMovieFrame even if it is not the target window when you call AddMovieFrame.
If the /PICT flag is provided, then the specified picture from the picture gallery (see Pictures on page III-509) 
is used in place of the target window.
Flags 
Output Variables
/Z
Suppresses error reporting. If you use /Z, check the V_Flag output variable to see 
if the operation succeeded.
V_Flag
Set to 0 if the operation succeeded or to a non-zero error code.
V_Flag is set only if you use the /Z flag.
/Z
Suppresses error reporting. If you use /Z, check the V_Flag output variable to see 
if the operation succeeded.
V_Flag
Set to 0 if the operation succeeded or to a non-zero error code.
V_Flag is set only if you use the /Z flag.
