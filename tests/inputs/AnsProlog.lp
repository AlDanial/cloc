% ASP logic program for cloc tests.
% Demonstrates the use of different types of comments in .lp files.
%
% There should be:
% 18 lines of comments
% 12 lines of whitespace (one inside a multi-line comment)
% 19 lines of code
%
% There are 49 total lines.
%

% This is a single line comment
baz(X) :- bar(X).   % This counts as a line of code

    % This is a slightly more indented single line comment
foo(X) :- baz(X).   % This counts as a line of code as well.

bar(a).

% Here are some choice rules and cardinality rules.
1 { bar(b); bar(c); bar(d) } 3.
1 { garply(X) : foo(X) } 2.

allow(a).
allow(b).
allow(c).

% conditional rule
conditional(X) :-
     garply(X);
     foo(X) : allow(X).

weight(1) :- conditional(a).
weight(2) :- conditional(b).
weight(3) :- conditional(c).
weight(4) :- conditional(d).


%* This is a multi-line comment with one whitespace line in it
quux(X) :- foo(X).  % This shouldn't be counted as it is in a multi-line comment.
this is a line inside a comment

*%

#minimize {
    X@0: weight(X)
}.

#show garply/1.
