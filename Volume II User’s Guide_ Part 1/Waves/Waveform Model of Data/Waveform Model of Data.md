# Waveform Model of Data

Chapter II-5 — Waves
II-62
Overview
We use the term “wave” to describe the Igor object that contains an array of numbers. Wave is short for 
“waveform”. The main purpose of Igor is to store, analyze, transform, and display waves.
Chapter I-1, Introduction to Igor Pro, presents some fundamental ideas about waves. Chapter I-2, Guided 
Tour of Igor Pro, is designed to make you comfortable with these ideas. In this chapter, we assume that you 
have been introduced to them.
This chapter focuses on one-dimensional numeric waves. Waves can have up to four dimensions and can 
store text data. Multidimensional waves are covered in Chapter II-6, Multidimensional Waves. Text waves 
are discussed in this chapter.
The primary tools for dealing with waves are Igor’s built-in operations and functions and its waveform assign-
ment capability. The built-in operations and functions are described in detail in Chapter V-1, Igor Reference.
This chapter covers:
•
waves in general
•
operations for making, killing and managing waves
•
setting and examining wave properties
•
waveform assignment
and other topics.
Waveform Model of Data
A wave consists of a number of components and properties. The most important are:
•
the wave name
•
the X scaling property
•
X units
•
an array of data values
•
data units
The waveform model of data is based on the premise that there is a straight-line mapping from a point 
number index to an X value or, stated another way, that the data is uniformly spaced in the X dimension. 
This is the case for data acquired from many types of scientific and engineering instruments and for math-
ematically synthesized data. If your data is not uniformly spaced, you can use two waves to form an XY 
pair. See XY Model of Data on page II-63.
A wave is similar to an array in a standard programming language like FORTRAN or C.
Index
Value
array0
0
3.74
1
4.59
2
4.78
3
5.89
4
5.66
Point 
Number
X value (s)
data value 
(V)
wave0
0
0
3.74
1
.001
4.59
2
.002
4.78
3
.003
5.89
4
.004
5.66
A wave
An array
