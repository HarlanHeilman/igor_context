# FPClustering

for-endfor
V-259
for-endfor 
for(<initialization>;<continuation test>;<update>)
<loop body>
endfor
A for-endfor loop executes the loop body code until the continuation test evaluates as false (zero) or until a 
break statement is executed in the body code. When the loop starts, the initialization expressions are 
evaluated once. For each iteration, the continuation test is evaluated at the beginning and the update 
expressions are evaluated at the end.
for(<type> varName : <wave>)
// Range-based for loop added in Igor Pro 9.00
<loop body>
endfor
A range-based for loop iterates over each element of a wave. The specified loop variable contains the value 
of the current wave element.
See Also
For Loop, Range-Based For Loop, break
for-var-in-wave 
for(<type> varName : <wave>)
// Range-based for loop added in Igor Pro 9.00
<loop body>
endfor
A range-based for loop iterates over each element of a wave. The specified loop variable contains the value 
of the current wave element.
See Also
Range-Based For Loop, For Loop, break
FPClustering 
FPClustering [flags] srcWave
The FPClustering operation performs cluster analysis using the farthest-point clustering algorithm. The 
input for the operation srcWave defines M points in N-dimensional space. Outputs are the waves 
W_FPCenterIndex and W_FPClusterIndex.
Flags
/CAC
Computes all the clusters specified by /MAXC.
/CM
Computes the center of mass for each cluster. The results are stored in the wave 
M_clustersCM in the current data folder. Each row corresponds to a single cluster 
with columns providing the respective dimensional components.
/DSO
Returns the distance map of srcWave in M_DistanceMap. No other output is 
generated and all other flags are ignores.
/DSO was added in Igor Pro 8.00.
The distance map is the Cartesian distance between any two rows in srcWave. The 
results are stored in the upper triangle of the double-precision output wave 
M_DistanceMap. The lower triangle is set to zero (results can be obtained by 
symmetry).
Each element of the distance map is given by:
M _ DistanceMaprc =
srcWave[r][i]−srcWave[c][i]
(
)
2
i=0
nCols−1
∑
