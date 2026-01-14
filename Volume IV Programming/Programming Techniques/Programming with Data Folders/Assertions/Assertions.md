# Assertions

Chapter IV-7 — Programming Techniques
IV-190
Back references to named subpatterns use the Python syntax (?P<name>). We could rewrite the above 
example as follows:
(?P<p1>(?i)rah)\s+(?P=p1)
or
Grep/E="(?P<p1>(?i)rah)\\s+(?P=p1)"
There may be more than one back reference to the same subpattern. If a subpattern has not actually been 
used in a particular match, any back references to it always fail. For example, the pattern
(a|(bc))\2
always fails if it starts to match “a” rather than “bc”. Because there may be many capturing parentheses in 
a pattern, all digits following the backslash are taken as part of a potential back reference number. If the 
pattern continues with a digit character, some delimiter must be used to terminate the back reference. An 
empty comment (see Regular Expression Comments on page IV-193) can be used.
A back reference that occurs inside the parentheses to which it refers fails when the subpattern is first used, 
so, for example, (a\1) never matches. However, such references can be useful inside repeated subpatterns. 
For example, the pattern
(a|b\1)+
or
Grep/E="(a|b\\1)+"
matches any number of a’s and also “aba”, “ababbaa” etc. At each iteration of the subpattern, the back ref-
erence matches the character string corresponding to the previous iteration. In order for this to work, the 
pattern must be such that the first iteration does not need to match the back reference. This can be done 
using alternation, as in the example above, or by a quantifier with a minimum of zero.
Assertions
An assertion is a test on the characters following or preceding the current matching point that does not actu-
ally consume any characters. The simple assertions coded as \b, \B, ^ and $ are described in Backslash 
and Simple Assertions on page IV-181.
More complicated assertions are coded as subpatterns. There are two kinds: those that look ahead of the 
current position in the subject string, and those that look behind it. An assertion subpattern is matched in 
the normal way, except that it does not cause the current matching position to be changed.
Assertion subpatterns are not capturing subpatterns, and may not be repeated, because it makes no sense to 
assert the same thing several times. If any kind of assertion contains capturing subpatterns within it, these are 
counted for the purposes of numbering the capturing subpatterns in the whole pattern. However, substring 
capturing is carried out only for positive assertions, because it does not make sense for negative assertions.
Lookahead Assertions
Lookahead assertions start with (?= for positive assertions and (?! for negative assertions. For example,
\w+(?=;)
or
Grep/E="\\w+(?=;)"
matches a word followed by a semicolon, but does not include the semicolon in the match, and
foo(?!bar)
matches any occurrence of “foo” that is not followed by “bar”. Note that the apparently similar pattern
(?!foo)bar
does not find an occurrence of “bar” that is preceded by something other than “foo”; it finds any occurrence 
of “bar” whatsoever, because the assertion (?!foo) is always true when the next three characters are 
“bar”. A lookbehind assertion is needed to achieve the other effect.
If you want to force a matching failure at some point in a pattern, the most convenient way to do it is with 
(?!) because an empty string always matches, so an assertion that requires there not to be an empty string 
must always fail.

Chapter IV-7 — Programming Techniques
IV-191
Lookbehind Assertions
Lookbehind assertions start with (?<= for positive assertions and (?<! for negative assertions. For exam-
ple,
(?<!foo)bar
does find an occurrence of “bar” that is not preceded by “foo”. The contents of a lookbehind assertion are 
restricted such that all the strings it matches must have a fixed length. However, if there are several alter-
natives, they do not all have to have the same fixed length. Thus
(?<=bullock|donkey)
is permitted, but
(?<!dogs?|cats?)
causes an error at compile time. Branches that match different length strings are permitted only at the top 
level of a lookbehind assertion. This is an extension compared with Perl (at least for 5.8), which requires all 
branches to match the same length of string. An assertion such as
(?<=ab(c|de))
is not permitted, because its single top-level branch can match two different lengths, but it is acceptable if 
rewritten to use two top-level branches:
(?<=abc|abde)
In some cases, the escape sequence \K (see above) can be used instead of a lookbehind assertion to get 
round the fixed-length restriction.
The implementation of lookbehind assertions is, for each alternative, to temporarily move the current posi-
tion back by the fixed width and then try to match. If there are insufficient characters before the current 
position, the match is deemed to fail.
PCRE does not allow the \C escape (which matches a single data unit) to appear in lookbehind assertions, 
because it makes it impossible to calculate the length of the lookbehind. The \X and \R escapes, which can 
match different numbers of data units, are also not permitted.
Atomic groups can be used in conjunction with lookbehind assertions to specify efficient matching at the 
end of the subject string. Consider a simple pattern such as
abcd$
when applied to a long string that does not match. Because matching proceeds from left to right, PCRE will look 
for each a in the subject and then see if what follows matches the rest of the pattern. If the pattern is specified as
^.*abcd$
the initial .* matches the entire string at first, but when this fails (because there is no following a), it backtracks 
to match all but the last character, then all but the last two characters, and so on. Once again the search for a 
covers the entire string, from right to left, so we are no better off. However, if the pattern is written as
^(?>.*)(?<=abcd)
or, equivalently, using the possessive quantifier syntax,
^.*+(?<=abcd)
there can be no backtracking for the .* item; it can match only the entire string. The subsequent lookbehind 
assertion does a single test on the last four characters. If it fails, the match fails immediately. For long 
strings, this approach makes a significant difference to the processing time.
Using Multiple Assertions
Several assertions (of any sort) may occur in succession. For example,
(?<=\d{3})(?<!999)foo
or
Grep/E="(?<=\\d{3})(?<!999)foo"
