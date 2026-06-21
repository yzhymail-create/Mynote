B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private MP As B4XMainPage
	Private ser As B4XSerializator
	Private btnSend As B4XView
	Private btnConnect As B4XView
	Private connected As Boolean
	Private client As Socket
	Public server As ServerSocket
	Private astream As AsyncStreams
	Private const PORT As Int = 51042
	Private working As Boolean = True
	Private lblStatus As B4XView
	Private lblMyIp As B4XView
	Private txtIP As B4XFloatTextField
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private mm As MyMessage

	Private My_Finish_Flag As Boolean = False

	Private Finish_Flag As Boolean = False
	Private Process_Flag As Boolean = False

	Private AnotherProgressBar1 As AnotherProgressBar
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	server.Initialize(PORT, "server")
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root.LoadLayout("sycview")
	MP = B4XPages.MainPage
	For Each txt As B4XFloatTextField In Array(txtIP)
		txt.LargeLabelTextSize = 15
		txt.SmallLabelTextSize = 12
		txt.Update
	Next

	UpdateState(False)
	AnotherProgressBar1.Visible = True
	B4XLoadingIndicator1.Hide
End Sub

private Sub B4XPage_appear
	
	ListenForConnections
End Sub

 Sub Check_Data
	Dim TX_new_flag As Boolean = False
	Dim TX_changed_flag As Boolean = False
	Dim TX_del_flag As Boolean = False
	
	Dim PS_new_flag As Boolean = False
	Dim PS_changed_flag As Boolean = False
	Dim PS_del_flag As Boolean = False
	Dim Query As String=""
	mm.Initialize
	mm.TX_newlist.Initialize
	mm.TX_changedlist.Initialize
	mm.TX_dellist.Initialize
	mm.PS_newlist.Initialize
	mm.PS_changedlist.Initialize
	mm.PS_dellist.Initialize
	mm.State_Flag.Initialize
	Dim Rs As ResultSet
	Dim id_user As String = MP.KVS.Get("id_user")
	mm.id_user = MP.KVS.Get("id_user")
	Dim l As List
	'get new data
	 Query  = "SELECT * FROM events WHERE id_user = ? AND new = ?"
	Rs = MP.SQL1.ExecQuery2(Query, Array As String (id_user,True))
	Do While Rs.NextRow 
		l.Initialize
		l.AddAll(Array As String (Rs.GetString("id_user"),Rs.GetString("month"),Rs.GetString("event_type"), _
		Rs.GetString("description"),Rs.GetString("value"),Rs.GetString("year"),Rs.GetString("time"), _ 
		Rs.GetString("timestamp"),True,False,False))
		mm.TX_newlist.Add(l)
	Loop
	Rs.Close
	If mm.TX_newlist.Size > 0 Then TX_new_flag =  True
	mm.State_Flag.Put("TX_new_flag",TX_new_flag)
	'ABOUT PASSWORD
	Query  = "SELECT * FROM psw WHERE id_user = ? AND new = ?" 
	Rs = MP.SQL1.ExecQuery2(Query, Array As String (id_user,"true"))
	Do While Rs.NextRow
		l.Initialize
		l.AddAll(Array As String (Rs.GetString("id_user"),Rs.GetString("description"),Rs.GetString("username"),Rs.GetString("password"),Rs.GetString("email"),Rs.GetString("remark"),Rs.GetString("time"),Rs.GetString("timestamp"),True,False,False))
		mm.PS_newlist.Add(l)
	Loop
	Rs.Close
	If mm.PS_newlist.Size > 0 Then PS_new_flag =  True
	mm.State_Flag.Put("PS_new_flag",PS_new_flag)
	
	'get changed data
	Query  = "SELECT * FROM events WHERE id_user = ? AND changed = ?"
	Rs = MP.SQL1.ExecQuery2(Query, Array As String (id_user,True))
	Do While Rs.NextRow
		l.Initialize
		l.AddAll(Array As String(Rs.GetString("event_type"), _
		Rs.GetString("description"),Rs.GetString("value"), _ 
		Rs.GetString("timestamp"),Rs.GetString("time"), _ 
		True,False,False,Null))
		mm.TX_changedlist.Add(l )
	Loop
	Rs.Close
	If mm.TX_changedlist.Size > 0 Then TX_changed_flag =  True
	mm.State_Flag.Put("TX_changed_flag",TX_changed_flag)
	
	'ABOUT PASSWORD
	Query  = "SELECT * FROM psw WHERE id_user = ? AND changed = ?" 
	Rs = MP.SQL1.ExecQuery2(Query, Array As String (id_user,True))
	Do While Rs.NextRow
		l.Initialize
		l.AddAll(Array As String(Rs.GetString("description"),Rs.GetString("username"),Rs.GetString("password"),Rs.GetString("email"),Rs.GetString("remark"), _
		Rs.GetString("timestamp"),Rs.GetString("time"), _ 
		True,False,False,Null))
		mm.PS_changedlist.Add(l)
	Loop
	Rs.Close
	If mm.PS_changedlist.Size > 0 Then PS_changed_flag =  True
	mm.State_Flag.Put("PS_changed_flag",PS_changed_flag)
	
