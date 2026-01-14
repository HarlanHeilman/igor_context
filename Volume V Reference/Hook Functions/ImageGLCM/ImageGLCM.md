# ImageGLCM

ImageGLCM
V-375
Variable V_flag is set to 1 if the top graph contained draw objects in the correct layer and 0 if not. If 0 then 
the M_ROIMask wave was not generated.
Examples 
Make/O/N=(200,400) jack=x*y; NewImage jack; ShowTools
SetDrawLayer ProgFront
SetDrawEnv linefgc=(65535,65535,0),fillpat=0,xcoord=top,ycoord=left,save
DrawRect 63.5,79.5,140.5,191.5
DrawRRect 61.5,206.5,141.5,280.5
SetDrawEnv fillpat= -1
DrawOval 80.5,169.5,126.5,226.5
ImageGenerateROIMask jack
NewImage M_ROIMask
AutoPositionWindow/E
See Also
For another example see Generating ROI Masks on page III-378.
ImageGLCM
ImageGLCM [flags] srcWave
The ImageGLCM operation calculates the gray-level co-occurrence matrix for an 8-bit grayscale image and 
optionally evaluates Haralick's texture parameters.
The ImageGLCM operation was added in Igor Pro 7.00.
Flags
/D=distance
Sets the offset in pixels for which the co-occurrence matrix is calculated. The default 
value is 1.
/DEST=destGLCM
Specifies the wave to hold the co-occurrence matrix. If you omit /DEST the operation 
stores the matrix in the wave M_GLCM in the current data folder.
/DETP=destParamWave 
Specifies the wave to hold the computed texture parameters. If you omit /DETP the 
operation stores the texture parameters in the wave W_TextureParams in the current 
data folder.
If the destination wave already exists it is overwritten. Note that you must specify the 
/HTFP flag to compute the texture parameters.
/E=structureBits
structureBits is a bitwise setting that lets you control the combination of co-
occurrences that you want to compute.
Consider a wave displayed in a table and a pixel at position x
The structureBits corresponding to co-occurrence between x and any direction is 
simply 2^direction. By default the operation computes all combinations. This is 
equivalent to structureBits=255.
Note that the structureBits only define directions. The combination of the distance (/D) 
and the structureBits define the full co-occurrence calculation.
See Setting Bit Parameters on page IV-12 for details about bit settings.
0
3
5
1
x
6
2
4
7
0
3
5
1
x
6
2
4
7

ImageGLCM
V-376
Details
ImageGLCM computes the co-occurrence matrix for the image in srcWave and optionally evaluates 
Haralick's texture parameters. The operation supports 8-bit grayscale images and generates a 256x256 
single-precision floating point co-occurrence matrix.
The elements of the matrix P[i][j] are defined as the normalized number of pixels that have a spatial 
relationship defined by the distance (/D) and the structure (/E) such that the first pixel has gray-level i and 
the second pixel has gray-level j. The matrix is normalized so that the sum of all its elements is 1.
If you specify the /HTFP flag the operation computes the 13 Haralick texture parameters and stores them 
sequentially in the destination wave (see /DETP). The wave is saved with dimension labels defining each 
element. The expressions for the texture parameters are:
/FREE
Creates output waves as free waves.
/FREE is permitted in user-defined functions only, not from the command line or in 
macros.
If you use /FREE then destGLCM and destParamWave must be simple names, not paths.
See Free Waves on page IV-91 for details on free waves.
/HTFP
Computes Haralick's texture parameters. See the discussion in the Details section 
below for more information about the texture parameters.
/P=plane
If the image consists of more than one plane you can use this flag to determine which 
plane in srcWave is analysed. By default it is plane zero.
/Z
No error reporting.
f1 =
p[i][ j]
(
)
2 ,
j∑
i∑
f1 =
p[i][ j]
(
)
2 ,
j∑
i∑
f2 =
n2
p[i][ j]
j=0
i−j =n
255
∑
i=0
255
∑
⎧
⎨⎪
⎩⎪
⎫
⎬⎪
⎭⎪
n=0
254
∑
,
f2 =
n2
p[i][ j]
j=0
i−j =n
255
∑
i=0
255
∑
⎧
⎨⎪
⎩⎪
⎫
⎬⎪
⎭⎪
n=0
254
∑
,
f3 =
(i −μx)( j −μy)p[i][ j]
σ xσ y
,
j∑
i∑
f3 =
(i −μx)( j −μy)p[i][ j]
σ xσ y
,
j∑
i∑
f4 =
(i −μ)2 p[i][ j],
j∑
i∑
f4 =
(i −μ)2 p[i][ j],
j∑
i∑
f5 =
1
1+ (i −j)2 p[i][ j],
j∑
i∑
f5 =
1
1+ (i −j)2 p[i][ j],
j∑
i∑
f6 =
ipx+y(i)
i∑
,
f6 =
ipx+y(i)
i∑
,

ImageGLCM
V-377
Here
f7 =
(i −f6)2 px+y(i)
i∑
,
f7 =
(i −f6)2 px+y(i)
i∑
,
f8 = −
px+y(i)
i∑
log px+y(i)
(
),
f8 = −
px+y(i)
i∑
log px+y(i)
(
),
f9 = −
p[i][ j]
j∑
i∑
log p[i][ j]
(
),
f10 = Variance px−y
(
),
f9 = −
p[i][ j]
j∑
i∑
log p[i][ j]
(
),
f10 = Variance px−y
(
),
f10 = Variance px−y
(
),
f11 =
px−y(i)log px−y(i)
(
)
i∑
,
f11 =
px−y(i)log px−y(i)
(
)
i∑
,
f12 =
f9 −HXY1
max HX,HY
(
),
f12 =
f9 −HXY1
max HX,HY
(
),
f13 =
1−exp −2 HXY 2 −f 9
(
)
(
).
f13 =
1−exp −2 HXY 2 −f 9
(
)
(
).
px(i) =
p[i][ j],
j∑
py( j) =
p[i][ j],
i∑
px(i) =
p[i][ j],
j∑
py( j) =
p[i][ j],
i∑
μx =
ipx(i),
i∑
μy =
ipy(i),
i∑
μ = (μx + μy) / 2.
μx =
ipx(i),
i∑
μy =
ipy(i),
i∑
μ = (μx + μy) / 2.
σ x =
1−μx
(
)
2 px(i)
i∑
,
σ y =
1−μy
(
)
2 py(i)
i∑
,
px+y(k) =
p[i][ j],
j
i+ j=k
∑
i∑
px+y(k) =
p[i][ j],
j
i+ j=k
∑
i∑
px−y(k) =
p[i][ j],
j
i−j =k
∑
i∑
px−y(k) =
p[i][ j],
j
i−j =k
∑
i∑
