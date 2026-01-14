# HideIgorMenus

hermiteGauss
V-346
hermiteGauss 
hermiteGauss(n, x)
The hermiteGauss function returns the normalized Hermite polynomial of order n:
Here the normalization was chosen such that
where nm is the Kronecker symbol.
You can verify the Hermite-Gauss normalization using the following functions:
Function TestNormalization(order)
Variable order
Variable/G theOrder = order
// The integrand vanishes in double-precision outside [-30,30]
Print/D Integrate1D(hermiteIntegrand,-30,30,2)
End
Function HermiteIntegrand(inX)
Variable inX
NVAR n = root:theOrder
return HermiteGauss(n,inx)^2*exp(-inx*inx)
End
See Also
The hermite function.
hide 
#pragma hide = value
The hide pragma allows you to make a procedure file invisible.
See Also
The The hide Pragma on page IV-54 and #pragma.
HideIgorMenus 
HideIgorMenus [MenuNameStr [, MenuNameStr ]…
The HideIgorMenus operation hides the named built-in menus or, if none are explicitly named, hides all 
built-in menus in the menu bar.
The effect of HideIgorMenus is lost when a new experiment is opened. The state of HideIgorMenus is saved 
with the experiment.
User-defined menus are not hidden by HideIgorMenus unless attached to built-in menus and the menu 
definition uses the hideable keyword.
Parameters
Details
The optional menu names are in English and not abbreviated. This ensures that code developed for a 
localized version of Igor will run on all versions.
The built-in menus that can be shown or hidden (the Help menu can be hidden only on Windows) are those 
that appear in the menu bar:
MenuNameStr
The name of an Igor menu, like “File”, “Data”, or “Graph”.
Hn(x) =
1
π 2nn!
(−1)n exp x2
(
) d n
dxn exp −x2
(
).
e−x2Hn(x)H m(x)dx = δ mn,
−∞
∞
∫
