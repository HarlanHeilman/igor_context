# Dilogarithm

digamma
V-159
Make/O/C cInput=cmplx(sin(p/8), cos(p/8))
Make/O/C/N=0 cOutput
Differentiate/C cInput /D=cOutput 
Wave Parameters
Details
If the optional /D = destWave flag is omitted, then the wave is differentiated in place overwriting the original 
data.
When using a method that deletes points (/EP=1) with a multidimensional wave, deletion is not done if no 
dimension is specified.
When using an X wave, the X wave must match the Y wave data type (excluding the complex type flag) and 
it must be 1D with the number points matching the size of the dimension being differentiated. X waves are 
not used with integer source waves.
Differentiate/METH=1/EP=1 is the inverse of Integrate/METH=2, but Integrate/METH=2 is the 
inverse of Differentiate/METH=1/EP=1 only if the original first data point is added to the output wave.
Differentiate applied to an XY pair of waves does not check the ordering of the X values and doesn’t care about 
it. However, it is usually the case that your X values should be monotonic. If your X values are not monotonic, 
you should be aware that the X values will be taken from your X wave in the order they are found, which will 
result in random X intervals for the X differences. It is usually best to sort the X and Y waves using Sort.
See Also
The Integrate operation.
digamma 
digamma(x)
The digamma function returns the digamma, or psi function of x. This is the logarithmic derivative of the 
gamma function:
In complex expressions, x is complex, and digamma(x) returns a complex value.
Limited testing indicates that the accuracy is approximately 1 part in 1016, at least for moderately-sized 
values of x.
Dilogarithm
Dilogarithm(z)
Returns the Dilogarithm function for real or complex argument z. The dilogarithm is a special case of the 
polylogarithm defined by
The dilogarithm function was added in Igor Pro 7.00.
See Also
zeta
Note:
All wave parameters must follow yWave in the command. All wave parameter flags 
and type flags must appear immediately after the operation name.
/D=destWave
Specifies the name of the wave to hold the differentiated data. It creates destWave if it 
does not already exist or overwrites it if it exists.
/X=xWave
Specifies the name of the corresponding X wave.
Ψ(z) ≡d
dz ln Γ(z)
(
) = Γ'(z)
Γ(z) .
Li2(z) =
zk
k2
k=1
∞
∑
.