'get deleted data
	Query  = "SELECT * FROM delevents WHERE id_user = ?"  
	Rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user))
	Do While Rs.NextRow 
		l.Initialize
		l.AddAll(Array As String(Rs.GetString("id_user"),Rs.GetString("deltime")))
		mm.TX_dellist.Add(l)
	Loop
		
	Rs.Close
	If mm.TX_dellist.Size > 0 Then TX_del_flag =  True
	mm.State_Flag.Put("TX_del_flag",TX_del_flag)
	'ABOUT PSSWORD
	Query  = "SELECT * FROM delpsw WHERE id_user = ?" 
	Rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user))
	Do While Rs.NextRow
		l.Initialize
		l.AddAll(Array As String(Rs.GetString("id_user"),Rs.GetString("delpsw")))
		mm.PS_dellist.Add(l)
	Loop
	Rs.Close
	If mm.PS_dellist.Size > 0 Then PS_del_flag =  True
	mm.State_Flag.Put("PS_del_flag",PS_del_flag)

End Sub


 Sub ListenForConnections
	Do While working
		server.Listen
		Wait For Server_NewConnection (Successful As Boolean, NewSocket As Socket)
		If Successful Then
			CloseExistingConnection
			client = NewSocket
			astream.InitializePrefix(client.InputStream, False, client.OutputStream, "astream")
			UpdateState(True)
		End If
	Loop
End Sub

 Sub CloseExistingConnection
	If astream.IsInitialized Then astream.Close
	If client.IsInitialized Then client.Close
	UpdateState (False)
End Sub

 Sub AStream_Error
	UpdateState(False)
End Sub

 Sub AStream_Terminated
	UpdateState(False)
End Sub

  Sub UpdateState (NewState As Boolean)
	connected = NewState
	btnSend.Enabled = connected
	If connected Then
		btnConnect.Text = "Disconnect"
		lblStatus.Text = "Connected"
	Else
		btnConnect.Text = "Connect"
		lblStatus.Text = "Disconnected"
	End If
	lblMyIp.Text = "My ip: " & server.GetMyIP
End Sub

