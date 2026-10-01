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
	Private B4XTable1 As B4XTable
	Private editCol As B4XTableColumn
	Private Gpsw As Gpsw_page
	Private Dialog As B4XDialog
	Private InputTemplate As B4XInputTemplate
	Private NameColumn(6) As B4XTableColumn
	#if b4a
	Private IME As IME
	Private toast As ToastMessageShow
	#end if
	Private cvs As B4XCanvas
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	#if b4a
	toast.Initialize("toast")
	toast.withButtonColor(xui.Color_Cyan)
	#end if
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("psw")
	'load the layout to Root
	Gpsw.Initialize
	B4XPages.AddPage("Gpsw_page",Gpsw)
	MP = B4XPages.MainPage
	B4XPages.SetTitle(Me,"PasswordNote")
	Dialog.Initialize(Root)
	Dialog.Title = "Edit"
	#if b4a
	IME.Initialize("IME")
	IME.AddHeightChangedEvent
	#End If

	NameColumn(0) = B4XTable1.AddColumn("Description", B4XTable1.COLUMN_TYPE_TEXT)
	NameColumn(1) = B4XTable1.AddColumn("Username", B4XTable1.COLUMN_TYPE_TEXT)
	NameColumn(2) = B4XTable1.AddColumn("Password", B4XTable1.COLUMN_TYPE_TEXT)
	NameColumn(3) = B4XTable1.AddColumn("Email", B4XTable1.COLUMN_TYPE_TEXT)
	NameColumn(4) = B4XTable1.AddColumn("Remark", B4XTable1.COLUMN_TYPE_TEXT)
	NameColumn(5) = B4XTable1.AddColumn("Edit", B4XTable1.COLUMN_TYPE_TEXT)
	
	editCol = NameColumn(5)
	editCol.Sortable = False
	editCol.Searchable = False
	editCol.Width = 200dip
	B4XTable1.RowHeight = 70dip
	B4XTable1.MaximumRowsPerPage = 20
	B4XTable1.NumberOfFrozenColumns = 1
	B4XTable1.BuildLayoutsCache(B4XTable1.MaximumRowsPerPage)
	For i = 1 To editCol.CellsLayouts.Size - 1
		Dim p As B4XView = editCol.CellsLayouts.Get(i)
		p.AddView(CreateButton("btnEdit", Chr(0xF044)), 5dip, 5dip, 60dip, 60dip)
		p.AddView(CreateButton("btnDelete", Chr(0xF00D)), 130dip, 5dip, 60dip, 60dip)
	Next
	
	LoadData
	
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 1dip, 1dip)
	cvs.Initialize(p)
	
End Sub


private Sub LoadData

	Dim Rs As ResultSet
	Dim id_user As String = MP.KVS.Get("id_user")
	Dim Data As List
	Data.Initialize
	Dim l As List 
	Rs = MP.SQL1.ExecQuery2(("SELECT * FROM psw WHERE id_user = ?"),Array As String(id_user))
	Do While Rs.NextRow
		l.Initialize
		l.AddAll(Array As String(Rs.GetString("description"),Rs.GetString("username"),Rs.GetString("password"),Rs.GetString("email"),Rs.GetString("remark"),""))
		Data.Add(l)
	Loop
	Rs.Close
	B4XTable1.SetData(Data)

End Sub


private Sub B4XTable1_DataUpdated
	Dim p As B4XView
	
	For i = 0 To B4XTable1.VisibleRowIds.Size - 1
		p  = editCol.CellsLayouts.Get(i + 1)

		p.GetView(1).Visible = B4XTable1.VisibleRowIds.Get(i) > 0
		p.GetView(2).Visible = p.GetView(1).Visible

	Next
#IF B4A
	Dim ShouldRefresh As Boolean
	For Each Column As B4XTableColumn In Array (NameColumn(0), NameColumn(1))
		Dim MaxWidth As Int
		For i = 0 To B4XTable1.VisibleRowIds.Size-1
			Dim pnl As B4XView = Column.CellsLayouts.Get(i)
			Dim lbl As B4XView = pnl.GetView(0)
			MaxWidth = Max(MaxWidth, cvs.MeasureText(lbl.Text, lbl.Font).Width + 10dip)
		Next
		If MaxWidth > Column.ComputedWidth Or MaxWidth < Column.ComputedWidth - 20dip Then
			Column.Width = MaxWidth + 5dip
			ShouldRefresh = True
		End If
	Next
	If ShouldRefresh Then
		B4XTable1.Refresh
	End If
	#END IF
