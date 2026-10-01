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
	Private pnlAdvancedSearch As B4XView
	Private lblSearchTips As Label
	Private txtCondition2 As B4XView
	Private txtCondition3 As B4XView
	Private btnLogic1 As B4XView
	Private btnLogic2 As B4XView
	Private ResultsBaseTop As Int
	Private ResultsBottomGap As Int
	Private SelectedItems As Map 'key: selection key -> result Map, tracks which cards are checked for export
	Private lblSelectionInfo As Label
	Private btnSelectAll As B4XView
	Private btnExportSelected As B4XView
	Private btnSelectAllNative As Button
	Private btnExportSelectedNative As Button
	Private MeasureCanvas As B4XCanvas
	#if b4a
	Private BtxInput As EditText
	Private etCondition2 As EditText
	Private etCondition3 As EditText
	Private btnLogic1Native As Button
	Private btnLogic2Native As Button
	Private ion As Object
	#end if
	
	Private InPut_Text As String
	Private CurrentKeyword As String
	Private CurrentSearchExpression As Map

	Public Show_m As Map
	Public Edit_Index As Int
	Public Edit_Flag = False As Boolean
	#if b4j
	Private BtxInput As TextField
	Private etCondition2 As TextField
	Private etCondition3 As TextField
	Private btnLogic1Native As Button
	Private btnLogic2Native As Button
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
	MP = B4XPages.MainPage
	MeasureCanvas.Initialize(Root)
	SelectedItems.Initialize
	BindExportButton
	ResultsBaseTop = clv2.AsView.Top
	ResultsBottomGap = Root.Height - (clv2.AsView.Top + clv2.AsView.Height)
	EnsureAdvancedSearchControls
	UpdateAdvancedSearchLayout
	DisableSearchLoadingIndicator
End Sub

Private Sub DisableSearchLoadingIndicator
	If B4XLoadingIndicator1.IsInitialized Then
		B4XLoadingIndicator1.Hide
		If B4XLoadingIndicator1.mBase.IsInitialized Then
			B4XLoadingIndicator1.mBase.Visible = False
			B4XLoadingIndicator1.mBase.RemoveViewFromParent
		End If
	End If
End Sub

Private Sub EnsureAdvancedSearchControls
	If pnlAdvancedSearch.IsInitialized Then Return
	pnlAdvancedSearch = xui.CreatePanel("")
	Root.AddView(pnlAdvancedSearch, 0, 0, 0, 0)

	lblSearchTips.Initialize("")
	lblSearchTips.Text = "高级搜索: 条件2/条件3留空时，仍可直接在首个输入框写 AND / OR / 与 / 或 表达式"
	lblSearchTips.TextSize = 12
	lblSearchTips.TextColor = xui.Color_Gray
	pnlAdvancedSearch.AddView(lblSearchTips, 0, 0, 0, 0)

	#If B4A
	etCondition2.Initialize("")
	etCondition2.SingleLine = True
	etCondition2.Hint = "条件2，例如: 电池"
	txtCondition2 = etCondition2
	pnlAdvancedSearch.AddView(etCondition2, 0, 0, 0, 0)

	etCondition3.Initialize("")
	etCondition3.SingleLine = True
	etCondition3.Hint = "条件3，例如: 储能"
	txtCondition3 = etCondition3
	pnlAdvancedSearch.AddView(etCondition3, 0, 0, 0, 0)

	btnLogic1Native.Initialize("btnLogic1")
	btnLogic2Native.Initialize("btnLogic2")
	btnLogic1 = btnLogic1Native
	btnLogic2 = btnLogic2Native
	pnlAdvancedSearch.AddView(btnLogic1Native, 0, 0, 0, 0)
	pnlAdvancedSearch.AddView(btnLogic2Native, 0, 0, 0, 0)
	#Else If B4J
	etCondition2.Initialize("etCondition2")
	etCondition2.PromptText = "条件2，例如: 电池"
	txtCondition2 = etCondition2
	pnlAdvancedSearch.AddView(etCondition2, 0, 0, 0, 0)

	etCondition3.Initialize("etCondition3")
	etCondition3.PromptText = "条件3，例如: 储能"
	txtCondition3 = etCondition3
	pnlAdvancedSearch.AddView(etCondition3, 0, 0, 0, 0)

	btnLogic1Native.Initialize("btnLogic1")
	btnLogic2Native.Initialize("btnLogic2")
	btnLogic1 = btnLogic1Native
	btnLogic2 = btnLogic2Native
	pnlAdvancedSearch.AddView(btnLogic1Native, 0, 0, 0, 0)
	pnlAdvancedSearch.AddView(btnLogic2Native, 0, 0, 0, 0)
	#End If

	lblSelectionInfo.Initialize("")
	lblSelectionInfo.TextSize = 12
	lblSelectionInfo.TextColor = xui.Color_Gray
	pnlAdvancedSearch.AddView(lblSelectionInfo, 0, 0, 0, 0)

	btnSelectAllNative.Initialize("btnSelectAllNative")
	btnSelectAll = btnSelectAllNative
	pnlAdvancedSearch.AddView(btnSelectAllNative, 0, 0, 0, 0)

	btnExportSelectedNative.Initialize("btnExportSelectedNative")
	btnExportSelected = btnExportSelectedNative
	pnlAdvancedSearch.AddView(btnExportSelectedNative, 0, 0, 0, 0)

	btnSelectAll.Text = "All"
	btnExportSelected.Text = "Export"
	UpdateSelectionInfoLabel

	SetLogicButtonText(btnLogic1, "AND")
	SetLogicButtonText(btnLogic2, "AND")
