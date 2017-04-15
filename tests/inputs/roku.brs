REM cut/paste from https://sdkdocs.roku.com/display/sdkdoc/Program+Statements#ProgramStatements-REM
Dim c[5, 4, 6]
For x = 1 To 5
    For y = 1 To 4
        For z = 1 To 6
            c[x, y, z] = k
            k = k + 1
        End for
    End for
End for
' a comment
rem another one 
k=0
For x = 1 To 5
    For y = 1 To 4
        For z = 1 To 6
            If c[x, y, z] <> k Then print"error" : Stop
            If c[x][y][z] <> k Then print "error": Stop
            k = k + 1
        End for
    End for
End for