End Sub



Private Sub ShowDialog(Item As Map, RowId As Long)
	If Item.IsInitialized = False Then Item.Initialize
	Wait For (CollectDialogInput(Item)) Complete (InputResult As Boolean)
	If InputResult = False Then Return

	Dim id_user As String = MP.KVS.Get("id_user")
	Dim timestamp As String = DateTime.Now
	Dim NowTime As String = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
	Dim tem_email As String = Item.GetDefault("Email", "")
	Dim tem_remark As String = Item.GetDefault("Remark", "")
	Dim params As List
	params.Initialize
	Dim l As List
	l.Initialize

		l.AddAll(Array As String(Item.Get("Description"),Item.Get("Username"),Item.Get("Password"),Item.Get("Email"),Item.Get("Remark")))
	If l.Get(0) <> "" And l.Get(1) <> "" Then 
		If RowId = 0 Then 'new row
				
'				B4XTable1.ClearDataView
				B4XTable1.sql1.ExecNonQuery2($"INSERT INTO data VALUES(?,?,?,?,?,"")"$,l)
				Dim Query As String ="INSERT INTO psw VALUES(?,?,?,?,?,?,?,?,?,?,?)"
				params.AddAll(Array As String (id_user,Item.Get("Description"),Item.Get("Username"),Item.Get("Password"),tem_email,tem_remark,NowTime,timestamp,False,True,False)) 'persist user-entered Email/Remark
				MP.SQL1.ExecNonQuery2(Query,params)
		Else
			l.Add(RowId)
			'first column is c0. We skip it as this is the "edit" column
'				B4XTable1.ClearDataView
				B4XTable1.sql1.ExecNonQuery2("UPDATE data SET c0 = ?,c1 = ?,c2 = ?,c3 = ?,c4 = ? WHERE ROWID = ?", l)
			
			'get the rowid
			Dim tem As String = Item.Get("Description")
			Dim  ResultSet1 As ResultSet
			Dim Query As String = "SELECT RowId FROM psw WHERE id_user = ? AND description = ?"
			ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (id_user,tem))
			Do While ResultSet1.NextRow
				Dim SQL_RowId As Long = ResultSet1.Getint2(0)
			Loop
			ResultSet1.Close
			'get the state of syc_flag
			Query = "SELECT sync_flag from psw WHERE rowid = ?"
				Dim tem_sync_flag As Boolean = MP.SQL1.ExecQuerySingleResult2(Query,Array As String(SQL_RowId))
				Dim tem_changed As Boolean = False
			If tem_sync_flag = True Then
				 tem_changed  = True
			Else
				 tem_changed  = False
			End If
		    params.Initialize
				params.AddAll(Array As String(Item.Get("Description"),Item.Get("Username"),Item.Get("Password"),tem_email,tem_remark,timestamp,tem_changed,SQL_RowId))
			Query  ="UPDATE psw SET description = ?,username = ?,password = ?,email = ?, remark = ?,timestamp = ?,changed = ? WHERE RowID = ?"
			MP.SQL1.ExecNonQuery2(Query,params)
		End If
	
	Else
		#if b4a
		ToastMessageShow("NO DATA !",True)
		#end if
		#if b4j
		xui.MsgboxAsync("NO DATA !",True)
		#End If
	End If
	B4XTable1.Refresh
	
End Sub

Private Sub CollectDialogInput (Item As Map) As ResumableSub
	Wait For (ShowPasswordEditor(Item)) Complete (Success As Boolean)
	Return Success
End Sub

