# Packages

Chapter IV-10 — Advanced Topics
IV-246
Before calling NewMovie, you need to prepare the first frame of your movie as the target graph, page 
layout, or Gizmo window.
If you will be using audio you also need to prepare a sound wave. The sound wave can be of any time dura-
tion but usually will either be the entire length of the movie or will be the length of one video frame. As of 
Igor Pro 7, sound is not supported on Macintosh.
After creating the file and the first video frame and optional audio, you use AddMovieFrame to add as 
many video frames as you wish. You may also add more audio using the AddMovieAudio operation. 
Finally you use the CloseMovie and PlayMovie operations.
When you write a procedure to generate a movie, you need to call the DoUpdate operation after all modi-
fications to the graph, page layout, or Gizmo window and before calling AddMovieFrame. This allows Igor 
to process any changes you have made to the window.
In addition to creating a movie from a window, you can also create movies from pictures in the picture 
gallery (see Pictures on page III-509) using the /PICT flag with NewMovie and AddMovieFrame. You can 
put pictures of Igor graphs, tables, page layouts, and Gizmo plots in the gallery using SavePICT.
Extracting Movie Frames
You can extract individual frames from a movie and can control movie playback using PlayMovieAction.
Movie Programming Examples
For examples of programming with movies, choose FileExample ExperimentsMovies & Audio.
Timing
There are two methods you can use when you want to measure elapsed time:
•
The ticks counter using the ticks function
•
The microsecond timer using StartMSTimer and StopMSTimer
Ticks Counter
You can easily measure elapsed time with a precision of 1/60th of a second using the ticks function. It 
returns the tick count which starts at zero when you first start your computer and is incremented at a rate 
of approximately 60 Hz rate from then on.
Here is an example of typical use:
…
Variable t0
…
t0= ticks
<operations you wish to time>
printf "Elapsed time was %g seconds\r",(ticks-t0)/60
…
Microsecond Timer
You can measure elapsed time to microsecond accuracy for durations up to 35 minutes using the microsec-
ond timer. See the StartMSTimer function (page V-906) for details and an example.
Packages
A package is a set of files that adds significant functionality to Igor. Packages consist of procedure files and 
may also include XOPs, help files and other supporting files.