End Sub

Private Sub UpdateAdvancedSearchLayout
	If pnlAdvancedSearch.IsInitialized = False Or BtxInput.IsInitialized = False Then Return
	Dim gap As Int = 6dip
	Dim buttonWidth As Int = 64dip
	Dim rowHeight As Int = Max(BtxInput.Height, 34dip)
	Dim margin As Int = 10dip
	Dim panelLeft As Int = margin
	Dim panelTop As Int = BtxInput.Top + BtxInput.Height + gap
	Dim panelWidth As Int = Root.Width - margin * 2
	Dim tipsHeight As Int = 26dip
	Dim contentWidth As Int = Max(100dip, panelWidth - buttonWidth - gap)
	Dim actionButtonWidth As Int = (panelWidth - gap) / 2
	Dim selectionInfoHeight As Int = 34dip
	Dim panelHeight As Int = tipsHeight + gap + rowHeight + gap + rowHeight + gap + selectionInfoHeight + gap + rowHeight
	pnlAdvancedSearch.SetLayoutAnimated(0, panelLeft, panelTop, panelWidth, panelHeight)
	lblSearchTips.SetLayoutAnimated(0, 0, 0, panelWidth, tipsHeight)
	txtCondition2.SetLayoutAnimated(0, 0, tipsHeight + gap, contentWidth, rowHeight)
	btnLogic1.SetLayoutAnimated(0, contentWidth + gap, tipsHeight + gap, buttonWidth, rowHeight)
	txtCondition3.SetLayoutAnimated(0, 0, tipsHeight + gap + rowHeight + gap, contentWidth, rowHeight)
	btnLogic2.SetLayoutAnimated(0, contentWidth + gap, tipsHeight + gap + rowHeight + gap, buttonWidth, rowHeight)

	Dim selectionRowTop As Int = tipsHeight + gap + rowHeight + gap + rowHeight + gap
	If lblSelectionInfo.IsInitialized Then
		lblSelectionInfo.SetLayoutAnimated(0, 0, selectionRowTop, panelWidth, selectionInfoHeight)
	End If
	Dim buttonsTop As Int = selectionRowTop + selectionInfoHeight + gap
	If btnSelectAll.IsInitialized Then
		btnSelectAll.SetLayoutAnimated(0, 0, buttonsTop, actionButtonWidth, rowHeight)
	End If
	If btnExportSelected.IsInitialized Then
		btnExportSelected.SetLayoutAnimated(0, actionButtonWidth + gap, buttonsTop, actionButtonWidth, rowHeight)
	End If

	Dim resultsTop As Int = Max(ResultsBaseTop, panelTop + panelHeight + 8dip)
	Dim resultsHeight As Int = Max(120dip, Root.Height - resultsTop - ResultsBottomGap)
	clv2.AsView.SetLayoutAnimated(0, clv2.AsView.Left, resultsTop, clv2.AsView.Width, resultsHeight)
