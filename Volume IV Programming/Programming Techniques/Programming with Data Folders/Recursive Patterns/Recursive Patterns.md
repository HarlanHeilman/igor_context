# Recursive Patterns

Chapter IV-7 — Programming Techniques
IV-193
Regular Expression Comments
The sequence (?# marks the start of a comment that continues up to the next closing parenthesis. Nested paren-
theses are not permitted. The characters that make up a comment play no part in the pattern matching at all.
Recursive Patterns
Consider the problem of matching a string in parentheses, allowing for unlimited nested parentheses. 
Without the use of recursion, the best that can be done is to use a pattern that matches up to some fixed 
depth of nesting. It is not possible to handle an arbitrary nesting depth. Perl provides a facility that allows 
regular expressions to recurse (amongst other things). It does this by interpolating Perl code in the expres-
sion at runtime, and the code can refer to the expression itself. A Perl pattern to solve the parentheses 
problem can be created like this:
$re = qr{\( (?: (?>[^()]+) | (?p{$re}) )* \)}x;
The (?p{…}) item interpolates Perl code at runtime, and in this case refers recursively to the pattern in 
which it appears. Obviously, PCRE cannot support the interpolation of Perl code. Instead, it supports some 
special syntax for recursion of the entire pattern, and also for individual subpattern recursion.
The special item that consists of (? followed by a number greater than zero and a closing parenthesis is a 
recursive call of the subpattern of the given number, provided that it occurs inside that subpattern. (If not, 
it is a “subroutine” call, which is described in Subpatterns as Subroutines on page IV-194.) The special item 
(?R) is a recursive call of the entire regular expression.
For example, this PCRE pattern solves the nested parentheses problem (additional nonfunction whitespace 
has been added to separate the expression into parts):
\( ( (?>[^()]+) | (?R) )* \)
First it matches an opening parenthesis. Then it matches any number of substrings which can either be a 
sequence of nonparentheses, or a recursive match of the pattern itself (that is a correctly parenthesized sub-
string). Finally there is a closing parenthesis.
If this were part of a larger pattern, you would not want to recurse the entire pattern, so instead you could 
use this:
( \( ( (?>[^()]+) | (?1) )* \))
We have put the pattern into parentheses, and caused the recursion to refer to them instead of the whole 
pattern. In a larger pattern, keeping track of parenthesis numbers can be tricky. It may be more convenient 
to use named parentheses instead. For this, PCRE uses (?P>name), which is an extension to the Python 
syntax that PCRE uses for named parentheses (Perl does not provide named parentheses). We could rewrite 
the above example as follows:
(?P<pn> \( ( (?>[^()]+) | (?P>pn) )* \))
This particular example pattern contains nested unlimited repeats, and so the use of atomic grouping for 
matching strings of nonparentheses is important when applying the pattern to strings that do not match. 
For example, when this pattern is applied to
(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa()
it yields “no match” quickly. However, if atomic grouping is not used, the match runs for a very long time 
indeed because there are so many different ways the + and * repeats can carve up the subject, and all have 
to be tested before failure can be reported.
At the end of a match, the values set for any capturing subpatterns are those from the outermost level of the 
recursion at which the subpattern value is set. If you want to obtain intermediate values, a callout function 
can be used (see Subpatterns as Subroutines on page IV-194). If the pattern above is matched against
(ab(cd)ef)
the value for the capturing parentheses is “ef”, which is the last value taken on at the top level. If additional 
parentheses are added, giving
