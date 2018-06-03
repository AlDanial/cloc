// Taken from https://github.com/t-b/igor-unit-testing-framework/blob/master/procedures/unit-testing-comparators.ipf
// licensed under BSD

/// @class NEQ_VAR_DOCU
/// Tests two variables for inequality
/// @param var1    first variable
/// @param var2    second variable
static Function NEQ_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(EQUAL_VAR(var1, var2)) // do some stuff
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End
