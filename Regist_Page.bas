B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
Sub Class_Globals
	
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private MP As B4XMainPage
	Private Dialog As B4XDialog
	Private LongTextTemplate As B4XLongTextTemplate

	Private Password11 As B4XFloatTextField
	Private Password21 As B4XFloatTextField
	Private UserName1 As B4XFloatTextField
	Private id_user As String
	Private Modify_id As String
    Private Modify_flag = False As Boolean
	Private ToastMessage As BCToast


    #if B4A
	Private IME As IME
    #end if
	

	Private bntUpdate As B4XView
	Private Bntok As B4XView
	Private pnlBottom As B4XView
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root.LoadLayout("Regist_Page")
	MP = B4XPages.MainPage
	B4XPages.SetTitle(Me, "注册新用户")
'	Dim cs As CSBuilder
'	cs.Initialize.Size(20).Typeface(Typeface.MONOSPACE)
'	cs.Append("").Image(LoadBitmap(File.DirAssets, "witmos.png"), 40dip, 40dip, False).Append(" 用户注册").Append(CRLF)
'	cs.PopAll
'	B4XPages.SetTitle(Me,cs)
	
	
	ToastMessage.Initialize(Root)
	LongTextTemplate.Initialize
	Dialog.Initialize (Root)

#if b4a
	IME.Initialize("IME")
#end if
	bntUpdate.Visible = False
	Bntok.Visible = False
End Sub

Private Sub B4XPage_Appear
	
	If MP.Modify_Flag = True Then
		Dim name As String = MP.etUser.Text.Trim
		Dim ps As String = MP.etPass.Text.Trim
		ps = MP.EncDec.AESEncrypt(ps)
		Dim Quary As String = "SELECT * FROM users WHERE nickname = ? and password = ?"
		Dim rs As ResultSet = MP.SQL1.ExecQuery2(Quary,Array As String(name,ps))
		Do While rs.NextRow
			Modify_id = rs.GetString("id_user")
		Loop
		rs.Close
	
		bntUpdate.Visible = True
		Bntok.Visible = False
		
	End If
	
	If MP.Regist_New_Flag = True Then
		bntUpdate.Visible = False
		Bntok.Visible = True
	End If
End Sub


Sub AddEntry As Boolean
	Private Query As String
	Private ResultSet1 As ResultSet
	Private username As String
	Private Password1 As String
	Private Password2 As String
	username = UserName1.Text
	Password1 = Password11.Text
	Password2 = Password21.Text
	'check if all dields are filled
	If  username = ""  Or Password1  = "" Or Password2= "" Then
		ToastMessage.Show("请填写完整！")	' confirmation for the user
		Return False
	End If
	
	If  Password1 <> Password2 Then
		ToastMessage.Show("密码信息不一致！")	' confirmation for the user
		Return False
	End If

	If Regex.IsMatch("^\d{4,}$", Password1) = False Then
		ToastMessage.Show("请设置不少于4位的数字密码！")
		Return False
	End If

'	If Password1.Length <> 6  Then
'		ToastMessage.Show("请填写六位密码！")	' confirmation for the user
'		Return False
'	End If

	
	'first we check if the entry already does exist
	Query = "SELECT * FROM users WHERE nickname = ?"
	ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (username))

	If ResultSet1.NextRow = True Then
		'if it exists show a message and do nothing else
		ToastMessage.Show("昵称用户已存在！")
		ResultSet1.Close
		Return False								'close the cursor, we don't it anymore
	Else
		'if not, add the entry
		'we use ExecNonQuery2 because it's easier, we don't need to take care of the data types
		'Get the regist date
		
		Password1 = MP.EncDec.AESEncrypt(Password1)
		
'		DateTime.DateFormat = "yyyy/MM/dd"
'		Regist_Date=DateTime.Date(DateTime.Now)
		DateTime.DateFormat = "yyyyMMdd"
		DateTime.TimeFormat = "HHmmss"				
		Dim id_user As String  = DateTime.Date(DateTime.Now) & DateTime.Time(DateTime.Now)		
		Query = "INSERT INTO users VALUES (?,?,?,?,?,?)"
		MP.SQL1.ExecNonQuery2(Query, Array As String(id_user,Password1,username,username,1,1))
		ResultSet1.Close
		Return True		
	End If
	   
End Sub

