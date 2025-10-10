Imports System
Imports System.Collections.Generic

' VB.NET example
Namespace HelloWorldApp
    Public Class Program
        Public Shared Sub Main(args As String())
            Console.WriteLine("Hello from VB.NET!")
            
            Dim numbers As New List(Of Integer)
            numbers.Add(1)
            numbers.Add(2)
            numbers.Add(3)
            
            For Each num As Integer In numbers
                Console.WriteLine($"Number: {num}")
            Next
        End Sub
        
        ' VB.NET method with modern syntax
        Public Function CalculateSum(values As List(Of Integer)) As Integer
            Return values.Sum()
        End Function
    End Class
End Namespace