End Sub

Private Sub SetLogicButtonText (Target As B4XView, LogicText As String)
	If Target.IsInitialized = False Then Return
	Target.Text = LogicText.ToUpperCase
End Sub

Private Sub ToggleLogicButton (Target As B4XView)
	If Target.IsInitialized = False Then Return
	If Target.Text.ToUpperCase = "AND" Then
		Target.Text = "OR"
	Else
		Target.Text = "AND"
	End If
End Sub

Private Sub BuildSearchRequestText As String
	Dim term1 As String = BtxInput.Text.Trim
	Dim term2 As String = txtCondition2.Text.Trim
	Dim term3 As String = txtCondition3.Text.Trim
	If term2 = "" And term3 = "" Then Return term1

	Dim sb As StringBuilder
	sb.Initialize
	AppendSearchTerm(sb, term1, "")
	AppendSearchTerm(sb, term2, btnLogic1.Text)
	AppendSearchTerm(sb, term3, btnLogic2.Text)
	Return sb.ToString.Trim
End Sub

Private Sub AppendSearchTerm (Target As StringBuilder, Term As String, OperatorText As String)
	If Term = "" Then Return
	If Target.Length > 0 Then
		Target.Append(" ").Append(NormalizeLogicOperator(OperatorText)).Append(" ")
	End If
	Target.Append(Term)
End Sub

Private Sub NormalizeLogicOperator (OperatorText As String) As String
	Dim normalized As String = OperatorText.Trim.ToUpperCase
	If normalized <> "OR" Then normalized = "AND"
	Return normalized
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
	InPut_Text = BuildSearchRequestText
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
	SelectedItems.Initialize
	UpdateSelectionInfoLabel
	CurrentKeyword = Search_String.Trim
	CurrentSearchExpression = ParseSearchExpression(CurrentKeyword)
	Dim rs As ResultSet
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
		search_result = SearchExpressionMatches(CurrentSearchExpression, str)
		
		If search_result = True Then
			Get_data_flag = True
			Dim eventUuid As String = ""
			If hasUuid Then eventUuid = rs.GetString("uuid")
			Dim lunarText As String = ""
			If hasLunarText Then lunarText = rs.GetString("lunar_text")
			lunarText = MP.ResolveEventLunarText(rs.GetString("time"), lunarText)
			Dim id As Long = MP.ResolveEventRowId(eventUuid, rs.GetString("time"))
			
			Dim hit As Map = ResolveFirstHit(eventType, description, v, tags, attachmentsJson, CurrentSearchExpression)
			Dim hitKeyword As String = hit.GetDefault("term", CurrentKeyword)
			Dim mapData As Map = CreateMap("id":id,"uuid":eventUuid,"event_type":eventType,"description":description,"value":v,"tags":tags,"time":rs.GetString("time"),"lunar_text":lunarText, _
				"kw":hitKeyword,"hit_field":hit.Get("field"),"hit_start":hit.Get("start"),"hit_len":hitKeyword.Length)
			Dim p As B4XView = CreateCard1(mapData)
			clv2.Add(p, mapData)
		End If
	Loop
	rs.Close
	If Get_data_flag = False Then 
		xui.MsgboxAsync("NO DATA !", "")
	End If
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
	Dim actionTop As Int = lblEdit.Top - 1dip
	Dim actionHeight As Int = Max(28dip, lblEdit.Height + 4dip)

	Dim btnSelectItem As Button
	btnSelectItem.Initialize("btnSelectItem")
	btnSelectItem.Tag = Data
	btnSelectItem.TextSize = 12
	Data.Put("_selecttoggle", btnSelectItem)
	ApplySelectionToggleState(btnSelectItem, SelectedItems.ContainsKey(CardSelectionKey(Data)))
	Dim selectWidth As Int = MeasureButtonTextWidth(btnSelectItem, "Select", "Selected")

	Dim btnExportOne As Button
	btnExportOne.Initialize("btnExportOne")
	btnExportOne.Tag = Data
	btnExportOne.Text = "Export"
	btnExportOne.TextSize = 12
	Dim exportWidth As Int = MeasureButtonTextWidth(btnExportOne, "Export", "Export")
	Dim actionGap As Int = 6dip
	Dim exportLeft As Int = Max(6dip, lblEdit.Left - actionGap - exportWidth)
	Dim selectLeft As Int = Max(6dip, exportLeft - actionGap - selectWidth)
	p.AddView(btnSelectItem, selectLeft, actionTop, selectWidth, actionHeight)
	p.AddView(btnExportOne, exportLeft, actionTop, exportWidth, actionHeight)
	Return p