Private Sub ShowPasswordEditor (Item As Map) As ResumableSub
	Dim defaults As Map = Item
	If defaults.IsInitialized = False Then
		defaults.Initialize
	End If

	Dim dlgWidth As Int = Max(280dip, Min(Root.Width - 24dip, 520dip))
	Dim dlgHeight As Int = Max(360dip, Min(Root.Height - 36dip, 560dip))
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, dlgWidth, dlgHeight)
	pnl.Color = xui.Color_White

	Dim currentTop As Int = 10dip
	Dim fieldH As Int = 40dip
	Dim titleGap As Int = 22dip
	Dim rowGap As Int = 10dip

	Dim descInput As B4XView = CreateLabeledInput(pnl, currentTop, "Description", defaults.GetDefault("Description", ""), dlgWidth, fieldH)
	currentTop = currentTop + titleGap + fieldH + rowGap
	Dim userInput As B4XView = CreateLabeledInput(pnl, currentTop, "Username", defaults.GetDefault("Username", ""), dlgWidth, fieldH)
	currentTop = currentTop + titleGap + fieldH + rowGap
	Dim pwdInput As B4XView = CreateLabeledInput(pnl, currentTop, "Password", defaults.GetDefault("Password", ""), dlgWidth, fieldH)
	currentTop = currentTop + titleGap + fieldH + rowGap
	Dim emailInput As B4XView = CreateLabeledInput(pnl, currentTop, "Email", defaults.GetDefault("Email", ""), dlgWidth, fieldH)
	currentTop = currentTop + titleGap + fieldH + rowGap
	Dim remarkInput As B4XView = CreateLabeledInput(pnl, currentTop, "Remark", defaults.GetDefault("Remark", ""), dlgWidth, fieldH)

	Dialog.Title = "Edit"
	Wait For (Dialog.ShowCustom(pnl, "Save", "", "Cancel")) Complete (Result As Int)
	If Result <> xui.DialogResponse_Positive Then Return False

	Item.Put("Description", descInput.Text.Trim)
	Item.Put("Username", userInput.Text.Trim)
	Item.Put("Password", pwdInput.Text)
	Item.Put("Email", emailInput.Text.Trim)
	Item.Put("Remark", remarkInput.Text.Trim)
	Return True
End Sub

Private Sub CreateLabeledInput(Parent As B4XView, Top As Int, Title As String, DefaultValue As String, FormWidth As Int, FieldHeight As Int) As B4XView
	Dim lbl As Label
	lbl.Initialize("")
	lbl.Text = Title
	Parent.AddView(lbl, 10dip, Top, FormWidth - 20dip, 20dip)

	Dim input As B4XView
	#If B4A
	Dim et As EditText
	et.Initialize("")
	et.Text = DefaultValue
	input = et
	#Else
	Dim tf As TextField
	tf.Initialize("")
	tf.Text = DefaultValue
	input = tf
	#End If
	Parent.AddView(input, 10dip, Top + 22dip, FormWidth - 20dip, FieldHeight)
	Return input
End Sub



private Sub IME_HeightChanged (NewHeight As Int, OldHeight As Int)
	If B4XTable1.IsInitialized Then
		B4XTable1.mBase.Height = NewHeight - B4XTable1.mBase.Top
		B4XTable1.Refresh
	End If
End Sub


