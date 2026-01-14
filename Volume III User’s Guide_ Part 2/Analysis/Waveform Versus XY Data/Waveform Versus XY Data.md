# Waveform Versus XY Data

Chapter III-7 — Analysis
III-108
Overview
Igor Pro is a powerful data analysis environment. The power comes from a synergistic combination of
•
An extensive set of basic built-in analysis operations
•
A fast and flexible waveform arithmetic capability
•
Immediate feedback from graphs and tables
•
Extensibility through an interactive programming environment
•
Extensibility through external code modules (XOPs and XFUNCs)
Analysis tasks in Igor range from simple experiments using no programming to extensive systems tailored 
for specific fields. Chapter I-2, Guided Tour of Igor Pro, shows examples of the former. WaveMetrics’ 
“Peak Measurement” procedure package is an example of the latter.
This chapter presents some of the basic analysis operations and discusses the more common analyses that 
can be derived from the basic operations. The end of the chapter shows a number of examples of using 
Igor’s programmability for “number crunching”.
Discussion of Igor Pro’s more specialized analytic capabilities is in chapters that follow.
See the WaveMetrics procedures, technical notes, and sample experiments that come with Igor Pro for more 
examples.
Analysis of Multidimensional Waves
Many of the analysis operations in Igor Pro operate on 1D (one-dimensional) data. However, Igor Pro 
includes the following capabilities for analysis of multidimensional data:
•
Multidimensional waveform arithmetic
•
Matrix math operations
•
The MatrixOp operation
•
Multidimensional Fast Fourier Transform
•
2D and 3D image processing operations
•
2D and 3D interpolation operations and functions
Some of these topics are discussed in Chapter II-6, Multidimensional Waves and in Chapter III-11, Image 
Processing. The present chapter focuses on analysis of 1D waves.
There are many analysis operations that are designed only for 1D data. Multidimensional waves do not appear 
in dialogs for these operations. If you invoke them on multidimensional waves from the command line or from 
an Igor procedure, Igor treats the multidimensional waves as if they were 1D. For example, the Histogram oper-
ation treats a 2D wave consisting of n rows and m columns as if it were a 1D wave with n*m rows. In some cases 
(e.g., WaveStats), the operation will be useful. In other cases, it will make no sense at all.
Waveform Versus XY Data
Igor is highly adapted for dealing with waveform data. In a waveform, data values are uniformly spaced 
in the X dimension. This is discussed under Waveform Model of Data on page II-62.
If your data is uniformly spaced, you can set the spacing using the SetScale operation. This is crucial 
because most of the built-in analysis operations and functions need to know this to work properly.
If your data is not uniformly spaced, you can represent it using an XY pair of waves. This is discussed under 
XY Model of Data on page II-63. Some of the analysis operations and functions in Igor can not handle XY 
pairs directly. To use these, you must either make a waveform representation of the XY pair or use Igor pro-
cedures that build on the built-in routines.
