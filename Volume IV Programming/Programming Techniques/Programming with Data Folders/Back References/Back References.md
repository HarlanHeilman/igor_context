# Back References

Chapter IV-7 — Programming Techniques
IV-189
are prepared to adjust the number of digits they match in order to make the rest of the pattern match, 
(?>\d+) can only match an entire sequence of digits.
Atomic groups in general can of course contain arbitrarily complicated subpatterns, and can be nested. 
However, when the subpattern for an atomic group is just a single repeated item, as in the example above, 
a simpler notation, called a “possessive quantifier” can be used. This consists of an additional + character 
following a quantifier. Using this notation, the previous example can be rewritten as
\d++foo
or
Grep/E="\\d++foo"
Possessive quantifiers are always greedy; the setting of the PCRE_UNGREEDY option is ignored. They are 
a convenient notation for the simpler forms of atomic group. However, there is no difference in the meaning 
or processing of a possessive quantifier and the equivalent atomic group.
The possessive quantifier syntax is an extension to the Perl syntax. It originates in Sun’s Java package.
When a pattern contains an unlimited repeat inside a subpattern that can itself be repeated an unlimited 
number of times, the use of an atomic group is the only way to avoid some failing matches taking a very 
long time indeed. The pattern
(\D+|<\d+>)*[!?]
or
Grep/E="(\\D+|<\\d+>)*[!?]"
matches an unlimited number of substrings that either consist of nondigits, or digits enclosed in <>, fol-
lowed by either ! or ?. When it matches, it runs quickly. However, if it is applied to
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
it takes a long time before reporting failure. This is because the string can be divided between the internal \D+ 
repeat and the external * repeat in a large number of ways, and all have to be tried. (The example uses [!?] 
rather than a single character at the end, because both PCRE and Perl have an optimization that allows for fast 
failure when a single character is used. They remember the last single character that is required for a match, 
and fail early if it is not present in the string.) If the pattern is changed so that it uses an atomic group, like this:
((?>\D+)|<\d+>)*[!?]
or
Grep/E="((?>\\D+)|<\\d+>)*[!?]"
sequences of nondigits cannot be broken, and failure happens quickly.
Back References
Outside a character class, a backslash followed by a digit greater than 0 (and possibly further digits) is a 
back reference to a capturing subpattern earlier (that is, to its left) in the pattern, provided there have been 
that many previous capturing left parentheses.
However, if the decimal number following the backslash is less than 10, it is always taken as a back refer-
ence, and causes an error only if there are not that many capturing left parentheses in the entire pattern. In 
other words, the parentheses that are referenced need not be to the left of the reference for numbers less 
than 10. See Backslash and Nonprinting Characters on page IV-179 for further details of the handling of 
digits following a backslash.
A back reference matches whatever actually matched the capturing subpattern in the current subject string, 
rather than anything matching the subpattern itself (see Subpatterns as Subroutines on page IV-194 for a 
way of doing that). So the pattern
(sens|respons)e and \1ibility or /E="(sens|respons)e and \\1ibility"
matches “sense and sensibility” and “response and responsibility”, but not “sense and responsibility”. If 
caseful matching is in force at the time of the back reference, the case of letters is relevant. For example,
((?i)rah)\s+\1
or
Grep/E="((?i)rah)\\s+\\1"
matches “rah rah” and “RAH RAH”, but not “RAH rah”, even though the original capturing subpattern is 
matched caselessly.
