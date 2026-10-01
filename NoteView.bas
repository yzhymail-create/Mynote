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
	Private PageData As B4XPageData
	Private Search_view As Search
	Private ToastMessage As BCToast
	#if b4a
	'Private IME As IME
	Private Const OkChar As String = Chr(0xF14A)
	Private Btx3 As B4XView
	#END IF
	
	#IF B4J
    Private BntOK As Button
	'Private Drawer As B4XDrawer
	Private Btx3 As B4XView
	#END IF
	
	Private LabTime As B4XView
	Private LabTime2 As B4XView
	Private Btx1 As B4XFloatTextField
	Private Btx2 As B4XFloatTextField
	Private wvSearchPreview As WebView
	Private SearchPreviewActive As Boolean
	Private SearchAnchorInserted As Boolean
	Private Ok_Flag = False As Boolean
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root.LoadLayout("ViewCard")
	PageData = B4XPages.GetPage("B4XPageData")
	Search_view = B4XPages.GetPage("Search")
	MP = B4XPages.MainPage
	B4XPages.SetTitle(Me,"Note")
	ToastMessage.Initialize(Root)
	#if b4j
	'Drawer.Initialize(Me, "Drawer", Root, 200dip)
	#end if
'	Drawer.CenterPanel.LoadLayout("DataCards")
'	Drawer.LeftPanel.LoadLayout("Page2Left")
	#if B4A
	'IME.Initialize("IME")
	#END IF
	wvSearchPreview.Initialize("wvSearchPreview")
	Root.AddView(wvSearchPreview, Btx3.Left, Btx3.Top, Btx3.Width, Btx3.Height)
	wvSearchPreview.Visible = False
	ConfigureTimeLabels
	CreateMenu
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

#if b4j
Private Sub BntOK_Click
	
		Ok_Flag = True
		If Btx1.Text="" Or Btx1.Text="" Or Btx1.Text="" Then
			ToastMessage.Show("请完整填写登录信息！")
		Else
			Dim sf As Object = xui.Msgbox2Async("Save ?", "", "Yes", "Cancel", "", Null)
			Wait For (sf) Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				Dim timestamp As String = DateTime.Now
				Dim NowTime As String = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
				If PageData.Add_Flag = True Then
					PageData.note_Paremeters = Array As String(B4XPages.MainPage.KVS.Get("id_user"),PageData.Nowday_Month,Btx1.Text,Btx3.Text,Btx2.Text, PageData.Nowday_Year,NowTime,timestamp,False,True,False)
				End If
				If PageData.Edit_Flag = True Then
					Dim Rowid As Long = MP.ResolveEventRowIdFromMap(PageData.Show_m)
					If Rowid > 0 Then
						MP.EnsureEventUuidForRow(Rowid)
						'get the state of syc_flag
						Dim Query As String = "SELECT sync_flag from events WHERE rowid = ?"
						Dim tem_sync_flag As String = MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Rowid))
						If tem_sync_flag = True Then
							Dim tem_changed As Boolean = True
						Else
							Dim tem_changed As Boolean = False
						End If
						PageData.note_Paremeters = Array As String(Btx1.Text, Btx3.Text, Btx2.Text,MP.BuildTagsPayload(Btx1.Text, Btx3.Text, Btx2.Text),MP.BuildAttachmentsPayload(Btx1.Text, Btx3.Text, Btx2.Text),timestamp,tem_changed,Rowid)
					Else
						ToastMessage.Show("ERROR！")
					End If
				End If
					
				PageData.Re_Flag = True
				Btx1.Text=""
				Btx2.Text=""
				Btx3.Text=""
				B4XPages.ClosePage(Me)
				B4XPages.ShowPage("B4XPageData")

			End If
		
	End If
