// This is .NET Intermediate Language
// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

.assembly extern System.Console
{
  .publickeytoken = (B0 3F 5F 7F 11 D5 0A 3A )
  .ver 4:0:0:0
}
.assembly extern mscorlib { }
.assembly 'devdiv_815942_' {}
.assembly extern xunit.core {}

.class public Repro
{
    .method public static int32 Main() cil managed
    {
        .custom instance void [xunit.core]Xunit.FactAttribute::.ctor() = (
            01 00 00 00
        )
        // This testcase ensures that we correctly compare a double local
        // against a float const by converting the float const to double
        // instead of converting the local to float and losing precision
  
        .entrypoint
        .locals init (float64 V_1)
        ldc.i4.1
        conv.i8
        call       float64 [mscorlib]System.BitConverter::Int64BitsToDouble(int64)
        conv.r8
        stloc.0
        ldloc.0
        ldc.r4     0.0
        bne.un.s   PASS
        ldstr      "FAIL!"
        call       void [System.Console]System.Console::WriteLine(string)
        ldloc.0
        call       void [System.Console]System.Console::WriteLine(float64)
        ldc.i4.s   101
        ret
PASS:
        ldstr      "PASS!"
        call       void [System.Console]System.Console::WriteLine(string)
        ldc.i4.s   100
        ret
    }
}
