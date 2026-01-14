# CopyDimLabels

CopyDimLabels
V-103
Use circular convolution for the case where the data in srcWaveName and destWaveName are considered to 
endlessly repeat (or “wrap around” from the end back to the start), which means no zero padding is needed.
Use acausal convolution when the source wave contains an impulse response where the middle point of 
srcWave corresponds to no delay (t = 0).
See Also
Convolution on page III-284 for illustrated examples. MatrixOp.
References 
A very complete explanation of circular and linear convolution can be found in sections 2.23 and 2.24 of 
Rabiner and Gold, Theory and Application of Digital Signal Processing, Prentice Hall, 1975.
CopyDimLabels
CopyDimLabels [flags] srcWave, destWave, [destWave]...
The CopyDimLabels operation copies dimension labels from the source wave to the destination wave or 
waves.
CopyDimLabels was added in Igor Pro 8.00.
Support for multiple destination waves was added in Igor Pro 9.00.
Flags
In the following flags, dim is 0 for the rows dimension, 1 for the columns dimension, 2 for the layers 
dimension, and 3 for the chunks dimension.
Details
If you omit all flags, CopyDimLabels copies all dimension labels in srcWave to the corresponding dimension 
labels of destWave for dimensions that exist in destWave.
You can use /ROWS, /COLS, /LAYR and /CHNK to copy dimension labels from any existing source wave 
dimension into any existing destination wave dimension. For example, to copy the column dimension 
labels of wave1 into the row dimension labels of wave2 use:
CopyDimLabels /COLS=0 wave1, wave2
To copy the column dimension labels of wave1 into the layer dimension labels of wave2 and the row 
dimension labels of wave1 into the column dimension labels of wave 2 use:
CopyDimLabels /COLS=2 /ROWS=1 wave1, wave2
If the source dimension has N elements and the destination dimension has M>N elements then only the first 
N dimension labels are set in the destination. The remaining dimension labels in the destination are 
unchanged.
If the source dimension has N elements and the destination dimension has M<N elements then only the first 
M dimension labels are copied from the source to the destination.
It is an error to attempt to copy dimension labels to a non-existent dimension in the destination.
See Also
FindDimLabel, GetDimLabel, SetDimLabel, Dimension Labels on page II-93 
/ROWS=dim
Copies the row dimension labels of srcWave into the destWave dimension specified by 
dim.
/COLS=dim
Copies the column dimension labels of srcWave into the destWave dimension specified 
by dim.
/LAYR=dim
Copies the layer dimension labels of srcWave into the destWave dimension specified by 
dim. 
/CHNK=dim
Copies the chunk dimension labels of srcWave into the destWave dimension specified 
by dim.
