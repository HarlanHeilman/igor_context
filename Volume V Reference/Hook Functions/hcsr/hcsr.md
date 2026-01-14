# hcsr

hcsr
V-340
Parameter
If you specify /ITYP=Vectors or omit /ITYP, sourceWave is an N row x M column matrix containing N data 
vectors of length M in the rows. HCluster creates a vector dissimilarity matrix from this input using the 
distance calculation method specified by /LINK.
If you specify /ITYP=DMatrix, sourceWave is a square matrix of dissimilarities between data vectors. If you 
choose this format, you are responsible for computing the dissimilarities between vectors. If none of the 
vector dissimilarity metrics provided by the /DISS flag are suitable, or if you require more processing after 
computing dissimilarities, you can use this format.
Dendrogram Output Wave
The HCluster operation optionally produces a dendrogram output wave that can be used to create a 
dendrogram plot. See Dendrogram Wave Format on page III-167 for a description of the dendrogram 
output wave format.
Reference
The HCluster operation is based on code developed by Daniel Müllner. This reference gives details of the 
algorithm and the various distance and vector dissimilarity measures and node agglomeration methods:
Daniel Müllner, fastcluster: Fast Hierarchical, Agglomerative Clustering Routines for R and Python, 
Journal of Statistical Software, 53 (2013), no. 9, 1–18, http://www.jstatsoft.org/v53/i09/.
See Also
Hierarchical Clustering on page III-162
hcsr 
hcsr(cursorName [, graphNameStr])
The hcsr function returns the horizontal coordinate of the named cursor (A through J) in the coordinate 
system of the top (or named) graph’s X axis.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
The X axis used is the one that controls the trace on which the cursor is placed.
Examples
Variable xAxisValueAtCursorA = hcsr(A)
// not hcsr("A")
String str="A"
Variable xA= hcsr($str,"Graph0")
// $str is a name, too
See Also
The pcsr, qcsr, vcsr, xcsr, and zcsr functions.
Programming With Cursors on page II-321.
/DEST={dMatrixName, dendrodrogramName}
Specifies the output waves when you have specified /OTYP=Both.
dMatrixName and dendrodrogramName are names of waves to be created or 
overwritten, optionally preceded by data folder paths.
If you specify /OTYP=Both and omit /DEST, HCluster creates an output 
vector dissimilarity matrix named M_HCluster_Dissimilarity and an output 
dendrogram wave named M_HCluster_Dendrogram, both in the current 
data folder.
/O
If present, allows the destination waves specified by the /DEST flag to 
overwrite a pre-existing wave.
