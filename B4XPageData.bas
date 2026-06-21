B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private MP As B4XMainPage
	Private Dialog As B4XDialog
	Private Drawer As B4XDrawer
	Private HamburgerIcon As B4XBitmap
	Private clvData As CustomListView
	Private pmDate As B4XPlusMinus
	Private lblType As Label
	Private lblDescription As Label
	Private lblValue As Label
	Private lblEdit, lblDelete As Label
	#if b4a
	Private ion As Object
	#end if
	'Private PrefDialogEvents As PreferencesDialog
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
	#if B4J
	Private btnPlus,btnRefresh As B4XView
	#End If
	Public Nowday_Month As String
	Public Nowday_Year As String
	Private Select_Year As String

	Private btnDate As SwiftButton
	Private DateTemplate As B4XDateTemplate

	Public Note_Paremeters()  As String
	Public Re_Flag = False As Boolean
	Public Edit_Flag = False As Boolean
	Public Add_Flag = False As Boolean
	Public Show_m As Map
	Public Edit_Index As Int
	Private BntSearch As Button
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'Note_View = B4XPages.GetPage("NoteView")
	'load the layout to Root
	Dialog.Initialize (Root)
	Dialog.Title = "Mynote"
	MP = B4XPages.MainPage
	Drawer.Initialize(Me, "Drawer", Root, 200dip)
	Drawer.CenterPanel.LoadLayout("DataCards")
	Drawer.LeftPanel.LoadLayout("Page2Left")
	'B4XPages.SetTitle(Me,"Data Cards")
	B4XPages.SetTitle(Me,"Note")
	HamburgerIcon = CreateHamburgerIconBitmap(32dip, xui.Color_White)
	pmDate.SetStringItems(Array As String("January","February","March","April","May","June","July","August","September","Octomber","November","December"))
	
	
	DateTemplate.Initialize
	DateTemplate.MinYear = 2021
	DateTemplate.MaxYear = 2051
	
	Nowday_Year = DateTime.Getyear(DateTime.Now)
	Select_Year = Nowday_Year
	btnDate.xLBL.Text = Nowday_Year
	
'	Log("Today is " & DateTime.Getyear(DateTime.Now))
'	Log("Today is " & DateTime.GetMonth(DateTime.Now))
	'DateTime.DateFormat = "yyyyMMdd"
'	NowTime = DateTime.Date(DateTime.Now)&"_"&DateTime.time(DateTime.Now)&"_"&DateUtils.GetDayOfWeekName(DateTime.Now)
'	Log(NowTime)
	Dim month As String = DateTime.GetMonth(DateTime.Now)
	Select month
		Case "1"
			Nowday_Month = "January"
		Case "2"
			Nowday_Month = "February"
		Case "3"
			Nowday_Month = "March"
		Case "4"
			Nowday_Month = "April"
		Case "5"
			Nowday_Month = "May"
		Case "6"
			Nowday_Month = "June"
		Case "7"
			Nowday_Month = "July"
		Case "8"
			Nowday_Month = "August"
		Case "9"
			Nowday_Month = "September"
		Case "10"
			Nowday_Month = "Octomber"
		Case "11"
			Nowday_Month = "November"
		Case "12"
			Nowday_Month = "December"			
	End Select
	
	pmDate.SelectedValue = Nowday_Month
	pmDate.mCyclic = True
	#if B4j
	'PrefDialogEvents.Initialize(Root , "MyNote", GetDeviceLayoutValues.Width-10dip, GetDeviceLayoutValues.Height-100dip)
	'PrefDialogEvents.Initialize(Root , "MyNote", 300dip, 300dip)
	#end if
	
	#if B4a
	'PrefDialogEvents.Initialize(Root , "MyNote", GetDeviceLayoutValues.Width-10dip, GetDeviceLayoutValues.Height-300dip)
	'PrefDialogEvents.Initialize(Root, "MyNote", 60%x, 60%y)
	#end if
	
	CreateMenu
	PopulateCards(Select_Year,pmDate.SelectedValue)
	
	#if B4i
	Dim bb As BarButton
	bb.InitializeBitmap(HamburgerIcon, "hamburger")
	B4XPages.GetNativeParent(Me).TopLeftButtons = Array(bb)
	#Else If B4J
	Dim iv As ImageView
	iv.Initialize("imgHamburger")
	iv.SetImage(HamburgerIcon)
	Drawer.CenterPanel.AddView(iv, 2dip, 2dip, 32dip, 32dip)
	iv.PickOnBounds = True
	#end if
