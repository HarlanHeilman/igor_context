# HCluster Vector Dissimilarity Calculation Methods for Boolean Data

Chapter III-7 — Analysis
III-165
Like Hamming, Jaccard is intended for boolean data, but tests for "not equal".
HCluster Vector Dissimilarity Calculation Methods for Boolean Data
The remaining metrics are for boolean data. Any data is accepted and each value is converted to a boolean 
value by testing for uj != 0.
The following definitions are used:
D is the vector length, 
.
dm = Yule
dm = Dice
dm = RogersTanimoto
dm = RusselRao
dm = SokalSneath
dm = Kulsinski
d(u, v) =
|{j|uj ̸= vj}|
|{j|uj ̸= 0 or vj ̸= 0}|
a = |{j | uj ∧vj}|
b = |{j | uj ∧(¬vj)}|
c = |{j | (¬uj) ∧vj}|
d = |{j | (¬uj) ∧(¬vj)}|
D = a + b + c + d
d (u, v) =
2bc
ad + bc
d (u, v) =
b + c
2a + b + c , d (0, 0) = 0
d (u, v) = 2 (b + c)
b + c + D
d (u, v) = b + c + d
D
d (u, v) =
2(b + c)
a + 2(b + c) , d(0, 0) = 0
d (u, v) = 1
2 ·

b
a + b +
c
a + c
