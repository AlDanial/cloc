Attribute VB_Name = "Module1"
' VBA (Visual Basic for Applications) example
' This would typically be found in Excel, Word, or Access

Option Explicit

Sub HelloWorld()
    ' This is a VBA subroutine
    MsgBox "Hello from VBA!"
End Sub

Function AddNumbers(x As Integer, y As Integer) As Integer
    ' VBA function to add two numbers
    AddNumbers = x + y
End Function

Private Sub Worksheet_Change(ByVal Target As Range)
    ' Event handler - typical in VBA
    If Target.Address = "$A$1" Then
        Range("B1").Value = "Cell A1 was changed"
    End If
End Sub