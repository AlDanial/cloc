/**
 * @name Find unused variables
 * @description Finds local variables that are defined but never used.
 * @kind problem
 * @problem.severity warning
 */

import javascript

// Find all variable declarations
from Variable v, DeclStmt decl
where
  decl.getADecl().getBindingPattern() = v.getADeclaration() and
  not exists(VarAccess access | access.getVariable() = v) and
  not v.getName().matches("\\_%")
select v, "Variable '" + v.getName() + "' is declared but never used."
