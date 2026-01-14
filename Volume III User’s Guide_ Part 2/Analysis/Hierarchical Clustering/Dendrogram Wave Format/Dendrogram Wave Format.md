# Dendrogram Wave Format

Chapter III-7 — Analysis
III-167
linkMethod = weighted
There is no general expression for the dissimilarity between clusters as it depends on the order in which the 
clusters are merged. At each step, new dissimilarities are computed as:
linkMethod = centroid
This method is suitable only for use with the Euclidean dissimilarity metric.
where 
c indicates the centroid of a cluster.
linkMethod = median
This method is suitable only for use with the Euclidean dissimilarity metric.
assigns d(K,L) like the centroid method. When two clusters I and J are combined into a new cluster K, the 
average of centroids i and j give the new centroid k. Or,
linkMethod = ward
This method is suitable only for use with the Euclidean dissimilarity metric.
The Ward variance minimization algorithm
Dendrogram Wave Format
The HCluster operation optionally produces a dendrogram output wave that can be used to create a den-
drogram plot. This section describes the format of the dendrogram output wave.
The dendrogram wave contains all the information about the node pairs that are combined by HCluster, 
and the dissimilarity between the nodes. It also has a list of the indices into the original data in the order in 
which, for instance, labels should be drawn to avoid node connector lines that cross. The wave has four 
columns and N rows, where N is the number of original data vectors.
d(K, L) = |I| · d(I, L) + |J| · d(J, L)
|I| + |J|
d(K, L) = d(I, L) + d(J, L)
2
d(A, B) = ∥⃗cA −⃗cB∥
c
d(K, L) =

|I| · d(I, L)2 + |J| · d(J, L)2
|I| + |J|
−|I| · |J| · d(I, J)2
(|I| + |J|)2
d(K, L) =

d(I, L)2
2
+ d(J, L)2
2
−d(I, J)2
4
d(A, B) =

2 |A| |B|
|A| + |B| · ∥⃗cA −⃗cB∥
d(K, L) =

(|I| + |L|) · d(I, L)2 + (|J| + |L|) · d(J, L)2 −|L| · d(I, J)2
|I| + |J| + |L|