'If Btx1.Text="" Or Btx1.Text="" Or Btx1.Text="" Then
'	ToastMessage.Show("请完整填写登录信息！")
'Else
'    
'	Dim sf As Object = xui.Msgbox2Async("Save ?", "", "Yes", "Cancel", "", Null)
'	Wait For (sf) Msgbox_Result (Result As Int)
'	If Result = xui.DialogResponse_Positive Then
'		Dim timestamp As String = DateTime.Now
'		Dim NowTime As String = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
'		If PageData.Add_Flag = True Then
'				PageData.note_Paremeters = Array As String(MP.KVS.Get("id_user"),PageData.Nowday_Month,Btx1.Text,Btx3.Text,Btx2.Text, PageData.Nowday_Year,NowTime,timestamp,False,True,False)
'		End If
'		If PageData.Edit_Flag = True Then
'			'get the rowid
'			Dim time As String = PageData.Show_m.Get("time")
'			Dim  ResultSet1 As ResultSet
'			Dim Query As String = "SELECT RowId FROM events WHERE time = ?"
'			ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (time))
'				Do While ResultSet1.NextRow
'					Dim Rowid As Int = ResultSet1.Getint2(0)
'				Loop
'			ResultSet1.Close
'		If Rowid > 0 Then
'			'get the state of syc_flag
'			Dim tem_changed As Boolean  = False
'			Query = "SELECT sync_flag from events WHERE rowid = ?"
'			Dim tem_sync_flag As String = MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Rowid))
'			If tem_sync_flag = True Then
'				 
'				 tem_changed  = True
'			Else
'				 tem_changed  = False
'			End If 
'			PageData.note_Paremeters = Array As String(Btx1.Text, Btx3.Text, Btx2.Text,timestamp,tem_changed,Rowid)
'	    Else
'			  ToastMessage.Show("ERROR！")
'		   End If 
'		End If
'			
'		PageData.Re_Flag = True
'		Btx1.Text=""
'		Btx2.Text=""
'		Btx3.Text=""
'			
'		B4XPages.ClosePage(Me)
'		B4XPages.ShowPage("B4XPageData")
'	End If
'	
'End If

End Sub
#end if


Sub B4XPage_Appear
	DisableSearchHighlightPreview
	If PageData.Edit_Flag = True Then
		Btx1.Text = PageData.Show_m.Get("event_type")
		Btx2.Text = PageData.Show_m.Get("value")
		Sleep(0)
		Btx3.Text = PageData.Show_m.Get("description")
		SetFooterTimeDisplay(PageData.Show_m.Get("time"), PageData.Show_m.GetDefault("lunar_text", ""))
		
	Else If Search_view.Edit_Flag = True Then
		Btx1.Text = Search_view.Show_m.Get("event_type")
		Btx2.Text = Search_view.Show_m.Get("value")
		SetFooterTimeDisplay(Search_view.Show_m.Get("time"), Search_view.Show_m.GetDefault("lunar_text", ""))
		Sleep(0)
		Btx3.Text = Search_view.Show_m.Get("description")
		ApplySearchHit(Search_view.Show_m)

	Else If PageData.add_Flag = True Then
		Btx1.Text = ""
		Btx2.Text = ""
		Btx3.Text = ""
		SetFooterTimeDisplay(BuildCurrentEventTime, "")
	End If
	#If B4A
	If SearchPreviewActive = False Then EnsureEditorCaretVisible
	#End If
	Ok_Flag = False
End Sub

Private Sub ConfigureTimeLabels
	If LabTime.IsInitialized = False Then Return
	LabTime.TextColor = xui.Color_Gray
	ConfigureFooterLabel(LabTime)
	If LabTime2.IsInitialized Then
		LabTime2.TextColor = xui.Color_Gray
		ConfigureFooterLabel(LabTime2)
	End If
End Sub

Private Sub SetFooterTimeDisplay (RawTime As String, LunarText As String)
	Dim resolvedLunar As String = MP.ResolveEventLunarText(RawTime, LunarText)
	LabTime.Text = RawTime
	If LabTime2.IsInitialized Then
		LabTime2.Text = resolvedLunar
	Else
		LabTime.Text = MP.BuildEventDisplayTime(RawTime, resolvedLunar)
	End If
End Sub

Private Sub ConfigureFooterLabel(TargetLabel As B4XView)
	#If B4A
	Dim lbl As Label = TargetLabel
	lbl.SingleLine = False
	#Else If B4J
	Dim lbl As Label = TargetLabel
	lbl.WrapText = True
	#End If
	Dim minHeight As Int = 22dip
	If TargetLabel.Height < minHeight Then
		TargetLabel.SetLayoutAnimated(0, TargetLabel.Left, TargetLabel.Top, TargetLabel.Width, minHeight)
	End If
End Sub

Private Sub BuildCurrentEventTime As String
	Return DateTime.Date(DateTime.Now) & "_" & DateTime.Time(DateTime.Now) & "_" & DateUtils.GetDayOfWeekName(DateTime.Now)
