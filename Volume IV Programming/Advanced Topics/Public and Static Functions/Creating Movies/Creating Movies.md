# Creating Movies

Chapter IV-10 — Advanced Topics
IV-245
from a regular module without using a qualified name.
•
A public function defined in an independent module can be called from a procedure file in Proc-
Global or from a regular module using a qualified name such as IndependentModuleA#Test.
•
A public function defined in an independent module can not be called from another independent 
module.
•
A static function defined in ProcGlobal can be called only from the file in which it is defined.
•
A static function defined in a regular module can be called from a procedure file in ProcGlobal or 
from another regular module using a qualified name such as RegularModuleA#Test.
•
A static function defined in a regular module can not be called from an independent module.
•
A static function defined in an independent module can be called only from the procedure file in 
which it is defined.
•
An independent module can call only functions defined in that independent module.
Sound
Two operations are provided for playing of sound through the computer speakers:
•
PlaySound
•
PlaySnd (Macintosh)
The PlaySound operation takes the sound data from a wave.
The obsolete PlaySnd operation gets its data from a Macintosh 'snd ' resource stored in a file.
A number of sound input operations are provided: SoundInStatus (page V-888) , SoundInSet (page V-887) , 
SoundInRecord (page V-887) , SoundInStartChart (page V-888) and SoundInStopChart (page V-889) . 
Several example experiments that use these routines can be found in your Igor Pro Folder in the Examples folder.
The SoundLoadWave operation loads various sound file formats into waves and SoundSaveWave saves 
wave data to sound files. These operations replace SndLoadWave, SoundSaveAIFF and SoundSaveWAV 
from the obsolete SndLoadSaveWave XOP. 
Movies
You can create movies, optionally with a soundtrack, and extract frames from movies for analysis.
Playing Movies
Use the PlayMovie operation to play a movie in your default movie viewing program.
Creating Movies
You can create a movie from a graph, page layout, or Gizmo window. To do this, you write a procedure 
that modifies the window and adds a frame to the movie in a loop. On Windows, you can include audio.
Here are the operations used to create and play a movie:
•
NewMovie
•
AddMovieFrame
•
AddMovieAudio
•
CloseMovie
•
PlayMovie
•
PlayMovieAction
The NewMovie operation creates a movie file and also defines the movie frame rate and optional audio 
track specifications.
