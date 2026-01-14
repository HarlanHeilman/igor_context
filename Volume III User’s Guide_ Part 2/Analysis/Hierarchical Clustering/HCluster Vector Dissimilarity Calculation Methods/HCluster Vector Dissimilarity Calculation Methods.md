# HCluster Vector Dissimilarity Calculation Methods

Chapter III-7 — Analysis
III-163
The most common method for calculating vector dissimilarity is the Euclidean metric, the familiar 
square root of the summed squared differences of the vector elements. See HCluster Vector Dis-
similarity Calculation Methods on page III-163 for a description of the vector dissimilarity metrics 
offered by the HCluster operation.
If you use /ITYP=DMatrix, you can prepare your own dissimilarity matrix using whatever method 
you wish for measuring the dissimilarity between vectors. Your dissimilarity metric must return a 
positive number. Identical vectors, such as comparing a vector with itself, have a dissimilarity of 
zero.
•
The dissimilarity between a vector and a previously-determined cluster or between two previous-
ly-determined clusters
We call this a "linkage" calculation.
You specify how to calculate linkage using the HCluster /LINK flag.
See HCluster Linkage Calculation Methods on page III-166 dfor a description of the linkage cal-
culation methods offered by the HCluster operation. The linkage method that you choose can have 
a very strong effect on the resulting dendrogram.
HCluster Vector Dissimilarity Calculation Methods
You use the HCluster /DISS=dm flag to specify the dissimilarity metric between two data vectors. Our defi-
nitions of dissimilarity follows Python scipy.spatial.distance.pdist.
The following values are supported for the dm keyword. If you omit /DISS, HCluster defaults to the Euclid-
ean method.
dm = Euclidean
This is the usual way to measure the dissimilarity between two vectors, the two-norm or L2 norm. It is 
simply the Euclidean distance. This is the default.
dm = SquaredEuclidean
Just like Euclidean, but omits taking the square root. May be needed to reproduce some results from R or 
Python. Results in the same clustering as Euclidean, but exaggerates larger differences.
dm = SEuclidean
Standardized Euclidean. Euclidean distance in which the dimensions are scaled by Vj, which is usually the 
variance of the j-th element of all the vectors.
Specify a wave giving the Vj vector using the /VARW flag.
dm = Cityblock
Manhattan distance or L1 norm.
d(u, v) = ∥u −v∥2 =

j
(uj −vj)2
d(u, v) =

j
(uj −vj)2
d(u, v) =

j
(uj −vj)2/Vj
d(u, v) =

j
|uj −vj|

Chapter III-7 — Analysis
III-164
Cityblock gives the same value of 2 for vectors (0,2), (2,0), and (1,1). Euclidean distance gives a smaller 
value, sqrt(2), for the vector (1,1). This can affect the resulting clusters.
dm = Chebychev
Supremum or L∞ norm.
dm = Minkowski
The Lp norm.
The value of p is specified using the HCluster /P flag.
p = 1 makes Minkowski equivalent to Cityblock.
p = 2 makes Minkowski equivalent to Euclidean.
p = Inf makes Minkowski equivalent to Chebychev.
dm = Cosine
dm = Canberra
Terms in which uj = vj = 0 contribute 0 to the sum.
dm = BrayCurtis
Terms in which uj = vj = 0 contribute 0 to the sum.
In the following, the notation |{...}| indicates the count of true boolean values.
dm = Hamming
Hamming is actually intended to be used with binary data, but the definition will test a "1" and "2" as being 
different. See Matching below, which tests each vector element for uj != 0. For data that is all ones or zeroes, 
Hamming and Matching give the same results.
dm = Jaccard
d(u, v) = max
j
|uj −vj|
d(u, v) =

j
|uj −vj|p
1/p
d(u, v) = 1 −
⟨u, v⟩
∥u∥· ∥v∥= 1 −

j ujvj

j u2
j · 
j v2
j
d(u, v) =

j
|uj −vj|
|uj| + |vj|
d(u, v) =

j
|uj −vj|
|uj + vj|
d(u, v) = |{j|uj ̸= vj}|