End Sub

Private Sub ApplySearchHit (SearchMap As Map)
	If SearchMap.IsInitialized = False Then Return
	Dim keyword As String = SearchMap.GetDefault("kw", "")
	Dim hitField As String = SearchMap.GetDefault("hit_field", "")
	Dim hitStart As Int = SearchMap.GetDefault("hit_start", -1)
	If keyword = "" Or hitStart < 0 Then
		DisableSearchHighlightPreview
		Return
	End If
	EnableSearchHighlightPreview(keyword, hitField)
End Sub

Private Sub EnableSearchHighlightPreview (Keyword As String, HitField As String)
	If Keyword = "" Then
		DisableSearchHighlightPreview
		Return
	End If
	SearchAnchorInserted = False
	UpdateSearchPreviewLayout
	wvSearchPreview.LoadHtml(BuildSearchPreviewHtml(Keyword, HitField))
	wvSearchPreview.Visible = True
	Btx3.Visible = False
	SearchPreviewActive = True
	Root.GetView(Root.NumberOfViews - 1).BringToFront
End Sub

Private Sub DisableSearchHighlightPreview
	SearchPreviewActive = False
	If wvSearchPreview.IsInitialized Then wvSearchPreview.Visible = False
	If Btx3.IsInitialized Then Btx3.Visible = True
End Sub

Private Sub UpdateSearchPreviewLayout
	If wvSearchPreview.IsInitialized = False Then Return
	Dim webViewContainer As B4XView = wvSearchPreview
	webViewContainer.SetLayoutAnimated(0, Btx3.Left, Btx3.Top, Btx3.Width, Btx3.Height)
End Sub

Private Sub BuildSearchPreviewHtml (Keyword As String, HitField As String) As String
	Dim typeHtml As String = BuildHighlightedHtmlBlock(Btx1.Text, Keyword, HitField = "event_type")
	Dim valueHtml As String = BuildHighlightedHtmlBlock(Btx2.Text, Keyword, HitField = "value")
	Dim descHtml As String = BuildHighlightedHtmlBlock(Btx3.Text, Keyword, HitField = "description")
	Dim html As String = $"<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'/>
