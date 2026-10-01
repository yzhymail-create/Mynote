B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.16
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private MP As B4XMainPage
	Public Note_View As NoteView
	'Public PageData As B4XPageData
	Private Drawer As B4XDrawer
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	Private lblType As Label
	Private lblDescription As Label
	Private lblValue As Label
	Private lblEdit, lblDelete As Label
	#if B4A
	Private IME As IME
	#End If
	Private clv2 As CustomListView
	Private btnExportSearch As B4XView
	Private Button2 As B4XView
	Private output As B4XView
	#if b4a
	Private BtxInput As EditText
	Private ion As Object
	#end if
	
	Private InPut_Text As String
	Private CurrentKeyword As String

	Public Show_m As Map
	Public Edit_Index As Int
	Public Edit_Flag = False As Boolean
	#if b4j
	Private BtxInput As TextField
	#end if
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	#if B4A
	IME.Initialize("IME")
	#End If
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	'PageData = B4XPages.GetPage("B4XPageData")
	Note_View = B4XPages.GetPage("NoteView")
	Drawer.Initialize(Me, "Drawer", Root, 200dip)
	Drawer.CenterPanel.LoadLayout("searchview")
	Root.LoadLayout("searchview")
	MP = B4XPages.MainPage
	BindExportButton
	B4XLoadingIndicator1.Hide
End Sub

Private Sub BindExportButton
	If output.IsInitialized Then
		btnExportSearch = output
	Else If Button2.IsInitialized Then
		btnExportSearch = Button2
	Else
		btnExportSearch = Null
	End If
	If btnExportSearch.IsInitialized Then btnExportSearch.Text = "TO TXT"
End Sub

Private Sub UpdateExportButtonLayout
	If btnExportSearch.IsInitialized = False Then Return
	'Use layout-defined position/size so it adapts across phone/tablet.
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.


Private Sub Button1_Click
	InPut_Text = BtxInput.Text
	If InPut_Text <>"" Then
		PopulateCards1(InPut_Text)
	End If
	#IF B4A
	IME.HideKeyboard
	#END IF
End Sub


Sub PopulateCards1 (Search_String As String)
	Dim Get_data_flag = False As Boolean   'check if there is the search data 
	clv2.Clear
	CurrentKeyword = Search_String
	Dim rs As ResultSet
	B4XLoadingIndicator1.Show
	Dim Paremeters()  As String = Array As String(B4XPages.MainPage.KVS.Get("id_user"))
	Dim hasUuid As Boolean = MP.EventsUseUuid
	Dim hasLunarText As Boolean = MP.EventsUseLunarText
	rs = MP.SQL1.ExecQuery2(MP.searchEvents,Paremeters)
	
	Do While rs.NextRow
		
		Dim eventType As String = rs.GetString("event_type")
		Dim description As String = rs.GetString("description")
		Dim v As String = rs.GetString("value")
		Dim tags As String = rs.GetString("tags")
		Dim attachmentsJson As String = rs.GetString("attachments_json")
		Dim str As String = eventType & description & v & tags & attachmentsJson
		Dim search_result = False As Boolean
		search_result = FindWordInText(Search_String,str)
		
		If search_result = True Then
			Get_data_flag = True
			Dim eventUuid As String = ""
			If hasUuid Then eventUuid = rs.GetString("uuid")
			Dim lunarText As String = ""
			If hasLunarText Then lunarText = rs.GetString("lunar_text")
			lunarText = MP.ResolveEventLunarText(rs.GetString("time"), lunarText)
			Dim id As Long = MP.ResolveEventRowId(eventUuid, rs.GetString("time"))
			
			Dim hit As Map = ResolveFirstHit(eventType, description, v, tags, Search_String)
			Dim mapData As Map = CreateMap("id":id,"uuid":eventUuid,"event_type":eventType,"description":description,"value":v,"tags":tags,"time":rs.GetString("time"),"lunar_text":lunarText, _
				"kw":Search_String,"hit_field":hit.Get("field"),"hit_start":hit.Get("start"),"hit_len":Search_String.Length)
			Dim p As B4XView = CreateCard1(mapData)
			clv2.Add(p, mapData)
		End If
	Loop
	rs.Close
	If Get_data_flag = False Then 
		xui.MsgboxAsync("NO DATA !", "")
	End If
	B4XLoadingIndicator1.Hide