End Sub

Private Sub MeasureButtonTextWidth (Target As Button, FirstText As String, SecondText As String) As Int
	Dim targetView As B4XView = Target
	Dim firstWidth As Float = MeasureCanvas.MeasureText(FirstText, targetView.Font).Width
	Dim secondWidth As Float = MeasureCanvas.MeasureText(SecondText, targetView.Font).Width
	Return Ceil(Max(firstWidth, secondWidth) + 20dip)
End Sub

Private Sub chkSelect_CheckedChange (Checked As Boolean)
	Dim chk As CheckBox = Sender
	Dim m As Map = chk.Tag
	Dim key As String = CardSelectionKey(m)
	If Checked Then
		SelectedItems.Put(key, m)
	Else
		SelectedItems.Remove(key)
	End If
	UpdateSelectionLabelForData(m, Checked)
	UpdateSelectionInfoLabel
End Sub

Private Sub UpdateSelectionLabelForData (Data As Map, Checked As Boolean)
	Dim ctrl As Button = Data.Get("_selecttoggle")
	If ctrl.IsInitialized Then ApplySelectionToggleState(ctrl, Checked)
End Sub

Private Sub ApplySelectionToggleState (Target As Button, Checked As Boolean)
	If Checked Then
		Target.Text = "Selected"
	Else
		Target.Text = "Select"
	End If
End Sub

Private Sub CardSelectionKey (Data As Map) As String
	Dim uuid As String = Data.GetDefault("uuid", "")
	If uuid <> "" Then Return "uuid:" & uuid
	Return "id:" & Data.GetDefault("id", 0)
End Sub

Private Sub UpdateSelectionInfoLabel
	If lblSelectionInfo.IsInitialized = False Then Return
	If SelectedItems.Size = 0 Then
		lblSelectionInfo.Text = "No items selected. Tap Select on notes, then tap Export."
	Else
		lblSelectionInfo.Text = SelectedItems.Size & " selected"
	End If
	UpdateSelectAllButtonText
End Sub

Private Sub UpdateSelectAllButtonText
	If btnSelectAll.IsInitialized = False Then Return
	If clv2.Size > 0 And SelectedItems.Size = clv2.Size Then
		btnSelectAll.Text = "All"
	Else
		btnSelectAll.Text = "All"
	End If
End Sub

Private Sub RefreshCardCheckboxes
	For i = 0 To clv2.Size - 1
		Dim m As Map = clv2.GetValue(i)
		UpdateSelectionLabelForData(m, SelectedItems.ContainsKey(CardSelectionKey(m)))
	Next
End Sub