End Sub

Private Sub CreateHamburgerIconBitmap (Size As Int, LineColor As Int) As B4XBitmap
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, Size, Size)
	Dim cvs As B4XCanvas
	cvs.Initialize(p)
	Dim stroke As Float = Max(2dip, Size / 9)
	Dim margin As Float = Size * 0.22
	Dim startX As Float = margin
	Dim endX As Float = Size - margin
	Dim y1 As Float = Size * 0.28
	Dim y2 As Float = Size * 0.5
	Dim y3 As Float = Size * 0.72
	cvs.DrawLine(startX, y1, endX, y1, LineColor, stroke)
	cvs.DrawLine(startX, y2, endX, y2, LineColor, stroke)
	cvs.DrawLine(startX, y3, endX, y3, LineColor, stroke)
	Dim bmp As B4XBitmap = cvs.CreateBitmap
	cvs.Release
	Return bmp
End Sub
#if B4J
Sub imgHamburger_MouseClicked (EventData As MouseEvent)
	Drawer.LeftOpen = True
End Sub
#else if B4i
Private Sub B4XPage_MenuClick (Tag As String)
	If Tag = "hamburger" Then
		Drawer.LeftOpen = Not(Drawer.LeftOpen)
	End If
End Sub
#end if

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Sub PopulateCards (year As String,Month As String)
	clvData.Clear
	'Dim rs As DBResult
	Dim rs As ResultSet
	B4XLoadingIndicator1.Show
	Dim Paremeters()  As String = Array As String(year,Month,MP.KVS.Get("id_user") )
	Dim time As String
	rs = MP.SQL1.ExecQuery2(MP.getEvents,Paremeters)
	Dim  ResultSet1 As ResultSet
	Dim Query As String = "SELECT RowId FROM events WHERE time = ?"
	Dim id As Long
	Dim mapData As Map
	Dim p As B4XView
		Do While rs.NextRow
			 time = rs.GetString("time")
			 ResultSet1 = MP.SQL1.ExecQuery2(Query, Array As String (time))
			Do While ResultSet1.NextRow
				 id = ResultSet1.Getint2(0)
			Loop
			ResultSet1.Close
		        mapData = CreateMap("id":id,"event_type":rs.GetString("event_type"),"description":rs.GetString("description"),"value":rs.GetString("value"),"time":rs.GetString("time"))
				p = CreateCard(mapData)
				clvData.Add(p, mapData)
		Loop
		rs.Close
	B4XLoadingIndicator1.Hide
End Sub

Sub CreateCard (Data As Map) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	Dim height As Int = 200dip
	#if B4A
	If GetDeviceLayoutValues.ApproximateScreenSize < 4.5 Then height = 310dip
	#end if
	p.SetLayoutAnimated(0, 0, 0, clvData.AsView.Width, height)
	p.LoadLayout("Card")
	lblType.Text = Data.Get("event_type")
	lblDescription.Text = Data.Get("description")
	lblValue.Text = Data.Get("value")
	'We store the map in the tag properties to pass it to B4XPreferencesDialog when editing or deleting
	lblEdit.Tag = Data 
	lblDelete.Tag = Data
	Return p
End Sub

Private Sub pmDate_ValueChanged (Value As Object)
	PopulateCards(Select_Year,Value)
End Sub


#if B4J
Private Sub lblEdit_MouseClicked (EventData As MouseEvent)
#end if

