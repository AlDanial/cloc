' https://github.com/badcodes/vb6.git NextPage/JetCar.cls

VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "JetCar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

Option Explicit

Public Sub AddUrlList(params)
Dim l As Long
Dim pCount As Long

Dim fTmp As String

Do
fTmp = BuildPath(Environ$("temp"), "NextPage." & Int(Rnd(Time) * 1000 + 1))
Loop While PathExists(fTmp)

If PathExists(fTmp) Then Kill fTmp

Open fTmp For Output As #10

pCount = UBound(params)

For l = 0 To pCount
Print #10, params(l)
Next

Close #10

Shell BuildPath(App.Path, "NextPage.exe") & " " & fTmp, vbNormalFocus


'JetCarCatch.AddUrlList params
End Sub

Public Sub AddUrl(URL)


Dim fTmp As String
Do
fTmp = BuildPath(Environ$("temp"), "NextPage." & Int(Rnd(Time) * 1000 + 1))
Loop While PathExists(fTmp)
If PathExists(fTmp) Then Kill fTmp

Open fTmp For Output As #10
Print #10, URL
Close #10

Shell BuildPath(App.Path, "NextPage.exe") & " " & fTmp, vbNormalFocus

End Sub