Sub AStream_NewData (Buffer() As Byte)                '//get the data from other device
	Dim TX_new_flag As Boolean = False
	Dim TX_changed_flag As Boolean = False
	Dim TX_del_flag As Boolean = False
	
	Dim PS_new_flag As Boolean = False
	Dim PS_changed_flag As Boolean = False
	Dim PS_del_flag As Boolean = False
	
	Dim Paremeters As String
	Dim tem_time As String
	
	Dim Query As String
	Dim rs As ResultSet
	Dim mm_get As MyMessage = ser.ConvertBytesToObject(Buffer)
	Dim id_user As String = MP.KVS.Get("id_user")
	TX_new_flag  = mm_get.State_Flag.Get("TX_new_flag")
	TX_changed_flag  = mm_get.State_Flag.Get("TX_changed_flag")
	TX_del_flag  = mm_get.State_Flag.Get("TX_del_flag")
	
	PS_new_flag  = mm_get.State_Flag.Get("PS_new_flag")
	PS_changed_flag  = mm_get.State_Flag.Get("PS_changed_flag")
	PS_del_flag  = mm_get.State_Flag.Get("PS_del_flag")
	Finish_Flag = mm_get.Finish_Flag
	Process_Flag = mm_get.Process_Flag

	    'get the answer then refresh db and delete the element of del.db
		If Finish_Flag = True Then
					'refresh the event.db,set the flag 
					Query = "SELECT rowid FROM events WHERE id_user = ? AND sync_flag = ?"
					rs = MP.SQL1.ExecQuery2(Query,Array As String (id_user,False))
		            Query ="UPDATE events SET sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
					Do While rs.NextRow
						Paremeters = rs.GetInt2(0)
			            Dim tem_arr() As String = Array As String (True,False,False,rs.GetInt2(0))
						MP.SQL1.ExecNonQuery2(Query,tem_arr)
					Loop
					rs.Close
				'ABOUT PASSORD
		        Query = "SELECT rowid FROM psw WHERE  id_user = ? AND sync_flag = ?"
				rs = MP.SQL1.ExecQuery2(Query,Array As String (id_user,False))
		        Query ="UPDATE psw SET sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
				Do While rs.NextRow
					Paremeters = rs.GetInt2(0)
			        Dim tem_arr() As String = Array As String (True,False,False,rs.GetInt2(0))
					MP.SQL1.ExecNonQuery2(Query,tem_arr)
				Loop
		        rs.Close		
		     My_Finish_Flag = True
		Else
		     My_Finish_Flag = False
		End If		
			'check the answer data
	If TX_new_flag =  True Or TX_changed_flag = True Or TX_del_flag = True  Then
					B4XLoadingIndicator1.Show
					'delete the specile data
		             If TX_del_flag =  True Then
			           Query  = "SELECT * FROM events WHERE  id_user = ? AND time = ?"
						For i = 0 To mm_get.TX_dellist.Size-1
				            Dim l As List = mm_get.TX_dellist.Get(i)
				            Dim  tem(l.size) As String
						    For j = 0 To  l.Size-1
								tem(j) = l.Get(j)
				             Next
							rs = MP.SQL1.ExecQuery2(Query,tem)
							Do While rs.NextRow				
					             MP.SQL1.ExecNonQuery2(MP.deleteEvents,Array As String (rs.GetInt2(0)))
							Loop
							rs.Close	
						Next
					End If
			'refresh the data which has been changed
					If TX_changed_flag = True Then	
				        Dim time1 As Long = 0
				        Dim time2 As Long = 0
						Dim time As String = ""
				        
			            Query  = "SELECT rowid FROM events WHERE  id_user = ? AND time = ?"
						For i = 0 To mm_get.TX_changedlist.Size-1
				        Dim re_data As List 
						re_data.Initialize
				        re_data = mm_get.TX_changedlist.Get(i) 
							tem_time = re_data.Get(4)
							rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user,tem_time))
							Do While rs.NextRow
						      Paremeters = rs.GetInt2(0)
					          time1  = re_data.Get(3)
						      Query = "SELECT timestamp from events WHERE RowID = ?"  
					           time2  =  MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Paremeters))
							  'check the data which is old
						     If time1 > time2 Then
						        time = re_data.Get(3)