#if b4a
Private Sub lblEdit_Click
#end if

	Edit_Index  = clvData.GetItemFromView(Sender)
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
	Dim Index As Int = clvData.GetItemFromView(Sender)
	Dim l As Label = Sender
	Dim m As Map = l.Tag
	Dim sf As Object = xui.Msgbox2Async("Delete event?", "WARNING !", "Yes", "Cancel", "No", Null)
	Wait For (sf) Msgbox_Result (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Dim Paremeters As String = m.Get("id")
		B4XLoadingIndicator1.Show
		'record this message in deltime tab in db 
		Dim Query As String  = "SELECT time from events WHERE rowid = ?" 
		Dim tem_time As String =  MP.SQL1.ExecQuerySingleResult2(Query,Array As String(Paremeters))
		MP.SQL1.ExecNonQuery2("INSERT INTO delevents VALUES(?,?)" ,Array As String(MP.KVS.Get("id_user"),tem_time))
		MP.SQL1.ExecNonQuery2(MP.deleteEvents ,Array As String(Paremeters))
		clvData.RemoveAt(Index)
		B4XLoadingIndicator1.Hide
	End If

End Sub

Private Sub AddCard
	Dim Data As Map = CreateMap()
	'By default, we will insert the card of the same month we're seeing. You can change it later
	Data.Put("month", pmDate.SelectedValue)

	MP.SQL1.ExecNonQuery2(MP.addEvents,Note_Paremeters)

	PopulateCards(Select_Year,pmDate.SelectedValue)
End Sub

Private Sub Update_Record
	MP.SQL1.ExecNonQuery2(MP.updateEvents,Note_Paremeters)
	PopulateCards(Select_Year,pmDate.SelectedValue)
End Sub



Private Sub B4XPage_Appear
	#if B4A
	Sleep(0)
	B4XPages.GetManager.ActionBar.RunMethod("setDisplayHomeAsUpEnabled", Array(True))
	Dim bd As BitmapDrawable
	bd.Initialize(HamburgerIcon)
	B4XPages.GetManager.ActionBar.RunMethod("setHomeAsUpIndicator", Array(bd))
	#End If
	If Re_Flag = True And Add_Flag = True Then
		AddCard
		Re_Flag = False
		Add_Flag = False
	Else If Re_Flag = True And Edit_Flag = True Then
		Update_Record
		Re_Flag = False
		Edit_Flag = False
	Else
		PopulateCards(Select_Year,pmDate.SelectedValue)
	End If
	
End Sub

Private Sub B4XPage_Disappear
	
	#if B4A
	B4XPages.GetManager.ActionBar.RunMethod("setHomeAsUpIndicator", Array(0))
	#end if

End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	#if B4A
	'home button
	If Main.ActionBarHomeClicked Then
		Drawer.LeftOpen = Not(Drawer.LeftOpen)
		Return False
	End If
	'back key
	If Drawer.LeftOpen Then
		Drawer.LeftOpen = False
		Return False
	End If

	#end if
	Return True
End Sub


Private Sub B4XPage_Background
	B4XPages.ShowPageAndRemovePreviousPages("Login_Page")
End Sub


Private Sub B4XPage_Resize (Width As Int, Height As Int)
	Drawer.Resize(Width, Height)
End Sub

Private Sub CreateMenu
	#if B4A
	Dim cs As CSBuilder
	Dim mi As B4AMenuItem
	mi = B4XPages.AddMenuItem(Me, cs.Initialize.Typeface(Typeface.FONTAWESOME).Size(25).Append(B4XPages.MainPage.PlusChar).PopAll)
	mi.AddToBar = True
	mi.Tag = "Add Event"
	Dim ni As B4AMenuItem
	ni = B4XPages.AddMenuItem(Me, cs.Initialize.Typeface(Typeface.FONTAWESOME).Size(25).Append(B4XPages.MainPage.SearChar).PopAll)
	ni.AddToBar = True
	ni.Tag = "Search Event"
	#Else if B4i
	Dim bb As BarButton
	bb.InitializeSystem(bb.ITEM_REFRESH, "refresh")
	Dim bb2 As BarButton
	bb2.InitializeSystem(bb.ITEM_SEARCH, "search")
	Dim bb3 As BarButton
	bb3.InitializeSystem(bb.ITEM_ADD, "new post")
	B4XPages.GetNativeParent(Me).TopRightButtons = Array(bb2, bb, bb3)
	#Else If B4J
	Dim ivHamburger As ImageView
	ivHamburger.Initialize("imgHamburger")
	Drawer.CenterPanel.AddView(ivHamburger, 2dip, 2dip, 32dip, 32dip)
	ivHamburger.PickOnBounds = True
	#end if
End Sub

#if b4a
Private Sub B4XPage_MenuClick (Tag As String)
	Log(Tag)
	If Tag = "Add Event" Then
		Log("Adding Event")
		Add_Flag = True
		B4XPages.ShowPage("NoteView")
	End If
	If Tag = "Search Event" Then
		B4XPages.ShowPage("Search")
	End If
End Sub
#end if

private Sub btnSignOut_Click
	Drawer.LeftOpen = False
	MP.KVS.Remove("user")
	MP.KVS.Remove("id_user")
	MP.etUser.Text = ""
	MP.etPass.Text = ""
	MP.check_in = False
	B4XPages.ShowPageAndRemovePreviousPages("MainPage")
End Sub

#if B4J
Private Sub BntSearch_MouseClicked (EventData As MouseEvent)
#else
Private Sub BntSearch_Click
#end if
	B4XPages.ShowPage("Search")
End Sub

#if B4J
Private Sub btnPlus_MouseClicked (EventData As MouseEvent)
	Add_Flag = True
	B4XPages.ShowPage("NoteView")
End Sub

Private Sub btnRefresh_MouseClicked (EventData As MouseEvent)
	PopulateCards(Select_Year,pmDate.SelectedValue)
End Sub
#end if

Private Sub btnDate_Click
	Wait For (Dialog.ShowTemplate(DateTemplate, "", "", "CANCEL")) Complete (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		btnDate.xLBL.Text = DateTime.GetYear(DateTemplate.Date)
		Select_Year = btnDate.xLBL.Text
	End If
End Sub

#if B4A
Private Sub BntRef_Click
	PopulateCards(Select_Year,pmDate.SelectedValue)
End Sub
#END IF

#if b4j
Private Sub Bntsyc_MouseClicked (EventData As MouseEvent)
#else
Private Sub Bntsyc_Click
#end if

	B4XPages.ShowPage("Synchorize")
    Sleep(0)
End Sub




Private Sub Bntpsw_Click
	B4XPages.ShowPage("Psw_Page")
End Sub

Private Sub BntGpsw_Click
	B4XPages.ShowPage("GPsw_Page")
End Sub

Private Sub Bntcsv_Click
	ExportTableToCSV
	#if b4a
	DateTime.DateFormat = "yyyyMMdd"
	Dim temname As String = "mynote" & "_"& DateTime.Date(DateTime.Now) & ".text"
	Dim in As InputStream = File.OpenInput(xui.DefaultFolder, "mynote.text")
	Wait For (SaveFile(in, "text/plain", temname)) Complete (Success As Boolean)
	in.Close
	If Success Then
		xui.MsgboxAsync("OK !","TO TEXT")
	End If
	'Log("File saved successfully? " & Success)
	#else
	xui.MsgboxAsync("文件已导出到: " & File.Combine(xui.DefaultFolder, "mynote.text"),"文件导出")
	#end if
	
End Sub

Private Sub ExportTableToCSV

	Dim su As StringUtils
	Dim RS As ResultSet
	RS = MP.SQL1.ExecQuery2("Select * FROM events WHERE id_user = ?", Array As String(MP.KVS.Get("id_user")))
	'Log(MP.KVS.Get("id_user"))
	Dim list1 As List
	list1.Initialize
	Dim cols() As String
	
	Do While RS.NextRow
		cols = Array As String(RS.GetString("event_type"),RS.GetString("value"),RS.GetString("description"), RS.GetString("time"))
		list1.Add(cols)
	Loop
	
	RS.Close
	su.SaveCSV(xui.DefaultFolder,"mynote.text", ",", list1)

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
	If -1 = Args(0) Then 'resultCode = RESULT_OK
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