#if B4J
Private Sub btnSelectItem_MouseClicked (EventData As MouseEvent)
#else
Private Sub btnSelectItem_Click
#end if
	Dim btn As Button = Sender
	Dim m As Map = btn.Tag
	Dim isSelected As Boolean = SelectedItems.ContainsKey(CardSelectionKey(m))
	If isSelected Then
		SelectedItems.Remove(CardSelectionKey(m))
	Else
		SelectedItems.Put(CardSelectionKey(m), m)
	End If
	UpdateSelectionLabelForData(m, Not(isSelected))
	UpdateSelectionInfoLabel
End Sub

#if B4J
Private Sub btnExportOne_MouseClicked (EventData As MouseEvent)
#else
Private Sub btnExportOne_Click
#end if
	Dim btn As Button = Sender
	Dim items As List
	items.Initialize
	items.Add(btn.Tag)
	ExportEventItems(items, "单独导出1条搜索结果")
End Sub

Private Sub btnSelectAllNative_Click
	If clv2.Size = 0 Then Return
	Dim shouldSelectAll As Boolean = SelectedItems.Size < clv2.Size
	SelectedItems.Initialize
	If shouldSelectAll Then
		For i = 0 To clv2.Size - 1
			Dim m As Map = clv2.GetValue(i)
			SelectedItems.Put(CardSelectionKey(m), m)
		Next
	End If
	RefreshCardCheckboxes
	UpdateSelectionInfoLabel
End Sub

Private Sub btnExportSelectedNative_Click
	If SelectedItems.Size = 0 Then
		xui.MsgboxAsync("Tap Export on a note first, then tap Export below. You can also export a single note directly.", "Export")
		Return
	End If
	Dim items As List
	items.Initialize
	For Each key As String In SelectedItems.Keys
		items.Add(SelectedItems.Get(key))
	Next
	ExportEventItems(items, "已选中的" & items.Size & "条结果")
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
	If txtCondition2.IsInitialized Then txtCondition2.Text = ""
	If txtCondition3.IsInitialized Then txtCondition3.Text = ""
	SetLogicButtonText(btnLogic1, "AND")
	SetLogicButtonText(btnLogic2, "AND")
	clv2.Clear
	SelectedItems.Initialize
	UpdateSelectionInfoLabel
	Return True
End Sub

Sub FindWordInText (word As String, txt As String) As Boolean
	If word = "" Then Return False
	Return txt.ToLowerCase.IndexOf(word.ToLowerCase) > -1
End Sub

Private Sub ParseSearchExpression (RawQuery As String) As Map
	Dim expression As Map
	expression.Initialize
	Dim trimmed As String = RawQuery.Trim
	expression.Put("raw", trimmed)
	Dim clauses As List
	clauses.Initialize
	If trimmed = "" Then
		expression.Put("clauses", clauses)
		expression.Put("display", "")
		Return expression
	End If

	If ContainsBooleanOperator(trimmed) = False Then
		Dim singleClause As List
		singleClause.Initialize
		singleClause.Add(trimmed)
		clauses.Add(singleClause)
		expression.Put("clauses", clauses)
		expression.Put("display", trimmed)
		Return expression
	End If

	Dim canonical As String = CanonicalizeSearchQuery(trimmed)
	Dim parts() As String = Regex.Split(" ", canonical)
	Dim currentClause As List
	currentClause.Initialize
	For Each part As String In parts
		If part = "" Then Continue
		If part = "OR" Then
			If currentClause.Size > 0 Then
				clauses.Add(currentClause)
				currentClause.Initialize
			End If
		Else If part <> "AND" Then
			currentClause.Add(part)
		End If
	Next
	If currentClause.Size > 0 Then clauses.Add(currentClause)
	If clauses.Size = 0 Then
		currentClause.Initialize
		currentClause.Add(trimmed)
		clauses.Add(currentClause)
	End If
	expression.Put("clauses", clauses)
	expression.Put("display", BuildSearchExpressionDisplay(clauses))
	Return expression
