# Conditional Subpatterns

Chapter IV-7 — Programming Techniques
IV-192
matches “foo” preceded by three digits that are not “999”. Notice that each of the assertions is applied inde-
pendently at the same point in the subject string. First there is a check that the previous three characters are 
all digits, and then there is a check that the same three characters are not “999”. This pattern does not match 
“foo” preceded by six characters, the first of which are digits and the last three of which are not “999”. For 
example, it doesn’t match “123abcfoo”. A pattern to do that is
(?<=\d{3}...)(?<!999)fooor
Grep/E="(?<=\\d{3}...)(?<!999)foo"
This time the first assertion looks at the preceding six characters, checking that the first three are digits, and 
then the second assertion checks that the preceding three characters are not “999”.
 Assertions can be nested in any combination. For example,
(?<=(?<!foo)bar)baz
matches an occurrence of “baz” that is preceded by “bar” which in turn is not preceded by “foo”, while
(?<=\d{3}(?!999)...)foo or Grep/E=" (?<=\\d{3}(?!999)...)foo"
is another pattern that matches “foo” preceded by three digits and any three characters that are not “999”.
Conditional Subpatterns
It is possible to cause the matching process to obey a subpattern conditionally or to choose between two 
alternative subpatterns, depending on the result of an assertion, or whether a previous capturing subpat-
tern matched or not. The two possible forms of conditional subpattern are
(?(condition)yes-pattern)
(?(condition)yes-pattern|no-pattern)
If the condition is satisfied, the yes-pattern is used; otherwise the no-pattern (if present) is used. If there are 
more than two alternatives in the subpattern, a compile-time error occurs.
There are three kinds of condition. If the text between the parentheses consists of a sequence of digits, the 
condition is satisfied if the capturing subpattern of that number has previously matched. The number must 
be greater than zero. Consider the following pattern, which contains nonsignificant white space to make it 
more readable and to divide it into three parts for ease of discussion:
( \( )?
[^()]+
(?(1) \) )
The first part matches an optional opening parenthesis, and if that character is present, sets it as the first 
captured substring. The second part matches one or more characters that are not parentheses. The third part 
is a conditional subpattern that tests whether the first set of parentheses matched or not. If they did, that is, 
if subject started with an opening parenthesis, the condition is true, and so the yes-pattern is executed and 
a closing parenthesis is required. Otherwise, since no-pattern is not present, the subpattern matches noth-
ing. In other words, this pattern matches a sequence of nonparentheses, optionally enclosed in parentheses.
If the condition is the string (R), it is satisfied if a recursive call to the pattern or subpattern has been made. At 
“top level”, the condition is false. This is a PCRE extension. Recursive patterns are described in the next section.
If the condition is not a sequence of digits or (R), it must be an assertion. This may be a positive or negative 
lookahead or lookbehind assertion. Consider this pattern, again containing nonsignificant white space, and 
with the two alternatives on the second line:
(?(?=[^a-z]*[a-z])
\d{2}-[a-z]{3}-\d{2} | \d{2}-\d{2}-\d{2})
The condition is a positive lookahead assertion that matches an optional sequence of nonletters followed by 
a letter. In other words, it tests for the presence of at least one letter in the subject. If a letter is found, the 
subject is matched against the first alternative; otherwise it is matched against the second. This pattern 
matches strings in one of the two forms dd-aaa-dd or dd-dd-dd, where aaa are letters and dd are digits.
