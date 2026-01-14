# Waves — The Key Igor Concept

Chapter I-1 — Introduction to Igor Pro
I-2
Introduction to Igor Pro
Igor Pro is an integrated program for visualizing, analyzing, transforming and presenting experimental 
data.
Igor Pro’s features include:
•
Publication-quality graphics
•
High-speed data display
•
Ability to handle large data sets
•
Curve-fitting, Fourier transforms, smoothing, statistics, and other data analysis
•
Waveform arithmetic
•
Image display and processing
•
Combination graphical and command-line user interface
•
Automation and data processing via a built-in programming environment
•
Extensibility through modules written in the C and C++ languages
Some people use Igor simply to produce high-quality, finely-tuned scientific graphics. Others use Igor as 
an all-purpose workhorse to acquire, analyze and present experimental data using its built-in program-
ming environment. We have tried to write the Igor program and this manual to fulfill the needs of the entire 
range of Igor users.
Igor 32-bit and 64-bit Versions
Igor is available in both 32-bit (Windows only) and 64-bit versions. When making a distinction between 
these versions, we sometimes refer to the 32-bit version as “IGOR32” and the 64-bit version as “IGOR64”.
On Windows, both 32-bit and 64-bit applications are installed. The 64-bit version runs by default. You 
should run the 32-bit version only if compatibility with a 32-bit XOP (plug-in) is required.
On Macintosh, starting with Igor Pro 8.00, Igor is available only as a 64-bit application. If you need to run 
with a 32-bit XOP (plug-in) then you must run Igor Pro 7.
Igor Objects
The basic objects that all Igor users work with are:
•
Waves
•
Graphs
•
Tables
•
Page layouts
A collection of objects is called an “experiment” and is stored in an experiment file. When you open an 
experiment, Igor recreates the objects that comprise it.
Waves — The Key Igor Concept 
We use the term “wave” to describe the Igor object that contains an array of numbers. Wave is short for 
“waveform”. The wave is the most important Igor concept.
Igor was originally designed to deal with waveform data. A waveform typically consists of hundreds to 
thousands of values measured at evenly-spaced intervals of time. Such data is usually acquired from a 
digital oscilloscope, scientific instrument or analog-to-digital converter card.
The distinguishing trait of a waveform is the uniform spacing of its values along an axis of time or other quan-
tity. An Igor wave has an important property called “X scaling” that you set to specify the spacing of your 
data. Igor stores the Y component for each point of a wave in memory but it computes the X component based 
on the wave’s X scaling.