End Sub

Private Sub ContainsBooleanOperator (RawQuery As String) As Boolean
	Dim query As String = RawQuery.ToUpperCase
	Return query.Contains(" AND ") Or query.Contains(" OR ") Or RawQuery.Contains("&&") Or RawQuery.Contains("||") Or RawQuery.Contains("与") Or RawQuery.Contains("或")
End Sub

Private Sub CanonicalizeSearchQuery (RawQuery As String) As String
	Dim query As String = RawQuery
	query = query.Replace(CRLF, " ")
	query = query.Replace(Chr(13), " ")
	query = query.Replace(Chr(10), " ")
	query = query.Replace(Chr(9), " ")
	query = query.Replace("&&", " AND ")
	query = query.Replace("||", " OR ")
	query = query.Replace("与", " AND ")
	query = query.Replace("或", " OR ")
	query = query.Replace(" and ", " AND ")
	query = query.Replace(" And ", " AND ")
	query = query.Replace(" aNd ", " AND ")
	query = query.Replace(" anD ", " AND ")
	query = query.Replace(" ANd ", " AND ")
	query = query.Replace(" Or ", " OR ")
	query = query.Replace(" oR ", " OR ")
	query = query.Replace(" or ", " OR ")
	query = query.Replace(" OR ", " OR ")
	Return CompactSpaces(query)
End Sub

Private Sub CompactSpaces (Text As String) As String
	Dim cleaned As String = Text.Trim
	Do While cleaned.Contains("  ")
		cleaned = cleaned.Replace("  ", " ")
	Loop
	Return cleaned
End Sub

Private Sub BuildSearchExpressionDisplay (Clauses As List) As String
	If Clauses.IsInitialized = False Or Clauses.Size = 0 Then Return ""
	Dim parts As List
	parts.Initialize
	For Each clause As List In Clauses
		parts.Add(JoinClauseTerms(clause))
	Next
	Return JoinTextList(parts, " OR ")
End Sub

Private Sub JoinClauseTerms (Clause As List) As String
	Return JoinTextList(Clause, " AND ")
End Sub

