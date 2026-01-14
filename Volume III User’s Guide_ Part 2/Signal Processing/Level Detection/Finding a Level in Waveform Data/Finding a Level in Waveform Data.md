# Finding a Level in Waveform Data

Chapter III-9 — Signal Processing
III-288
A related, but different question is “given a function y = f(x), find x where y is zero (or some other value)”. 
This question is answered by the FindRoots operation. See Finding Function Roots on page III-338, and the 
FindRoots operation on page V-248.
The following sections pertain to detecting level crossings in data that varies irregularly. The operations 
discussed are not designed to detect peaks; see Peak Measurement on page III-290.
Finding a Level in Waveform Data
You can use the FindLevel operation (see page V-242) to find a single level crossing, or the FindLevels oper-
ation (see page V-244) to find multiple level crossings in waveform data. Both of these operations can option-
ally smooth the waves they search to reduce the effects of noise. A subrange of the data can be searched, by 
either ascending or descending X values, depending on the startX and endX values you supply to the opera-
tion’s /R flag.
FindLevel locates the first level crossing encountered in the search range, starting at startX and proceeding 
toward endX until a level crossing is found. The search is performed sequentially. The outputs of FindLevel 
are two special numeric variables: V_Flag and V_LevelX. V_Flag indicates the success or failure of the 
search (0 is success), and V_LevelX contains the X coordinate of the level crossing.
For example, given the following data:
the command:
FindLevel/R=(-0.5,0.5) signal,0.30
prints this level crossing information into the history area:
0.6
0.4
0.2
0.0
-0.2
1.0
0.5
0.0
-0.5
-1.0
level
V_LevelX
endX
1. search starts here,
at startX
2. search toward endX 
for location where signal 
crosses level.
3. FindLevel ﬁnds crossing
at x=V_LevelX
