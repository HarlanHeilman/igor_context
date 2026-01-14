# Quantifier Greediness

Chapter IV-7 — Programming Techniques
IV-187
•
A back reference (see Back References on page IV-189)
•
A parenthesized subpattern (unless it is an assertion)
The general repetition quantifier specifies a minimum and maximum number of permitted matches, by 
giving the two numbers in braces, separated by a comma. The numbers must be less than 65536, and the 
first must be less than or equal to the second. For example:
z{2,4}
matches “zz”, “zzz”, or “zzzz”.
If the second number is omitted, but the comma is present, there is no upper limit; if the second number 
and the comma are both omitted, the quantifier specifies an exact number of required matches. Thus
[aeiou]{3,}
matches at least 3 successive vowels, but may match many more, while
\d{8}
matches exactly 8 digits. A left brace that appears in a position where a quantifier is not allowed, or one that 
does not match the syntax of a quantifier, is taken as a literal character. For example, {,6} is not a quanti-
fier, but a literal string of four characters.
Quantifiers apply to characters rather than to individual data units. Thus, for example, \x{100}{2} matches 
two characters, each of which is represented by a two-byte sequence in a UTF-8 string. Similarly, \X{3} 
matches three Unicode extended grapheme clusters, each of which may be several data units long (and they 
may be of different lengths).
The quantifier {0} is permitted, causing the expression to behave as if the previous item and the quantifier 
were not present.
For convenience (and historical compatibility) the three most common quantifiers have single-character 
abbreviations:
It is possible to construct infinite loops by following a subpattern that can match no characters with a quan-
tifier that has no upper limit, for example:
(a?)*
Earlier versions of Perl and PCRE used to give an error at compile time for such patterns. However, because 
there are cases where this can be useful, such patterns are now accepted, but if any repetition of the subpat-
tern does in fact match no characters, the loop is forcibly broken.
Quantifier Greediness
By default, the quantifiers are “greedy”, that is, they match as much as possible (up to the maximum number of 
permitted times), without causing the rest of the pattern to fail. The classic example of where this gives problems 
is in trying to match comments in C programs. These appear between /* and */ and within the comment, indi-
vidual * and / characters may appear. An attempt to match C comments by applying the pattern
/\*.*\*/
or
Grep/E="/\\*.*\\*/"
to the string
/* first comment */ not comment /* second comment */
fails because it matches the entire string owing to the greediness of the .* item.
*
Equivalent to {0,}
+
Equivalent to {1,}
?
Equivalent to {0,1}