End Sub

Sub CreateCard1 (Data As Map) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	'Dim height As Int = 180dip
	Dim height As Int = 200dip
	#if B4A
	If GetDeviceLayoutValues.ApproximateScreenSize < 4.5 Then height = 310dip
	#end if
	p.SetLayoutAnimated(0, 0, 0, clv2.AsView.Width, height)
	p.LoadLayout("Card")
	lblType.Text = BuildHighlightedText(Data.Get("event_type"), CurrentKeyword)
	lblDescription.Text = BuildHighlightedText(Data.Get("description"), CurrentKeyword)
	lblValue.Text = BuildHighlightedText(Data.Get("value"), CurrentKeyword)
	'We store the map in the tag properties to pass it to B4XPreferencesDialog when editing or deleting
	lblEdit.Tag = Data
	lblDelete.Tag = Data
	Return p
End Sub


Private Sub B4XPage_CloseRequest As ResumableSub
'	#if B4A
'	'home button
'	If Main.ActionBarHomeClicked Then
'		Drawer.LeftOpen = Not(Drawer.LeftOpen)
'		Return False
'	End If
'	'back key
	If Drawer.LeftOpen Then
		Drawer.LeftOpen = Not(Drawer.LeftOpen)
		'Return False
	End If
'	#end if

	BtxInput.Text=""
	clv2.Clear
	Return True
End Sub

Sub FindWordInText (word As String, txt As String) As Boolean
	If word = "" Then Return False
	Return txt.ToLowerCase.IndexOf(word.ToLowerCase) > -1
End Sub

Private Sub BuildHighlightedText (Source As String, Keyword As String) As Object
	If Source = Null Then Source = ""
	If Keyword <> "" Then
		Return Source
	End If
	Return Source
End Sub

Private Sub ResolveFirstHit (EventType As String, Description As String, ValueText As String, TagsText As String, Keyword As String) As Map
	Dim m As Map
	m.Initialize
	Dim p As Int = Description.ToLowerCase.IndexOf(Keyword.ToLowerCase)
	If p > -1 Then
		m.Put("field", "description")
		m.Put("start", p)
		Return m
	End If
	p = EventType.ToLowerCase.IndexOf(Keyword.ToLowerCase)
	If p > -1 Then
		m.Put("field", "event_type")
		m.Put("start", p)
		Return m
	End If
	p = ValueText.ToLowerCase.IndexOf(Keyword.ToLowerCase)
	If p > -1 Then
		m.Put("field", "value")
		m.Put("start", p)
		Return m
	End If
	p = TagsText.ToLowerCase.IndexOf(Keyword.ToLowerCase)
	If p > -1 Then
		m.Put("field", "description")
		m.Put("start", 0)
		Return m
	End If
	m.Put("field", "value")
	m.Put("start", p)
	Return m
End Sub


#if B4A
Private Sub BtxInput_EnterPressed

End Sub
#end if

#if B4J
Private Sub lblEdit_MouseClicked (EventData As MouseEvent)
#end if
#if b4a
Private Sub lblEdit_Click
#end if

	Edit_Index  = clv2.GetItemFromView(Sender)
	Dim l As Label = Sender
	Show_m  = l.Tag
	Edit_Flag = True
	B4XPages.ShowPage("NoteView")
	 
End Sub

