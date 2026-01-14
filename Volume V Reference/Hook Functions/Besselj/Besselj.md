# Besselj

Base64Encode
V-46
Example
String encodedString = "SWdvciBpcyBncmVhdCE="
Print Base64Decode(encodedString)
 Igor is great!
See Also
Base64Encode, URLRequest
Base64Encode
Base64Encode(inputStr)
The Base64Encode function returns a copy of inputStr encoded as Base64. 
The algorithm used to encode Base64-encoded data is defined in RFC 4648 
(http://www.ietf.org/rfc/rfc4648.txt).
For an explanation of Base64 encoding, see https://en.wikipedia.org/wiki/Base64.
The Base64Encode function was added in Igor Pro 8.00.
Example
String theString = "Igor is great!"
Print Base64Encode(theString)
 SWdvciBpcyBncmVhdCE=
See Also
Base64Decode, URLRequest
Beep 
Beep
The Beep operation plays the current alert sound (Macintosh) or the system beep sound (Windows).
Besseli 
Besseli(n,z)
The Besseli function returns the modified Bessel function of the first kind, In(z), of order n and argument z. 
Replaces the bessI function, which is supported for backwards compatibility only.
If z is real, Besseli returns a real value, which means that if z is also negative, it returns NaN unless n is an integer.
For complex z a complex value is returned, and there are no restrictions on z except for possible overflow.
Details
The calculation is performed using the SLATEC library. The function supports fractional and negative 
orders n, as well as real or complex arguments z.
See Also
The Besselj, Besselk, and Bessely functions.
Besselj 
Besselj(n,z)
The Besselj function returns the Bessel function of the first kind, Jn (z), of order n and argument z. Replaces 
the bessJ function, which is supported for backwards compatibility only.
If z is real, Besselj returns a real value, which means that if z is also negative, it returns NaN unless n is an integer.
For complex z a complex value is returned, and there are no restrictions on z except for possible overflow.
Details
The calculation is performed using the SLATEC library. The function supports fractional and negative 
orders n, as well as real or complex arguments z.
See Also
The Besseli, Besselk, and Bessely functions.
