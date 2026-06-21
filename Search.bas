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
	#if b4a
	Private BtxInput As EditText
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
	B4XLoadingIndicator1.Hide
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
	rs = MP.SQL1.ExecQuery2(MP.searchEvents,Paremeters)
	
	Do While rs.NextRow
		
		Dim eventType As String = rs.GetString("event_type")
		Dim description As String = rs.GetString("description")
		Dim v As String = rs.GetString("value")
		Dim str As String = eventType & description & v
		Dim search_result = False As Boolean
		search_result = FindWordInText(Search_String,str)
		
		If search_result = True Then
			Get_data_flag = True
			Dim time As String = rs.GetString("time")
			Dim  ResultSet1 As ResultSet
			Dim Query As String = "SELECT RowId FROM events WHERE time = ?"
			ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (time))
			#if B4A
			ResultSet1.Position=0
			#END IF
			Do While ResultSet1.NextRow
				Dim id As Int = ResultSet1.Getint2(0)
			Loop

			ResultSet1.Close
			
			Dim hit As Map = ResolveFirstHit(eventType, description, v, Search_String)
			Dim mapData As Map = CreateMap("id":id,"event_type":eventType,"description":description,"value":v,"time":rs.GetString("time"), _
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
	If Keyword = "" Then Return Source
	Dim matches As List = FindMatches(Source, Keyword)
	If matches.Size = 0 Then Return Source
	Dim cs As CSBuilder
	cs.Initialize
	Dim cursor As Int = 0
	For Each startIndex As Int In matches
		If startIndex > cursor Then cs.Append(Source.SubString2(cursor, startIndex))
		Dim endIndex As Int = Min(Source.Length, startIndex + Keyword.Length)
		cs.BackgroundColor(xui.Color_Yellow).Color(xui.Color_Black).Append(Source.SubString2(startIndex, endIndex)).PopAll
		cursor = endIndex
	Next
	If cursor < Source.Length Then cs.Append(Source.SubString(cursor))
	Return cs
End Sub

Private Sub FindMatches (Source As String, Keyword As String) As List
	Dim res As List
	res.Initialize
	If Source = Null Or Keyword = "" Then Return res
	Dim srcLower As String = Source.ToLowerCase
	Dim keyLower As String = Keyword.ToLowerCase
	Dim pos As Int = srcLower.IndexOf(keyLower)
	Do While pos > -1
		res.Add(pos)
		pos = srcLower.IndexOf2(keyLower, pos + Max(1, keyLower.Length))
	Loop
	Return res
End Sub

Private Sub ResolveFirstHit (EventType As String, Description As String, ValueText As String, Keyword As String) As Map
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
		Dim Paremeters As String = m.Get("id")
		B4XLoadingIndicator1.Show
		
		MP.SQL1.ExecNonQuery2(MP.deleteEvents ,array as string ( Paremeters))
		clv2.RemoveAt(Index)
		B4XLoadingIndicator1.Hide
	End If

End Sub


Sub B4XPage_Appear

End Sub