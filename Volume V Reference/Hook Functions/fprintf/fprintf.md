# fprintf

fprintf
V-260
Details
The input for FPClustering is a 2D wave srcWave which consists of M rows by N columns where each row 
represents a point in N-dimensional space. srcWave can contain only finite real numbers and must be of type 
SP or DP. The operation computes the clustering and produces the wave W_FPCenterIndex which contains 
the centers or “hubs” of the clusters. The hubs are specified by the zero-based row number in srcWave which 
contains the cluster center. In addition, the operation creates the wave W_FPClusterIndex where each entry 
maps the corresponding input point to a cluster index. By default, the operation continues to add clusters 
as long as the largest possible distance is greater than the average intercluster distance. You can also stop 
the processing when the operation has formed a specified number of clusters (see /MAXC).
The variable V_max contains the maximum distance between any element and its cluster hub.
It is possible that in some circumstances you can get slightly different clustering depending on your starting 
point. The default starting hub is row zero of srcWave but you can use the /SHUB flag to specify a different 
starting point.
FPClustering computes the Cartesian distance between points. As a result, if the scale of any dimension is 
significantly larger than other dimensions it might bias the clustering towards that dimension. To avoid this 
situation you can use the /NOR flag which normalizes each column to the range [0,1] and hence equalizes 
the weight of each dimension in the clustering process.
See Also
The KMeans operation.
References
Gonzalez, T., Clustering to minimize the maximum intercluster distance, Theoretical Computer Science, 38, 
293-306, 1985.
fprintf 
fprintf refNum, formatStr [, parameter]…
The fprintf operation prints formatted output to a text file.
Parameters
refNum is a file reference number from the Open operation used to open the file.
formatStr is the format string, as used by the printf operation.
parameter varies depending on formatStr.
Details 
If refNum is 1, fprintf will print to the history area instead of to a file, as if you used printf instead of fprintf. 
This useful for debugging purposes.
/INCD
Computes the inter-cluster distances. The result is stored in the current data folder in 
the wave M_InterClusterDistance, a 2D wave in which the [i][j] element contains the 
distance between cluster i and cluster j.
/MAXC=nClusters
Terminates the calculation when the number of clusters reaches the specified value. 
Note that this termination condition is sufficient but not necessary, i.e., the operation 
can terminate earlier if the farthest distance of an element from a hub is less than the 
average distance.
/MAXR=maxRad
Terminates the calculation when the maximum distance is less than or equal to maxRad.
/NOR
Normalizes the data on a column by column basis. The normalization makes each 
columns of the input span the range [0,1] so that even when srcWave contains columns 
that may be different by several orders of magnitude, the algorithm is not biased by a 
larger implied cartesian distance.
/Q
Don’t print information to the history area.
/SHUB=sHub
Specifies the row which is used as a starting hub number. By default the operation 
uses the first row in srcWave.
/Z
No error reporting.