private Sub B4XTable1_CellLongClicked (ColumnId As String, RowId As Long)
	InputTemplate.Initialize
	InputTemplate.TextField1.TextColor = xui.Color_Black
	InputTemplate.TextField1.SetTextAlignment("TOP", "LEFT")
	InputTemplate.mBase.Height = 200dip
	#if B4A
	Dim et As EditText = InputTemplate.TextField1
	et.SingleLine = False
	et.Height = 150dip
	#END IF
	Dim column As B4XTableColumn = B4XTable1.GetColumn(ColumnId)
	Dim value As String = B4XTable1.GetRow(RowId).Get(ColumnId)
	InputTemplate.Text = value
	InputTemplate.lblTitle.Text = column.Id
	Wait For (Dialog.ShowTemplate(InputTemplate, "OK", "", "CANCEL")) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		B4XTable1.sql1.ExecNonQuery2($"UPDATE data SET ${column.SQLID} = ? WHERE rowid = ?"$, Array As String(InputTemplate.Text, RowId))
		
		'get the rowid
		'there is a problem that i don't know why?
		Dim QUERY As String = "SELECT c0 FROM data WHERE rowid = ?"
		Dim tem As String = B4XTable1.sql1.ExecQuerySingleResult2(QUERY, Array As String (RowId))
		Dim  ResultSet1 As ResultSet
	     QUERY  = "SELECT RowId FROM psw WHERE description = ?"
		ResultSet1 = MP.SQL1.ExecQuery2(QUERY, Array As String (tem))
		Do While ResultSet1.NextRow
			Dim SQL_RowId As Long = ResultSet1.Getint2(0)
		Loop
		ResultSet1.Close
		Dim tem_changed As String = "false"
		QUERY  = "SELECT sync_flag FROM psw WHERE rowid = ?"
		Dim tem_sync_flag As String = MP.SQL1.ExecQuerySingleResult2(QUERY,Array As String(SQL_RowId))
		If tem_sync_flag = "true" Then
			tem_changed = "true"
		Else
			tem_changed  = "false"
		End If
		
		DateTime.DateFormat = "yyyyMMdd"
		DateTime.TimeFormat = "HHmmss"
		Dim tem As String = DateTime.Date(DateTime.Now) & DateTime.Time(DateTime.Now)

		Dim l As List 
		l.Initialize
		l.AddAll(Array As String(InputTemplate.Text,tem,tem_changed,SQL_RowId))
		QUERY  ="UPDATE psw SET " & ColumnId.TolowerCase & " = ?,timestamp = ?,changed = ? WHERE RowId = ?" 
		MP.SQL1.ExecNonQuery2(QUERY,l)
		B4XTable1.Refresh
	End If
End Sub

private Sub CreateButton (EventName As String, Text As String) As B4XView
	Dim Btn As Button
	Dim FontSize As Int = 20
	#if B4i
	Btn.InitializeCustom(EventName, xui.Color_Black, xui.Color_White)
	FontSize = 16
	#else
	Btn.Initialize(EventName)
	#End If
	Dim x As B4XView = Btn
	
	x.Font =  xui.CreateFontAwesome(FontSize)
	x.Visible = False
	x.Text = Text
	x.TextColor = xui.Color_Black
	x.Color = xui.Color_Transparent
	Return x
End Sub

private Sub GetRowId (View As B4XView) As Long
	Dim RowIndex As Int = editCol.CellsLayouts.IndexOf(View.Parent)
	Dim RowId As Long = B4XTable1.VisibleRowIds.Get(RowIndex - 1) '-1 because of the header
	Return RowId
End Sub


Private Sub btnAdd_Click
	ShowDialog(CreateMap(), 0)
End Sub

private Sub btnDelete_Click

	Dim RowId As Long = GetRowId(Sender)
	Dim Item As Map = B4XTable1.GetRow(RowId)
	
	Dim sf As Object = xui.Msgbox2Async("Delete ?", "WARNING!", "Yes", "Cancel", "No", Null)
	Wait For (sf) Msgbox_Result (Result1 As Int)
	If Result1 = xui.DialogResponse_Positive Then
		Dim sf As Object = xui.Msgbox2Async($"Delete item: ${Item.Get("Description")}?"$, "", "Yes", "", "No", Null)
		Wait For (sf) Msgbox_Result (Result As Int)
		If Result = xui.DialogResponse_Positive Then
			Dim tem As String = Item.Get("Description")
			B4XTable1.sql1.ExecNonQuery2("DELETE FROM data WHERE rowid = ?", Array As String(RowId))
			
			'get the rowid
			
			Dim  ResultSet1 As ResultSet
			Dim Query As String = "SELECT RowId FROM psw WHERE description = ?"
			ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (tem))
			Do While ResultSet1.NextRow
				Dim SQL_RowId As Long = ResultSet1.Getint2(0)
			Loop
			ResultSet1.Close
			
			MP.SQL1.ExecNonQuery2("DELETE FROM psw WHERE rowid = ?", Array As String(SQL_RowId))
			B4XTable1.UpdateTableCounters
			End If
	End If
End Sub

private Sub btnEdit_Click
	Dim RowId As Long = GetRowId(Sender)
	Dim Item As Map = B4XTable1.GetRow(RowId)
	ShowDialog(Item, RowId)
End Sub


Private Sub Bntsyc_Click
	LoadData
End Sub