<style>
body { font-family: sans-serif; padding: 8px; margin: 0; background: #ffffff; color: #111111; }
.mode { background: #eef6ff; border-left: 4px solid #2d7ff9; padding: 8px 10px; margin-bottom: 10px; font-size: 13px; }
.section-title { margin-top: 10px; margin-bottom: 4px; font-weight: bold; color: #3a3a3a; }
.content { white-space: pre-wrap; word-wrap: break-word; line-height: 1.55; }
mark { background: #fff176; color: #000000; padding: 0 1px; }
</style>
</head>
<body>
<div class='mode'>搜索查看状态：当前关键字会保持高亮；离开此页面后自动退出搜索高亮。</div>
<div class='section-title'>Type</div>
<div class='content'>${typeHtml}</div>
<div class='section-title'>Value</div>
<div class='content'>${valueHtml}</div>
<div class='section-title'>Description</div>
<div class='content'>${descHtml}</div>
<script>
window.onload = function() {
  var el = document.getElementById('search-hit-target');
  if (el) { el.scrollIntoView(); }
};
</script>
</body>
</html>"$
	Return html
End Sub

Private Sub BuildHighlightedHtmlBlock (Source As String, Keyword As String, AnchorThisBlock As Boolean) As String
	If Source = Null Then Source = ""
	If Keyword = "" Then Return HtmlEncode(Source)
	Dim matches As List = FindMatches(Source, Keyword)
	If matches.Size = 0 Then Return HtmlEncode(Source)
	Dim sb As StringBuilder
	sb.Initialize
	Dim cursor As Int = 0
	For Each startIndex As Int In matches
		If startIndex > cursor Then sb.Append(HtmlEncode(Source.SubString2(cursor, startIndex)))
		Dim endIndex As Int = Min(Source.Length, startIndex + Keyword.Length)
		Dim markId As String = ""
		If AnchorThisBlock And SearchAnchorInserted = False Then
			markId = " id='search-hit-target'"
			SearchAnchorInserted = True
		End If
		sb.Append("<mark" & markId & ">")
		sb.Append(HtmlEncode(Source.SubString2(startIndex, endIndex)))
		sb.Append("</mark>")
		cursor = endIndex
	Next
	If cursor < Source.Length Then sb.Append(HtmlEncode(Source.SubString(cursor)))
	Return sb.ToString
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

Private Sub HtmlEncode (Text As String) As String
	If Text = Null Then Return ""
	Text = Text.Replace("&", "&amp;")
	Text = Text.Replace("<", "&lt;")
	Text = Text.Replace(">", "&gt;")
	Text = Text.Replace(QUOTE, "&quot;")
	Text = Text.Replace("'", "&#39;")
	Return Text.Replace(CRLF, "<br/>").Replace(Chr(13), "<br/>").Replace(Chr(10), "<br/>")
End Sub

#If B4A
Private Sub EnsureEditorCaretVisible
	If Btx3.IsInitialized = False Then Return
	If SearchPreviewActive Then Return
	Dim et As EditText = Btx3
	Dim jo As JavaObject = et
	Dim rawLayout As Object = jo.RunMethod("getLayout", Null)
	If rawLayout = Null Then Return
	Dim layout As JavaObject = rawLayout
	Dim cursor As Int = jo.RunMethod("getSelectionStart", Null)
	If cursor < 0 Then cursor = et.Text.Length
	Dim line As Int = layout.RunMethod("getLineForOffset", Array(cursor))
	Dim lineTop As Int = layout.RunMethod("getLineTop", Array(line))
	Dim lineBottom As Int = layout.RunMethod("getLineBottom", Array(line))
	Dim currentY As Int = jo.RunMethod("getScrollY", Null)
	Dim viewHeight As Int = et.Height
	Dim padding As Int = 24dip
	Dim targetY As Int = currentY
	If lineBottom > currentY + viewHeight - padding Then
		targetY = lineBottom - viewHeight + padding
	Else If lineTop < currentY + padding Then
		targetY = lineTop - padding
	End If
	Dim contentHeight As Int = layout.RunMethod("getHeight", Null)
	Dim maxY As Int = Max(0, contentHeight - viewHeight)
	targetY = Max(0, Min(maxY, targetY))
	If targetY <> currentY Then jo.RunMethod("scrollTo", Array(0, targetY))
End Sub

Private Sub Btx3_TextChanged (Old As String, New As String)
	EnsureEditorCaretVisible
End Sub

Private Sub Btx3_FocusChanged (HasFocus As Boolean)
	If HasFocus Then EnsureEditorCaretVisible
End Sub
#End If



Private Sub CreateMenu
	#if B4A
	Dim cs As CSBuilder
	Dim mi As B4AMenuItem
	mi = B4XPages.AddMenuItem(Me, cs.Initialize.Typeface(Typeface.FONTAWESOME).Size(30).Append(OkChar).PopAll)
	mi.AddToBar = True
	mi.Tag = "OK Event"
	#Else if B4i
	Dim bb As BarButton
	bb.InitializeSystem(bb.ITEM_REFRESH, "refresh")
	Dim bb2 As BarButton
	bb2.InitializeSystem(bb.ITEM_SEARCH, "search")
	Dim bb3 As BarButton
	bb3.InitializeSystem(bb.ITEM_ADD, "new post")
	B4XPages.GetNativeParent(Me).TopRightButtons = Array(bb2, bb, bb3)
'	#Else If B4J
'	Dim ivHamburger As ImageView
'	ivHamburger.Initialize("imgHamburger")
'	Drawer.CenterPanel.AddView(ivHamburger, 2dip, 2dip, 32dip, 32dip)
'	ivHamburger.PickOnBounds = True
	#end if
End Sub

#if b4a
Private Sub B4XPage_MenuClick (Tag As String)
	'Log(Tag)
	If Tag = "OK Event" Then
		Ok_Flag = True
		If Btx1.Text="" Or Btx1.Text="" Or Btx1.Text="" Then
			ToastMessage.Show("请完整填写登录信息！")
		Else
			Dim sf As Object = xui.Msgbox2Async("Save ?", "", "Yes", "Cancel", "", Null)
			Wait For (sf) Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				Dim timestamp As String = DateTime.Now
				Dim NowTime As String = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
				If PageData.Add_Flag = True Then
						PageData.note_Paremeters = Array As String(B4XPages.MainPage.KVS.Get("id_user"),PageData.Nowday_Month,Btx1.Text,Btx3.Text,Btx2.Text, PageData.Nowday_Year,NowTime,timestamp,False,True,False)
				End If
				If IsEditingExistingEvent Then
					Dim updateParams() As Object = BuildUpdateEventParameters(timestamp)
					If updateParams = Null Then
						ToastMessage.Show("ERROR！")
						Ok_Flag = False
						Return
					End If
					MP.SQL1.ExecNonQuery2(MP.updateEvents, updateParams)
					ClearEditFlags
				End If
					
				If PageData.Add_Flag Then PageData.Re_Flag = True
				Btx1.Text=""
				Btx2.Text=""
				Btx3.Text=""
				B4XPages.ClosePage(Me)
				B4XPages.ShowPage("B4XPageData")

		End If
	End If
End If
End Sub
#end if

Private Sub B4XPage_CloseRequest As ResumableSub

	DisableSearchHighlightPreview
	Return True
End Sub

Private Sub B4XPage_Disappear
	Dim timestamp As String = DateTime.Now
	DisableSearchHighlightPreview
	If PageData.Add_Flag = True And Ok_Flag = False Then
		
		Dim NowTime As String = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
	
		PageData.note_Paremeters = Array As String(B4XPages.MainPage.KVS.Get("id_user"),PageData.Nowday_Month,Btx1.Text,Btx3.Text,Btx2.Text, PageData.Nowday_Year,NowTime,timestamp,False,True,False)
		MP.SQL1.ExecNonQuery2(MP.addEvents, MP.NormalizeEventInsertParameters(PageData.Note_Paremeters))
		PageData.Add_Flag = False
	else if IsEditingExistingEvent And Ok_Flag = False Then
		Dim updateParams() As Object = BuildUpdateEventParameters(timestamp)
		If updateParams <> Null Then
			MP.SQL1.ExecNonQuery2(MP.updateEvents, updateParams)
		End If
		ClearEditFlags
	End If

End Sub

Private Sub B4XPage_Background

End Sub

Private Sub B4XPage_Resize (Width As Int, Height As Int)
	UpdateSearchPreviewLayout
	#If B4A
	If SearchPreviewActive = False Then EnsureEditorCaretVisible
	#End If
End Sub

#if b4j
Private Sub BntCancle_Click
	DisableSearchHighlightPreview
	PageData.Add_Flag = False
	PageData.Re_Flag = False
	PageData.Edit_Flag = False
	Search_view.Edit_Flag = False
	B4XPages.ClosePage(Me)
	B4XPages.ShowPage("B4XPageData")
End Sub
#end if



Private Sub Btx3_EnterPressed
	#IF B4A
	'IME.HideKeyboard
	#END IF
End Sub

Private Sub IsEditingExistingEvent As Boolean
	Return PageData.Edit_Flag Or Search_view.Edit_Flag
End Sub

Private Sub GetActiveEditMap As Map
	If Search_view.Edit_Flag Then Return Search_view.Show_m
	Return PageData.Show_m
End Sub

Private Sub BuildUpdateEventParameters (Timestamp As String) As Object()
	Dim currentEvent As Map = GetActiveEditMap
	If currentEvent.IsInitialized = False Then Return Null
	Dim Rowid As Long = MP.ResolveEventRowIdFromMap(currentEvent)
	If Rowid <= 0 Then Return Null
	MP.EnsureEventUuidForRow(Rowid)
	Dim Query As String = "SELECT sync_flag from events WHERE rowid = ?"
	Dim tem_sync_flag As String = MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Rowid))
	Dim tem_changed As Boolean = (tem_sync_flag = True)
	Dim rawTime As String = currentEvent.GetDefault("time", "")
	Dim lunarText As String = MP.ResolveEventLunarText(rawTime, currentEvent.GetDefault("lunar_text", ""))
	Return Array As Object(Btx1.Text, Btx3.Text, Btx2.Text, MP.BuildTagsPayload(Btx1.Text, Btx3.Text, Btx2.Text), MP.BuildAttachmentsPayload(Btx1.Text, Btx3.Text, Btx2.Text), Timestamp, tem_changed, lunarText, Rowid)
End Sub

Private Sub ClearEditFlags
	PageData.Edit_Flag = False
	Search_view.Edit_Flag = False
	PageData.Re_Flag = False
End Sub