'						        Dim tem_arr() As String = Array As String (re_data(0),re_data(1),re_data(2),time,re_data(5),re_data(6),re_data(7),rs.GetInt2(0))				     
						        Dim tem_arr() As String = Array As String (re_data.get(0),re_data.get(1),re_data.get(2),time,re_data.get(5),re_data.get(6),re_data.get(7),rs.GetInt2(0))

								 MP.SQL1.ExecNonQuery2(MP.sycEvents,tem_arr)
						     End If
							Loop
							rs.Close
						Next
					End If
					
					'insert new data
					If TX_new_flag = True Then 			            
						For i = 0 To mm_get.TX_newlist.size-1
							Dim l As List = mm_get.TX_newlist.Get(i)
							Dim  tem(l.size) As String
							For j = 0 To  l.Size-1
								tem(j) = l.Get(j)
							Next
				            MP.SQL1.ExecNonQuery2(MP.addEvents,tem)
		            Next
				  End If
		End If
		'ABOUT PASSWORD
		If PS_new_flag =  True Or PS_changed_flag = True Or PS_del_flag = True  Then
			'delete the specile data
			If PS_del_flag =  True Then
			    Query  = "SELECT rowid FROM delpsw WHERE  id_user = ? AND delpsw = ?"
				For i =0 To mm_get.PS_dellist.Size-1
					tem_time  = mm_get.PS_dellist.Get(i)
					rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user,tem_time))
					Do While rs.NextRow
						Paremeters = rs.GetInt2(0)
						MP.SQL1.ExecNonQuery2("DELETE FROM delpsw WHERE rowid = ?" ,Array As String( Paremeters))
					Loop
					rs.Close
				Next
			End If
			'refresh the data which has been changed
			If PS_changed_flag = True Then
				Dim time1 As Long = 0
				Dim time2 As Long = 0
				Dim time As String = ""
				
			    
				For i = 0 To mm_get.PS_changedlist.Size - 1
'				    Dim re_data() As String = mm_get.PS_changedlist.Get(i)
				    Dim re_data As List
				     re_data.Initialize
				     re_data = mm_get.PS_changedlist.Get(i)

					tem_time = re_data.get(6)
				    Query  = "SELECT rowid FROM psw WHERE  id_user = ? AND time = ?"
					rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user,tem_time))
					Do While rs.NextRow
						Paremeters = rs.GetInt2(0)
						time1  = re_data.get(5)
						Query = "SELECT timestamp from psw WHERE RowID = ?"  
					    time2  =  MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Paremeters))
						'check the data which is old
						If time1 > time2 Then
							time = re_data.get(5)
						    Dim tem_arr() As String = Array As String (re_data.get(0),re_data.get(1),re_data.get(2),time,re_data.get(5),re_data.get(6),re_data.get(7),re_data.get(8),rs.GetInt2(0))
							MP.SQL1.ExecNonQuery2(MP.sycPsw,tem_arr)
						End If
					Loop
					rs.Close
				Next
			End If
					
			'insert new data
			If PS_new_flag = True Then
			
			For i = 0 To mm_get.PS_newlist.size-1
				Dim l As List = mm_get.PS_newlist.Get(i)
				Dim  tem(l.size) As String
				For j = 0 To  l.Size-1
					tem(j) = l.Get(j)
				Next
					MP.SQL1.ExecNonQuery2(MP.addPsw,tem)
				Next
			End If
			B4XLoadingIndicator1.Hide
		End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'	If TX_new_flag =  True Or TX_changed_flag = True Or TX_del_flag = True Or PS_new_flag =  True Or PS_changed_flag = True Or PS_del_flag = True Then
'		My_Finish_Flag = False
'	Else
'		My_Finish_Flag = True
'	End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''	
	   If My_Finish_Flag = False Then
			Check_Data
			AnotherProgressBar1.Value = 60
		    mm.Finish_Flag = True
			SendData (ser.ConvertObjectToBytes(mm))
			
	   Else IF Process_Flag = False And My_Finish_Flag = True Then
			'just return the flag
		mm.Initialize
		mm.TX_newlist.Initialize
		mm.TX_changedlist.Initialize
		mm.TX_dellist.Initialize
		mm.PS_newlist.Initialize
		mm.PS_changedlist.Initialize
		mm.PS_dellist.Initialize
		mm.State_Flag.Initialize
		mm.Finish_Flag = True
		mm.Process_Flag = True
		mm.State_Flag.Put("TX_new_flag",False)
		mm.State_Flag.Put("TX_changed_flag",False)
		mm.State_Flag.Put("TX_del_flag",False)
		mm.State_Flag.Put("PS_new_flag",False)
		mm.State_Flag.Put("PS_changed_flag",False)
		mm.State_Flag.Put("PS_del_flag",False)
	
		SendData (ser.ConvertObjectToBytes(mm))
	End If

	AnotherProgressBar1.Value = 80
		
