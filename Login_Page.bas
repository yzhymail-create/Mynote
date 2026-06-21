B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private MP As B4XMainPage
	Private Button1 As B4XView
	Private Button2 As B4XView
	Private Button3 As B4XView
	Private Button4 As B4XView
	Private Button5 As B4XView
	Private Button6 As B4XView
	Private Button7 As B4XView
	Private Button8 As B4XView
	Private Button9 As B4XView
	Private psw As String
	Private checkin As String
	Private Button10 As B4XView
	Private Button11 As B4XView
	Private Button12 As B4XView
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root.LoadLayout("login_view")
	MP = B4XPages.MainPage
	B4XPages.SetTitle(Me,"Login")
	RandomizeKeypad
	LoadExpectedPassword
	checkin = ""

End Sub

Private Sub B4XPage_Appear
	'User_Name is refreshed from KVS in MainPage, so reload expected password every time.
	LoadExpectedPassword
	checkin = ""
	RandomizeKeypad
End Sub

Private Sub LoadExpectedPassword
	Dim Quary As String = "SELECT password FROM users WHERE nickname = ? "
	Dim rs As ResultSet
	rs = MP.SQL1.ExecQuery2(Quary,Array As String(MP.User_Name))
	If rs.NextRow = True Then
		psw =  rs.GetString("password")
		psw = MP.EncDec.AESDecrypt(psw)
	Else
		xui.MsgboxAsync("Wrong name or password ！", "Error")
		MP.etPass.Text = ""
		MP.etUser.Text = ""
		MP.check_in = False
		B4XPages.ShowPageAndRemovePreviousPages("MainPage")
	End If
	rs.Close
End Sub

Private Sub RandomizeKeypad
	Dim Num As List
	Dim tem As Int
	Num.Initialize
	Num.Addall(Array As String(0,1,2,3,4,5,6,7,8,9))
	For Each btn As Button In Array(Button1, Button2, Button3,Button4, Button5, Button6,Button7, Button8, Button9,Button10, Button11, Button12)
		If Num.size <> 1 Then
			tem = Rnd(0,Num.size)
		Else
			tem = 0
		End If
		btn.Text = Num.Get(tem)
		If Num.size <> 1 Then
			Num.RemoveAt(tem)
		End If
	Next
End Sub


Private Sub Button12_Click
	checkin = checkin & Button12.text
End Sub

Private Sub Button11_Click
	checkin = checkin & Button11.text
End Sub

Private Sub Button10_Click
	checkin = checkin & Button10.text
End Sub

Private Sub Button9_Click
	checkin = checkin & Button9.text
End Sub

Private Sub Button8_Click
	checkin = checkin & Button8.text
End Sub

Private Sub Button7_Click
	checkin = checkin & Button7.text
End Sub

Private Sub Button6_Click
	checkin = checkin & Button6.text
End Sub

Private Sub Button5_Click
	checkin = checkin & Button5.text
End Sub

Private Sub Button4_Click
	checkin = checkin & Button4.text
End Sub

Private Sub Button3_Click
	checkin = checkin & Button3.text
End Sub

Private Sub Button2_Click
	checkin = checkin & Button2.text
End Sub

Private Sub Button1_Click
	checkin = checkin & Button1.text
End Sub

#if b4a	
Private Sub LOGIN_Click
#else if b4j
Private Sub Login_Click
#end if
		If checkin = psw Then
		checkin =""
		B4XPages.ShowPageAndRemovePreviousPages("B4XPageData")
	Else
		checkin =""
		
		'B4XPages.ShowPageAndRemovePreviousPages("MainPage")
		xui.MsgboxAsync("PASSWORD ERROR !","LOGIN")
	End If
End Sub

Private Sub B4XPage_Disappear
	RandomizeKeypad
	checkin = ""
End Sub



Private Sub Home_Click
	MP.etUser.Text = ""
	MP.etPass.Text = ""
	MP.check_in = False
	MP.BntHome_Flag= True
	B4XPages.ShowPage("MainPage")
End Sub