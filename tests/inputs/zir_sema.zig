// https://github.com/ziglang/zig/raw/master/src-self-hosted/zir_sema.zig
//
//! This file operates on a `Module` instance, transforming untyped ZIR
//! instructions into semantically-analyzed IR instructions. It does type
//! checking, comptime control flow, and safety-check generation. This is the
//! the heart of the Zig compiler.
//! When deciding if something goes into this file or into Module, here is a
//! guiding principle: if it has to do with (untyped) ZIR instructions, it goes
//! here. If the analysis operates on typed IR instructions, it goes in Module.

const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const Value = @import("value.zig").Value;
const Type = @import("type.zig").Type;
const TypedValue = @import("TypedValue.zig");
const assert = std.debug.assert;
const ir = @import("ir.zig");
const zir = @import("zir.zig");
const Module = @import("Module.zig");
const Inst = ir.Inst;
const Body = ir.Body;
const trace = @import("tracy.zig").trace;
const Scope = Module.Scope;
const InnerError = Module.InnerError;
const Decl = Module.Decl;

pub fn analyzeInst(mod: *Module, scope: *Scope, old_inst: *zir.Inst) InnerError!*Inst {
    switch (old_inst.tag) {
        .alloc => return analyzeInstAlloc(mod, scope, old_inst.castTag(.alloc).?),
        .alloc_inferred => return analyzeInstAllocInferred(mod, scope, old_inst.castTag(.alloc_inferred).?),
        .arg => return analyzeInstArg(mod, scope, old_inst.castTag(.arg).?),
        .bitcast_ref => return analyzeInstBitCastRef(mod, scope, old_inst.castTag(.bitcast_ref).?),
        .bitcast_result_ptr => return analyzeInstBitCastResultPtr(mod, scope, old_inst.castTag(.bitcast_result_ptr).?),
        .block => return analyzeInstBlock(mod, scope, old_inst.castTag(.block).?, false),
        .block_comptime => return analyzeInstBlock(mod, scope, old_inst.castTag(.block_comptime).?, true),
        .block_flat => return analyzeInstBlockFlat(mod, scope, old_inst.castTag(.block_flat).?, false),
        .block_comptime_flat => return analyzeInstBlockFlat(mod, scope, old_inst.castTag(.block_comptime_flat).?, true),
        .@"break" => return analyzeInstBreak(mod, scope, old_inst.castTag(.@"break").?),
        .breakpoint => return analyzeInstBreakpoint(mod, scope, old_inst.castTag(.breakpoint).?),
        .breakvoid => return analyzeInstBreakVoid(mod, scope, old_inst.castTag(.breakvoid).?),
        .call => return analyzeInstCall(mod, scope, old_inst.castTag(.call).?),
        .coerce_result_block_ptr => return analyzeInstCoerceResultBlockPtr(mod, scope, old_inst.castTag(.coerce_result_block_ptr).?),
        .coerce_result_ptr => return analyzeInstCoerceResultPtr(mod, scope, old_inst.castTag(.coerce_result_ptr).?),
        .coerce_to_ptr_elem => return analyzeInstCoerceToPtrElem(mod, scope, old_inst.castTag(.coerce_to_ptr_elem).?),
        .compileerror => return analyzeInstCompileError(mod, scope, old_inst.castTag(.compileerror).?),
        .@"const" => return analyzeInstConst(mod, scope, old_inst.castTag(.@"const").?),
        .dbg_stmt => return analyzeInstDbgStmt(mod, scope, old_inst.castTag(.dbg_stmt).?),
        .declref => return analyzeInstDeclRef(mod, scope, old_inst.castTag(.declref).?),
        .declref_str => return analyzeInstDeclRefStr(mod, scope, old_inst.castTag(.declref_str).?),
        .declval => return analyzeInstDeclVal(mod, scope, old_inst.castTag(.declval).?),
        .declval_in_module => return analyzeInstDeclValInModule(mod, scope, old_inst.castTag(.declval_in_module).?),
        .ensure_result_used => return analyzeInstEnsureResultUsed(mod, scope, old_inst.castTag(.ensure_result_used).?),
        .ensure_result_non_error => return analyzeInstEnsureResultNonError(mod, scope, old_inst.castTag(.ensure_result_non_error).?),
        .ensure_indexable => return analyzeInstEnsureIndexable(mod, scope, old_inst.castTag(.ensure_indexable).?),
        .ref => return analyzeInstRef(mod, scope, old_inst.castTag(.ref).?),
        .ret_ptr => return analyzeInstRetPtr(mod, scope, old_inst.castTag(.ret_ptr).?),
        .ret_type => return analyzeInstRetType(mod, scope, old_inst.castTag(.ret_type).?),
        .single_const_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.single_const_ptr_type).?, false, .One),
        .single_mut_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.single_mut_ptr_type).?, true, .One),
        .many_const_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.many_const_ptr_type).?, false, .Many),
        .many_mut_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.many_mut_ptr_type).?, true, .Many),
        .c_const_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.c_const_ptr_type).?, false, .C),
        .c_mut_ptr_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.c_mut_ptr_type).?, true, .C),
        .const_slice_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.const_slice_type).?, false, .Slice),
        .mut_slice_type => return analyzeInstSimplePtrType(mod, scope, old_inst.castTag(.mut_slice_type).?, true, .Slice),
        .ptr_type => return analyzeInstPtrType(mod, scope, old_inst.castTag(.ptr_type).?),
        .store => return analyzeInstStore(mod, scope, old_inst.castTag(.store).?),
        .str => return analyzeInstStr(mod, scope, old_inst.castTag(.str).?),
        .int => {
            const big_int = old_inst.castTag(.int).?.positionals.int;
            return mod.constIntBig(scope, old_inst.src, Type.initTag(.comptime_int), big_int);
        },
        .inttype => return analyzeInstIntType(mod, scope, old_inst.castTag(.inttype).?),
        .loop => return analyzeInstLoop(mod, scope, old_inst.castTag(.loop).?),
        .param_type => return analyzeInstParamType(mod, scope, old_inst.castTag(.param_type).?),
        .ptrtoint => return analyzeInstPtrToInt(mod, scope, old_inst.castTag(.ptrtoint).?),
        .fieldptr => return analyzeInstFieldPtr(mod, scope, old_inst.castTag(.fieldptr).?),
        .deref => return analyzeInstDeref(mod, scope, old_inst.castTag(.deref).?),
        .as => return analyzeInstAs(mod, scope, old_inst.castTag(.as).?),
        .@"asm" => return analyzeInstAsm(mod, scope, old_inst.castTag(.@"asm").?),
        .@"unreachable" => return analyzeInstUnreachable(mod, scope, old_inst.castTag(.@"unreachable").?, true),
        .unreach_nocheck => return analyzeInstUnreachable(mod, scope, old_inst.castTag(.unreach_nocheck).?, false),
        .@"return" => return analyzeInstRet(mod, scope, old_inst.castTag(.@"return").?),
        .returnvoid => return analyzeInstRetVoid(mod, scope, old_inst.castTag(.returnvoid).?),
        .@"fn" => return analyzeInstFn(mod, scope, old_inst.castTag(.@"fn").?),
        .@"export" => return analyzeInstExport(mod, scope, old_inst.castTag(.@"export").?),
        .primitive => return analyzeInstPrimitive(mod, scope, old_inst.castTag(.primitive).?),
        .fntype => return analyzeInstFnType(mod, scope, old_inst.castTag(.fntype).?),
        .intcast => return analyzeInstIntCast(mod, scope, old_inst.castTag(.intcast).?),
        .bitcast => return analyzeInstBitCast(mod, scope, old_inst.castTag(.bitcast).?),
        .floatcast => return analyzeInstFloatCast(mod, scope, old_inst.castTag(.floatcast).?),
        .elemptr => return analyzeInstElemPtr(mod, scope, old_inst.castTag(.elemptr).?),
        .add => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.add).?),
        .addwrap => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.addwrap).?),
        .sub => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.sub).?),
        .subwrap => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.subwrap).?),
        .mul => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.mul).?),
        .mulwrap => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.mulwrap).?),
        .div => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.div).?),
        .mod_rem => return analyzeInstArithmetic(mod, scope, old_inst.castTag(.mod_rem).?),
        .array_cat => return analyzeInstArrayCat(mod, scope, old_inst.castTag(.array_cat).?),
        .array_mul => return analyzeInstArrayMul(mod, scope, old_inst.castTag(.array_mul).?),
        .bitand => return analyzeInstBitwise(mod, scope, old_inst.castTag(.bitand).?),
        .bitnot => return analyzeInstBitNot(mod, scope, old_inst.castTag(.bitnot).?),
        .bitor => return analyzeInstBitwise(mod, scope, old_inst.castTag(.bitor).?),
        .xor => return analyzeInstBitwise(mod, scope, old_inst.castTag(.xor).?),
        .shl => return analyzeInstShl(mod, scope, old_inst.castTag(.shl).?),
        .shr => return analyzeInstShr(mod, scope, old_inst.castTag(.shr).?),
        .cmp_lt => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_lt).?, .lt),
        .cmp_lte => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_lte).?, .lte),
        .cmp_eq => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_eq).?, .eq),
        .cmp_gte => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_gte).?, .gte),
        .cmp_gt => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_gt).?, .gt),
        .cmp_neq => return analyzeInstCmp(mod, scope, old_inst.castTag(.cmp_neq).?, .neq),
        .condbr => return analyzeInstCondBr(mod, scope, old_inst.castTag(.condbr).?),
        .isnull => return analyzeInstIsNonNull(mod, scope, old_inst.castTag(.isnull).?, true),
        .isnonnull => return analyzeInstIsNonNull(mod, scope, old_inst.castTag(.isnonnull).?, false),
   // a comment
        .iserr => return analyzeInstIsErr(mod, scope, old_inst.castTag(.iserr).?),  // another comment
        .boolnot => return analyzeInstBoolNot(mod, scope, old_inst.castTag(.boolnot).?),
        .typeof => return analyzeInstTypeOf(mod, scope, old_inst.castTag(.typeof).?),
        .optional_type => return analyzeInstOptionalType(mod, scope, old_inst.castTag(.optional_type).?),
        .unwrap_optional_safe => return analyzeInstUnwrapOptional(mod, scope, old_inst.castTag(.unwrap_optional_safe).?, true),
        .unwrap_optional_unsafe => return analyzeInstUnwrapOptional(mod, scope, old_inst.castTag(.unwrap_optional_unsafe).?, false),
        .unwrap_err_safe => return analyzeInstUnwrapErr(mod, scope, old_inst.castTag(.unwrap_err_safe).?, true),
        .unwrap_err_unsafe => return analyzeInstUnwrapErr(mod, scope, old_inst.castTag(.unwrap_err_unsafe).?, false),
        .unwrap_err_code => return analyzeInstUnwrapErrCode(mod, scope, old_inst.castTag(.unwrap_err_code).?),
        .ensure_err_payload_void => return analyzeInstEnsureErrPayloadVoid(mod, scope, old_inst.castTag(.ensure_err_payload_void).?),
        .array_type => return analyzeInstArrayType(mod, scope, old_inst.castTag(.array_type).?),
        .array_type_sentinel => return analyzeInstArrayTypeSentinel(mod, scope, old_inst.castTag(.array_type_sentinel).?),
        .enum_literal => return analyzeInstEnumLiteral(mod, scope, old_inst.castTag(.enum_literal).?),
        .merge_error_sets => return analyzeInstMergeErrorSets(mod, scope, old_inst.castTag(.merge_error_sets).?),
        .error_union_type => return analyzeInstErrorUnionType(mod, scope, old_inst.castTag(.error_union_type).?),
        .anyframe_type => return analyzeInstAnyframeType(mod, scope, old_inst.castTag(.anyframe_type).?),
        .error_set => return analyzeInstErrorSet(mod, scope, old_inst.castTag(.error_set).?),
        .slice => return analyzeInstSlice(mod, scope, old_inst.castTag(.slice).?),
        .slice_start => return analyzeInstSliceStart(mod, scope, old_inst.castTag(.slice_start).?),
    }
}