private Sub Modify
	Private Query As String
	Private ResultSet1 As ResultSet
	Private username As String
	Private Password1 As String
	Private Password2 As String

	username = UserName1.Text
	Password1 = Password11.Text
	Password2 = Password21.Text
	'check if all dields are filled
	If  username = ""  Or Password1  = "" Or Password2= "" Then
		ToastMessage.Show("请填写完整！")	' confirmation for the user
		Modify_flag = False
		Return
	End If
	
	If  Password1 <> Password2 Then
		ToastMessage.Show("密码信息不一致！")	' confirmation for the user
		Modify_flag = False
		Return
	End If

	If Regex.IsMatch("^\d{4,}$", Password1) = False Then
		ToastMessage.Show("请设置不少于4位的数字密码！")
		Modify_flag = False
		Return
	End If
 
	
'只能修改用户密码。同时处理KVS的存储信息清空。
	Query = "SELECT name FROM users WHERE id_user = ?"
	ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (Modify_id))
	'first we check if the entry already does exist

	If ResultSet1.NextRow = True Then
		'if it exists show a message and do nothing else
		
		Password1 = MP.EncDec.AESEncrypt(Password1)
		Query ="UPDATE users Set  name = ?, nickname = ?,password = ? WHERE id_user = ?"
		MP.SQL1.ExecNonQuery2(Query, Array As String(username,username,Password1,Modify_id))
		ResultSet1.Close
		
		'清除KVS存储的用户信息
		MP.KVS.Remove("user")
		MP.KVS.Remove("id_user")
		MP.etUser.Text = ""
		MP.etPass.Text = ""
		MP.check_in = False
		Modify_flag = True

	Else
		Modify_flag = False
		ResultSet1.Close
		
	End If
	
End Sub



Private Sub Bntok_Click
	If AddEntry = True Then
		ToastMessage.Show("完成注册，请登录！")	' confirmation for the user
		MP.etUser.Text = ""
		MP.etPass.Text = ""
		MP.check_in = False
		B4XPages.ShowPageAndRemovePreviousPages("MainPage")
'		B4XPages.ShowPage("MainPage")
	End If
End Sub


Private Sub bntHome_Click
	MP.etUser.Text = ""
	MP.etPass.Text = ""
	MP.check_in = False
	B4XPages.ShowPageAndRemovePreviousPages("MainPage")
End Sub

Private Sub bntUpdate_Click
	Modify
	If  Modify_flag = True Then
		Modify_flag = False
		ToastMessage.Show("密码已修改，请重新登录！")
		B4XPages.ShowPageAndRemovePreviousPages("MainPage")
	Else
		ToastMessage.Show("不能修改用户名称，请使用正确的用户名！")
	End If
	MP.etUser.Text = ""
	MP.etPass.Text = ""
	MP.check_in = False
'	B4XPages.ShowPageAndRemovePreviousPages("MainPage")
End Sub


#if B4A
Private Sub btnTerms_Click
	Dialog.Title = "隐私政策"
	
	Dim cs As CSBuilder
	Dim tem As String
	tem = File.ReadString(File.DirAssets, "privacy policy.txt")
	Sleep(50)
	LongTextTemplate.Text = tem
	cs.Initialize.Color(xui.Color_Blue).Typeface(Typeface.DEFAULT_BOLD).Size(13).Append(LongTextTemplate.text).PopAll
	LongTextTemplate.Text =cs
	LongTextTemplate.CustomListView1.DefaultTextBackgroundColor = xui.Color_Yellow
	Dim dlgWidth As Int = Max(240dip, Min(Root.Width - 24dip, 520dip))
	Dim dlgHeight As Int = Max(220dip, Min(Root.Height - 48dip, Root.Height * 0.75))
	LongTextTemplate.Resize(dlgWidth, dlgHeight)
	Dim sf As Object = Dialog.ShowTemplate(LongTextTemplate, "OK", "", "")
	Sleep(0)
	LongTextTemplate.CustomListView1.sv.ScrollViewOffsetY = 0
	Wait For (sf) Complete (Result As Int)
End Sub
#end if


#if b4j
Private Sub btnTerms_MouseClicked (EventData As MouseEvent)
	Dim tem As String
	tem = File.ReadString(File.DirAssets, "privacy policy.txt")
	Sleep(50)
	LongTextTemplate.Text = tem
	
	
	Dim dlgWidth As Int = Max(300dip, Min(Root.Width - 24dip, 640dip))
	Dim dlgHeight As Int = Max(260dip, Min(Root.Height - 48dip, Root.Height * 0.75))
	LongTextTemplate.Resize(dlgWidth, dlgHeight)
	LongTextTemplate.CustomListView1.DefaultTextBackgroundColor = xui.Color_Gray

	Dim sf As Object = Dialog.ShowTemplate(LongTextTemplate, "OK", "", "")
	Wait For (sf) Complete (Result As Int)
End Sub
#End If


Private Sub B4XPage_Disappear

End Sub




