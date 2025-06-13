package example.policy

import future.keywords.every

default valid := false # unless otherwise defined, valid is false

valid if { # valid is true if...
	count(violation) == 0 # there are zero violations.
}

violation contains msg if { # violation is true if...
    some i in input {
        # every item in input must have a "name" field
        not input[i].name;
        msg := sprintf("Item %d is missing a 'name' field", [i])
    }
}

violation contains msg if { # violation is true if...
    some i in input {
        # every item in input must have a numeric "value" field
        not input[i].value || not is_number(input[i].value);
        msg := sprintf("Item %d is missing a numeric 'value' field", [i])
    }
}