@{
    ' VB.NET code in a vbhtml file
    ViewBag.Title = "Test Page"
    Dim message As String = "Hello from VB.NET"
}

<!DOCTYPE html>
<html>
<head>
    <title>@ViewBag.Title</title>
</head>
<body>
    <h1>@message</h1>
    @If True Then
        @<p>This is a VB.NET HTML template</p>
    End If
</body>
</html>