If  My_Finish_Flag = True  Then
		'refresh the event.db
		Query = "SELECT rowid FROM events WHERE  id_user = ? AND sync_flag = ?"
		rs = MP.SQL1.ExecQuery2(Query,Array As String (id_user,True))
		Query ="UPDATE events SET sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
		Do While rs.NextRow
			Dim tem_arr() As String = Array As String (True,False,False,rs.GetInt2(0))
			MP.SQL1.ExecNonQuery2(Query,tem_arr)
		Loop
		rs.Close
		
		'clean the del.db
		Query  = "SELECT rowid FROM delevents WHERE id_user = ?"
		rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user))
		Query  ="DELETE FROM delevents WHERE rowid = ? "
		Do While rs.NextRow
			Paremeters = rs.GetInt2(0)
			MP.SQL1.ExecNonQuery2(Query , Array As String(Paremeters))
		Loop
		rs.Close
		'''''''''''''''''''''''''''
		'about password
		'refresh the db
		Query = "SELECT rowid FROM psw WHERE id_user = ? AND sync_flag = ?"
		rs = MP.SQL1.ExecQuery2(Query,Array As String (id_user,True))
		Query ="UPDATE psw SET sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
		Do While rs.NextRow
			Dim tem_arr() As String = Array As String (True,False,False,rs.GetInt2(0))
			MP.SQL1.ExecNonQuery2(Query,tem_arr)
		Loop
		rs.Close
		
		'clean the del.db
		Query  = "SELECT rowid FROM delpsw WHERE id_user = ?" 
		rs = MP.SQL1.ExecQuery2(Query,Array As String(id_user))
		Query  ="DELETE FROM delpsw WHERE rowid = ?"
		Do While rs.NextRow
			MP.SQL1.ExecNonQuery2(Query , Array As String(rs.GetInt2(0)))
		Loop
		rs.Close
		mm.Initialize
		mm.TX_newlist.Initialize
		mm.TX_changedlist.Initialize
		mm.TX_dellist.Initialize
		mm.State_Flag.Initialize
		mm.Finish_Flag = False
		mm.Process_Flag = False
		mm.State_Flag.Put("new_flag",False)
		mm.State_Flag.Put("changed_flag",False)
		mm.State_Flag.Put("del_flag",False)
		
		AnotherProgressBar1.Value = 100
		xui.MsgboxAsync("Finished", "OK")
	End If
 
 

End Sub


 Sub ConnectToServer(Host As String)
	Log("Trying to connect to: " & Host)
	CloseExistingConnection
	Dim client As Socket
	client.Initialize("client")
	client.Connect(Host, PORT, 10000)
	Wait For Client_Connected (Successful As Boolean)
	If Successful Then
		astream.InitializePrefix(client.InputStream, False, client.OutputStream, "astream")
		UpdateState (True)
	Else
		Log("Failed to connect: " & LastException)
	End If
End Sub

 Sub Disconnect
	CloseExistingConnection
End Sub


 Sub SendData (data() As Byte)
	If connected Then astream.Write(data)
End Sub



Private Sub btnConnect_Click
	If connected = False Then
		If txtIP.Text.Length = 0 Then
			xui.MsgboxAsync("Please enter the server ip address.", "")
			Return
		Else
			ConnectToServer(txtIP.Text)
		End If
	Else
		Disconnect
	End If
End Sub

 Sub btnSend_Click
	Check_Data
	AnotherProgressBar1.Value = 20
	SendData (ser.ConvertObjectToBytes(mm))
	AnotherProgressBar1.Value = 30
End Sub


Private Sub lblMyIp_Click
	
End Sub

