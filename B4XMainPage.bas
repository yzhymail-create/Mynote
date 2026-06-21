B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
'Ctrl + click to export as zip: ide://run?=&File=%B4X%\Zipper.jar&Args=Project.zip
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Public Note_View As NoteView
	Public MP As B4XMainPage
	Public PageData As B4XPageData   'Page to show the xCustomListview with the data (Página para añadir el xCLV con los datos)
	Public Search_str As Search
	Public Sync_Action As Synchorize
	Public Psw As Psw_Page
	Public Gpsw As Gpsw_page
	Public Login As Login_Page
	Public Register As Regist_Page
	Public etPass As B4XView
	Public etUser As B4XView
	Public check_in As Boolean = False
	Private btnLogin As Button
	
	Public  EncDec As AESEncryption
	Public User_Name As String
	
	Public Modify_Flag = False As Boolean
	Public Regist_New_Flag = False As Boolean
	Public BntHome_Flag = False As Boolean
	Public KVS As KeyValueStore
	Public jRDC As jRDC2
	Public Const PlusChar As String = Chr(0xF067) '+ char for the title bar 
	Public Const SearChar As String = Chr(0xF002)'search bar
	Public SQL1 As SQL
	Public const getEvents As String = "Select * FROM events WHERE  year = ? And month = ? And id_user = ? order by RowID desc"
	Public const updateEvents As String = "UPDATE events SET event_type = ?,description = ?,value = ?,timestamp = ?,changed = ? WHERE RowID = ?"
	Public const deleteEvents As String  = "DELETE FROM events WHERE rowid = ?"
	Public const addEvents As String = "INSERT INTO events VALUES (?,?,?,?,?,?,?,?,?,?,?)"
	Public const addPsw As String = "INSERT INTO psw VALUES (?,?,?,?,?,?,?,?,?,?,?)"
	Public const sycEvents As String = "UPDATE events SET event_type = ?,description = ?,value = ?,timestamp = ?,sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
	Public const sycPsw As String = "UPDATE psw SET description = ?,username = ?,password = ?,email = ?,remark= ?,timestamp = ?,sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
	Public const searchEvents As String = "Select * FROM events WHERE  id_user = ? order by rowid desc"

	Private BntForget As B4XView
End Sub

'You can add more parameters here.
Public Sub Initialize
	B4XPages.GetManager.LogEvents = True
	jRDC.Initialize
	xui.SetDataFolder("mynote")
	EncDec.InitializationVector = "Q.6qYq0_C+mGmymX" 'Must be 16 characters in length
	EncDec.SecretKey = "3hba8fOumOPrMG0.G?-mkF-scGOkPwyW" 'Must be 16 or 32 characters in length

	KVS.Initialize(xui.DefaultFolder,"kvs") 'We use KVS to save the logged user (Usaremos KVS para guardar el usuario que inicia sesión)
'	If File.Exists(xui.DefaultFolder, "notesql.db") = True Then
'		
'		File.Copy(File.DirAssets, "notesql.db", xui.DefaultFolder, "notesql.db")
'	End If
	'copy the default DB
	'Log (xui.DefaultFolder)
	If File.Exists(xui.DefaultFolder, "notesql.db") = False Then
		If File.Exists(File.DirAssets, "notesql.db") = True Then 
		  File.Copy(File.DirAssets, "notesql.db", xui.DefaultFolder, "notesql.db")
	    Else
	#If B4J
	SQL1.InitializeSQLite(xui.DefaultFolder, "notesql.db", True)
	#Else
		SQL1.Initialize(xui.DefaultFolder, "notesql.db", True)
	#End If
		SQL1.ExecNonQuery _
		("CREATE TABLE events (id_user TEXT , month TEXT, event_type TEXT,description TEXT,value TEXT,year TEXT,time TEXT  PRIMARY KEY,timestamp TEXT,sync_flag BOOLEAN,new BOOLEAN,changed BOOLEAN)")
		SQL1.ExecNonQuery("CREATE TABLE users (id_user TEXT PRIMARY KEY, password TEXT,name TEXT,nickname TEXT,level INTEGRE,active BOOLEAN)")
		SQL1.ExecNonQuery("CREATE TABLE psw (id_user TEXT ,description TEXT,username TEXT,password TEXT,email TEXT,remark TEXT,time TEXT  PRIMARY KEY,timestamp TEXT,sync_flag BOOLEAN,new BOOLEAN,changed BOOLEAN)")
		SQL1.ExecNonQuery("CREATE TABLE delevents (id_user TEXT , deltime TEXT)")
		SQL1.ExecNonQuery("CREATE TABLE delPSW (id_user TEXT , delpsw TEXT)")
	End If
	Else
  		#If B4J
		SQL1.InitializeSQLite(xui.DefaultFolder, "notesql.db", True)
	#Else
		SQL1.Initialize(xui.DefaultFolder, "notesql.db", True)
	#End If
  End If
  
	'Log (xui.DefaultFolder)
	'initialize the database