Private Sub JoinTextList (Items As List, Separator As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To Items.Size - 1
		If i > 0 Then sb.Append(Separator)
		sb.Append(Items.Get(i))
	Next
	Return sb.ToString
End Sub

Private Sub SearchExpressionMatches (Expression As Map, Text As String) As Boolean
	If Expression.IsInitialized = False Then Return False
	Dim clauses As List = Expression.Get("clauses")
	If clauses.IsInitialized = False Or clauses.Size = 0 Then Return False
	Dim haystack As String = Text.ToLowerCase
	For Each clause As List In clauses
		If ClauseMatches(clause, haystack) Then Return True
	Next
	Return False
End Sub

Private Sub ClauseMatches (Clause As List, Haystack As String) As Boolean
	If Clause.IsInitialized = False Or Clause.Size = 0 Then Return False
	For Each term As String In Clause
		If Haystack.IndexOf(term.ToLowerCase) = -1 Then Return False
	Next
	Return True
End Sub

Private Sub BuildHighlightedText (Source As String, Keyword As String) As Object
	If Source = Null Then Source = ""
	If Keyword <> "" Then
		Return Source
	End If
	Return Source
End Sub

Private Sub ResolveFirstHit (EventType As String, Description As String, ValueText As String, TagsText As String, AttachmentsJson As String, Expression As Map) As Map
	Dim m As Map
	m.Initialize
	Dim clauses As List = Expression.Get("clauses")
	If clauses.IsInitialized Then
		Dim searchable As String = EventType & Description & ValueText & TagsText & AttachmentsJson
		Dim searchableLower As String = searchable.ToLowerCase
		For Each clause As List In clauses
			If ClauseMatches(clause, searchableLower) Then
				For Each term As String In clause
					Dim hit As Map = ResolveSingleTermHit(EventType, Description, ValueText, TagsText, term)
					If hit.GetDefault("start", -1) > -1 Then Return hit
				Next
			End If
		Next
	End If
	m.Put("field", "value")
	m.Put("start", -1)
	m.Put("term", "")
	Return m
End Sub

Private Sub ResolveSingleTermHit (EventType As String, Description As String, ValueText As String, TagsText As String, Term As String) As Map
	Dim m As Map
	m.Initialize
	Dim lowerTerm As String = Term.ToLowerCase
	Dim p As Int = Description.ToLowerCase.IndexOf(lowerTerm)
	If p > -1 Then
		m.Put("field", "description")
		m.Put("start", p)
		m.Put("term", Term)
		Return m
	End If
	p = EventType.ToLowerCase.IndexOf(lowerTerm)
	If p > -1 Then
		m.Put("field", "event_type")
		m.Put("start", p)
		m.Put("term", Term)
		Return m
	End If
	p = ValueText.ToLowerCase.IndexOf(lowerTerm)
	If p > -1 Then
		m.Put("field", "value")
		m.Put("start", p)
		m.Put("term", Term)
		Return m
	End If
	p = TagsText.ToLowerCase.IndexOf(lowerTerm)
	If p > -1 Then
		m.Put("field", "description")
		m.Put("start", 0)
		m.Put("term", Term)
		Return m
	End If
	m.Put("field", "value")
	m.Put("start", -1)
	m.Put("term", Term)
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
		Dim tem_time As String = MP.SQL1.ExecQuerySingleResult2("SELECT time from events WHERE rowid = ?",Array As String(Paremeters))
		MP.InsertDeleteEventTombstone(MP.KVS.Get("id_user"), m.GetDefault("uuid", ""), tem_time)
		
		MP.SQL1.ExecNonQuery2(MP.deleteEvents ,array as string ( Paremeters))
		SelectedItems.Remove(CardSelectionKey(m))
		UpdateSelectionInfoLabel
		clv2.RemoveAt(Index)
	End If

End Sub


Sub B4XPage_Appear
	BindExportButton
	DisableSearchLoadingIndicator
	UpdateAdvancedSearchLayout
	UpdateExportButtonLayout
	B4XPages.SetTitle(Me, "Search (AND/OR + TXT导出)")

End Sub

Private Sub B4XPage_Resize (Width As Int, Height As Int)
	UpdateAdvancedSearchLayout
	UpdateExportButtonLayout

End Sub

Private Sub btnLogic1_Click
	ToggleLogicButton(btnLogic1)
End Sub

Private Sub btnLogic2_Click
	ToggleLogicButton(btnLogic2)
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
	Dim items As List
	items.Initialize
	For i = 0 To clv2.Size - 1
		items.Add(clv2.GetValue(i))
	Next
	ExportEventItems(items, "全部" & items.Size & "条搜索结果")
End Sub

Private Sub ExportEventItems (Items As List, ScopeLabel As String)
	If Items.IsInitialized = False Or Items.Size = 0 Then
		xui.MsgboxAsync("当前没有可导出的内容。", "导出TXT")
		Return
	End If

	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("MySuperNote Search Export").Append(CRLF)
	sb.Append("Query: ").Append(CurrentKeyword).Append(CRLF)
	sb.Append("Logic: ").Append(CurrentSearchExpression.GetDefault("display", CurrentKeyword)).Append(CRLF)
	sb.Append("Scope: ").Append(ScopeLabel).Append(CRLF)
	sb.Append("Count: ").Append(Items.Size).Append(CRLF).Append(CRLF)

	For i = 0 To Items.Size - 1
		Dim m As Map = Items.Get(i)
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
		xui.MsgboxAsync("已导出为 TXT（UTF-8）：" & ScopeLabel, "导出TXT")
	End If
	#Else
	xui.MsgboxAsync("已导出为 TXT（UTF-8）：" & ScopeLabel & CRLF & File.Combine(xui.DefaultFolder, fileName), "导出TXT")
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