#if B4J
Private Sub lblDelete_MouseClicked (EventData As MouseEvent)
#else
Private Sub lblDelete_Click
#end if
	Dim Index As Int = clv2.GetItemFromView(Sender)
	Dim l As Label = Sender
	Dim m As Map = l.Tag
	Dim sf As Object = xui.Msgbox2Async("Delete event?", "WARNING", "Yes", "Cancel", "No", Null)
	Wait For (sf) Msgbox_Result (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Dim Paremeters As Long = MP.ResolveEventRowIdFromMap(m)
		If Paremeters <= 0 Then Return
		B4XLoadingIndicator1.Show
		Dim tem_time As String = MP.SQL1.ExecQuerySingleResult2("SELECT time from events WHERE rowid = ?",Array As String(Paremeters))
		MP.InsertDeleteEventTombstone(MP.KVS.Get("id_user"), m.GetDefault("uuid", ""), tem_time)
		
		MP.SQL1.ExecNonQuery2(MP.deleteEvents ,array as string ( Paremeters))
		clv2.RemoveAt(Index)
		B4XLoadingIndicator1.Hide
	End If

End Sub


Sub B4XPage_Appear
	BindExportButton
	UpdateExportButtonLayout
	B4XPages.SetTitle(Me, "Search (TXT导出)")

End Sub

Private Sub B4XPage_Resize (Width As Int, Height As Int)
	UpdateExportButtonLayout

End Sub

Private Sub Button2_Click
	ExportSearchResultsTxt
End Sub

Private Sub output_Click
	ExportSearchResultsTxt
End Sub

Private Sub btnExportSearch_Click
	ExportSearchResultsTxt
End Sub

Private Sub ExportSearchResultsTxt
	If clv2.Size = 0 Then
		xui.MsgboxAsync("当前没有搜索结果可导出。", "导出TXT")
		Return
	End If

	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("MySuperNote Search Export").Append(CRLF)
	sb.Append("Keyword: ").Append(CurrentKeyword).Append(CRLF)
	sb.Append("Count: ").Append(clv2.Size).Append(CRLF).Append(CRLF)

	For i = 0 To clv2.Size - 1
		Dim m As Map = clv2.GetValue(i)
		sb.Append("# ").Append(i + 1).Append(CRLF)
		sb.Append("Type: ").Append(m.GetDefault("event_type", "")).Append(CRLF)
		sb.Append("Value: ").Append(m.GetDefault("value", "")).Append(CRLF)
		sb.Append("Description: ").Append(m.GetDefault("description", "")).Append(CRLF)
		sb.Append("Tags: ").Append(m.GetDefault("tags", "")).Append(CRLF)
		sb.Append("Time: ").Append(m.GetDefault("time", "")).Append(CRLF)
		sb.Append("Lunar: ").Append(MP.ResolveEventLunarText(m.GetDefault("time", ""), m.GetDefault("lunar_text", ""))).Append(CRLF)
		sb.Append("--------------------------------").Append(CRLF)
	Next

	DateTime.DateFormat = "yyyyMMdd"
	DateTime.TimeFormat = "HHmmss"
	Dim fileName As String = "search_results_" & DateTime.Date(DateTime.Now) & "_" & DateTime.Time(DateTime.Now) & ".txt"
	File.WriteString(xui.DefaultFolder, fileName, sb.ToString)

	#If B4A
	Dim in As InputStream = File.OpenInput(xui.DefaultFolder, fileName)
	Wait For (SaveFile(in, "text/plain", fileName)) Complete (Success As Boolean)
	in.Close
	If Success Then
		xui.MsgboxAsync("搜索结果已导出为 TXT（UTF-8）。", "导出TXT")
	End If
	#Else
	xui.MsgboxAsync("搜索结果已导出为 TXT（UTF-8）:" & CRLF & File.Combine(xui.DefaultFolder, fileName), "导出TXT")
	#End If

End Sub

#if b4a
Sub SaveFile (Source As InputStream, MimeType As String, Title As String) As ResumableSub
	Dim intent As Intent
	intent.Initialize("android.intent.action.CREATE_DOCUMENT", "")
	intent.AddCategory("android.intent.category.OPENABLE")
	intent.PutExtra("android.intent.extra.TITLE", Title)
	intent.SetType(MimeType)
	StartActivityForResult(intent)
	Wait For ion_Event (MethodName As String, Args() As Object)
	If -1 = Args(0) Then
		Dim result As Intent = Args(1)
		Dim jo As JavaObject = result
		Dim ctxt As JavaObject
		Dim out As OutputStream = ctxt.InitializeContext.RunMethodJO("getContentResolver", Null).RunMethod("openOutputStream", Array(jo.RunMethod("getData", Null)))
		File.Copy2(Source, out)
		out.Close
		Return True
	End If
	Return False
End Sub

Sub StartActivityForResult(i As Intent)
	Dim jo As JavaObject = GetBA
	ion = jo.CreateEvent("anywheresoftware.b4a.IOnActivityResult", "ion", Null)
	jo.RunMethod("startActivityForResult", Array(ion, i))
End Sub

Sub GetBA As Object
	Dim jo As JavaObject = Me
	Return jo.RunMethod("getBA", Null)
End Sub
#end if