'	SQL1.ExecNonQuery("CREATE TABLE IF NOT EXISTS 'psw' ( `id_user` TEXT,`description` TEXT,`password` TEXT,`time` TEXT,`timestamp` TEXT, `sync_flag` Boolean,`new` Boolean,`changed` Boolean)")
'	SQL1.ExecNonQuery("CREATE TABLE IF NOT EXISTS 'delpsw' ( `delpsw` TEXT)")


End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("Login")
	B4XPages.SetTitle(Me,"LOGIN")
    Register.Initialize
	B4XPages.AddPage("Regist_Page",Register)
	Login.Initialize
	B4XPages.AddPage("login_Page",Login)
	PageData.Initialize
	B4XPages.AddPage("B4XPageData", PageData)
	Note_View.Initialize
	B4XPages.AddPage("NoteView", Note_View)
	Search_str.Initialize
	B4XPages.AddPage("Search", Search_str)
	Sync_Action.Initialize
	B4XPages.AddPage("synchorize",Sync_Action)
	Psw.Initialize
	B4XPages.AddPage("Psw_Page",Psw)
	Gpsw.Initialize
	B4XPages.AddPage("Gpsw_page",Gpsw)



End Sub

Private Sub B4XPage_Appear

	
If KVS.ContainsKey("user") And BntHome_Flag= False Then  'If we've logged before, go directly to PageData
		User_Name = KVS.Get("user")
		B4XPages.ShowPageAndRemovePreviousPages("Login_Page")
	Else
		User_Name = ""
		BntHome_Flag= False
'		xui.MsgboxAsync("Please login !","LOGIN")

End If

End Sub

#if B4J
Private Sub btnLogin_MouseClicked (EventData As MouseEvent)
#else
Private Sub btnLogin_Click
#end if
	'this code is for local
	Dim name As String = etUser.Text.Trim
	Dim ps As String = etPass.Text.Trim
	ps = EncDec.AESEncrypt(ps)
	Dim Quary As String = "SELECT * FROM users WHERE nickname = ? and password = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(Quary,Array As String(name,ps))
	Do While rs.NextRow
		Dim id As String = rs.GetString("id_user")
		check_in = True
	Loop
	If check_in  =  True Then
		User_Name = name
		KVS.Put("user", name)
		KVS.Put("id_user", id)
		B4XPages.ShowPageAndRemovePreviousPages("B4XPageData")

	Else
		xui.MsgboxAsync("Wrong name or password ！", "Error")
	End If
	'the next code is for jrdc
'	'B4XPages.MainPage.Toast.Show("Checking user and password...")
'	Dim Parametros() As String = Array As String(etUser.Text.Trim, etPass.Text.Trim)
'	Wait For(jRDC.GetRecord("Login", Parametros)) Complete (Answer As Map)
'	If Answer.Get("Success") Then
'		Dim l As List
'		Dim rs As DBResult
'		rs = Answer.Get("Data")
'		l = rs.Rows
'		If l.Size > 0 Then 'We get a result
'			Dim UserData As List
'			For Each row() As Object In l
'				UserData = row
'			Next
'			'Save the user name and id to build the sql queries
'			'Guardamos el nombre de usuario y el id para construir las sentencias sql
'			KVS.Put("user", etUser.Text.Trim)
'			KVS.Put("id_user", UserData.Get(0))
'			B4XPages.ClosePage(Me)
'			B4XPages.ShowPage("B4XPageData")
'		Else
'			xui.MsgboxAsync("Wrong sername or password", "Error")
'		End If
'	Else
'		xui.MsgboxAsync("Problem connecting: " & Answer.Get("Error"), "Error")
'	End If
End Sub



Sub etPass_TextChanged (Old As String, New As String)
	btnLogin.Enabled = New.Length > 0
End Sub

Sub txtUser_EnterPressed
	'If btnLogin.Enabled Then btnLogin_Click
End Sub


Private Sub Bntmodify_Click
	Dim name As String = etUser.Text.Trim
	Dim ps As String = etPass.Text.Trim
	ps = EncDec.AESEncrypt(ps)
	Dim Quary As String = "SELECT * FROM users WHERE nickname = ? and password = ?"
	Dim rs As ResultSet = SQL1.ExecQuery2(Quary,Array As String(name,ps))
	Do While rs.NextRow
		check_in = True
	Loop
	If check_in = True Then
		Modify_Flag = True
		B4XPages.ShowPageAndRemovePreviousPages("Regist_Page")
	Else
		xui.MsgboxAsync("No name or password !","ERROR")
	End If
End Sub

Private Sub Bntregist_Click
	Regist_New_Flag = True
	B4XPages.ShowPageAndRemovePreviousPages("Regist_Page")
End Sub




Private Sub ForgetPassword_Click
	xui.MsgboxAsync("Please send email to yzhy-mail@163.com to get help !","HELP!")
End Sub