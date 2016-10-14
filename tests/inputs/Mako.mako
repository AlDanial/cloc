## This is the test file for mako extenstion
## As Mako can be used as a template to render almost any other
## language we only count mako comments as comments.

<ol>
% for x in range(10):
    <!-- This is a HTML comment but will be counted -->
    <li>${strong(x)}</li>
% endfor
</ol>

<%def name="strong(x)">
  <strong>${x}</strong>
</%def>

## Result:
## Lines: 20
## Code: 9
## Comment: 8
## Blank: 3
