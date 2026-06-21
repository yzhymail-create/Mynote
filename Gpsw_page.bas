B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	'Constants for Map Strings
	Private CONST cName 	As String = "Name"
	Private CONST cMinLen 	As String = "MinLen"
	
	Private CONST cDigit 	As String = "bDigit"
	Private CONST cUpper 	As String = "bUpper"
	Private CONST cLower 	As String = "bLower"
	Private CONST cSpecial 	As String = "bSpecial"
	Private CONST cSymbols 	As String = "bSymbols"
	Private CONST cInclude 	As String = "sInclude"
	Private CONST cBracket 	As String = "sBracket"
	
	Public mapPreDefined As Map

	'RandomPassword
	Private btnRandomPassword As Button
	Private cbxBrackets As CheckBox
	Private cbxDigits As CheckBox
	Private cbxDontUse As CheckBox
	Private cbxInclude As CheckBox
	Private cbxLower As CheckBox
	Private cbxSpecial As CheckBox
	Private cbxSymbols As CheckBox
	Private cbxUpper As CheckBox

	Private cboPreDefined As B4XComboBox
	Private SpnSel As Spinner
	Private tfInclude As B4XFloatTextField
	#if B4A
	Private Sel_Value As Int = 6
	#end if
	Private LblGrade As Label
	Private tfRandomYourPassword As B4XView
	#IF B4J
	Private fx As JFX
	#END IF
	Public pbPasswdStrenght As ProgressBar
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("gpsw")
	B4XPages.SetTitle(Me,"Generate Password")
	'load the layout to Root
	#if b4a
	Dim Items As List
	Items.Initialize
	For i= 6 To 70
		Items.Add(i)
	Next
    SpnSel.AddAll(Items)
	#end if
	
	#if b4j
     SpnSel.Value = 8
	#end if
	FillPreDefined
End Sub



Sub cbxInclude_CheckedChange(Checked As Boolean)
	If Checked = True Then tfInclude.Focused = True
End Sub

Private Sub cboPreDefined_SelectedIndexChanged (Index As Int)
	Dim mapValues As Map
	mapValues.Initialize
	mapValues = mapPreDefined.GetValueAt(Index)
	cbxUpper.Checked = mapValues.GetDefault( cUpper, False)
	cbxLower.Checked = mapValues.GetDefault( cLower, False)
	cbxDigits.Checked =mapValues.GetDefault( cDigit, False)
	cbxSymbols.Checked = mapValues.GetDefault( cSymbols, False)
	cbxSpecial.Checked = mapValues.GetDefault( cSpecial, False)
	If mapValues.GetDefault( cInclude, "") <> Null Then
		cbxInclude.Checked = True
		tfInclude.Text = mapValues.GetDefault( cInclude, "")
	Else
		cbxInclude.Checked = False
	End If
	#if b4a
	Sel_Value = mapValues.GetDefault( cMinLen, 6)
	#else if b4j
	 SpnSel.Value = mapValues.GetDefault( cMinLen, 6)
	#end if
	btnRandomPassword.RequestFocus
End Sub



Sub FillPreDefined
	Dim mapValues As Map
	mapValues.Initialize
	mapPreDefined.Initialize
	'äöüÄÖÜ@<({[/=\]})>!?$%&#*-+.,;:_
	mapValues = CreateMap( cName:"None", cMinLen:4, cLower:False, cUpper:False, cDigit:False, cSymbols:False, cSpecial:False, cBracket:False,cInclude:"")
	mapPreDefined.Put( "None", mapValues)

	mapValues = CreateMap( cName:"Internet 10", cMinLen:10, cLower:True, cUpper:True, cDigit:True, cSymbols:False, cSpecial:False, cInclude:"$%&#-_")
	mapPreDefined.Put( "Internet 10", mapValues)
	
	mapValues = CreateMap( cName:"Internet 12", cMinLen:12,  cLower:True, cUpper:True, cDigit:True, cSymbols:False, cSpecial:False, cInclude:"$%&#-_")
	mapPreDefined.Put( "Internet 12", mapValues)

	mapValues = CreateMap( cName:"WAP2", cMinLen:63, cLower:True, cUpper:True, cDigit:True, cSymbols:False, cSpecial:False, cInclude:"")
	mapPreDefined.Put( "WAP2", mapValues)
	
	mapValues = CreateMap( cName:"very strong", cMinLen:8,  cLower:True, cUpper:True, cDigit:True, cSymbols:True, cSpecial:True, cBracket:False,cInclude:"")
	mapPreDefined.Put( "very strong", mapValues)

	mapValues = CreateMap( cName:"Letters", cMinLen:8, cLower:True, cUpper:True, cDigit:False, cSymbols:False, cSpecial:False, cInclude:"-_")
	mapPreDefined.Put( "Letters", mapValues)
	
	Dim Items As List
	Items.Initialize
	For Each k As String In mapPreDefined.Keys
			Items.Add(k)
	Next
	cboPreDefined.SetItems(Items)
End Sub

Sub GeneratePassword( MinLen As Int, bUpper As Boolean, bLower As Boolean, bSpecial As Boolean, bDigit As Boolean, bSymbols As Boolean,bBracket  As Boolean, bDontUse As Boolean,sInclude As String) As String
	Dim RetPassword As String
	Dim Pool As String = ""
	Dim AlphaL As String = "abcdefghijklmnopqrstuvwxyz"
	Dim AlphaU As String = AlphaL.ToUpperCase
	Dim Digits As String = "0123456789"
	Dim Special As String = "ßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ"
	Dim Symbols As String = "!#%&'*,-./:;?@\_|¦§$°µ+²³"
	Dim Brackets As String = "()[]{}"
	Dim PoolList As List
	PoolList.Initialize
	Dim Poolstring As String
	Dim l As List
	l.Initialize

	If bDontUse Then	
		Dim AlphaL As String = "abcdefghjkmnpqrstuvwxyz"
		Dim Digits As String = "23456789"
	End If
	
	If sInclude <> "" Then
		PoolList.Add(sInclude)
		Poolstring = Poolstring & sInclude
	End If
	
	If bLower Then
		PoolList.Add(AlphaL.CharAt(Rnd(0, AlphaL.length-1)))
		Poolstring = Poolstring & AlphaL.CharAt(Rnd(0,AlphaL.length-1))
		l.Add( AlphaL)

	End If
	If bUpper Then
		PoolList.Add( AlphaU.CharAt(Rnd(0,AlphaL.length-1)))
		Poolstring = Poolstring & AlphaU.CharAt(Rnd(0,AlphaL.length-1))
		l.Add( AlphaU)

	End If
	If bDigit Then
		PoolList.Add( Digits.CharAt(Rnd(0,Digits.Length-1)))
		Poolstring = Poolstring & Digits.CharAt(Rnd(0,Digits.Length-1))
		l.Add( Digits)

	End If
	If bBracket Then
		PoolList.Add( Brackets.CharAt(Rnd(0,Brackets.Length-1)))
		Poolstring = Poolstring & Brackets.CharAt(Rnd(0,Brackets.Length-1))

	End If
	If bSymbols Then
		PoolList.Add( Symbols.CharAt(Rnd(0,Symbols.Length-1)))
		Poolstring = Poolstring & Symbols.CharAt(Rnd(0,Symbols.Length-1))

	End If
	If bSpecial Then
		PoolList.Add( Special.CharAt(Rnd(0,Special.Length-1)))
		Poolstring = Poolstring & Special.CharAt(Rnd(0,Special.Length-1))

	End If
	
	If Poolstring.Length < 1 Then
		#if b4a
		ToastMessageShow("NO SET !",True)
		#end if
		xui.MsgboxAsync("NO SET !",True)
		Return ""
	End If
	
	Dim pwLen As Int = MinLen
	Dim tem As Int
	
	If Poolstring.Length >= pwLen Then	
	
		Do Until RetPassword.Length = pwLen
			If PoolList.Size > 1 Then
			 tem = Rnd(0,PoolList.Size-1)
			Else
			 tem = 0
			End If
			Pool = PoolList.Get(tem)
			PoolList.RemoveAt(tem)
			RetPassword = RetPassword & Pool
		Loop
	Else
		Do Until RetPassword.Length =  Poolstring.Length
			If PoolList.Size > 1 Then
				tem = Rnd(0,PoolList.Size-1)
			Else
				tem = 0
			End If
			Pool = PoolList.Get(tem)
			PoolList.RemoveAt(tem)
			RetPassword = RetPassword & Pool
		Loop
		Dim RetPassword2 As String
		Do Until RetPassword2.Length = (pwLen-RetPassword.Length)
			Pool = l.Get(Rnd(0,l.Size-1))
			RetPassword2 = RetPassword2 & Pool.CharAt( Rnd( 0, Pool.Length-1))
		Loop
		RetPassword = RetPassword &  RetPassword2
	End If

	Return RetPassword
End Sub


private Sub ShowPasswordStrenght(Strenght As Int)
	pbPasswdStrenght.Progress = 0
	Dim sGrade	As String = ""
	Select True
		#if b4a
		Case Strenght < 20
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Red)
			sGrade = "F--"
		Case Strenght < 40
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Red)
			sGrade = "F"
		Case Strenght < 60
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Yellow)
			sGrade = "E"
		Case Strenght < 80
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Yellow)
			sGrade = "D"
		Case Strenght < 100
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Yellow)
			sGrade = "C"
		Case Strenght < 140
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_Yellow)
			sGrade = "B"
		Case Strenght < 200
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_GREEN)
			sGrade = "A"
		Case Strenght >= 200
			pbPasswdStrenght.SetColorAnimated(1000,xui.Color_Black,xui.Color_GREEN)
			sGrade = "A++"
		#end if
		
		#if b4j
		Case Strenght < 20
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: red;"
			sGrade = "F--"
		Case Strenght < 40
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: red;"
			sGrade = "F"
		Case Strenght < 60
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: orange;"
			sGrade = "E"
		Case Strenght < 80
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: orange;"
			sGrade = "D"
		Case Strenght < 100
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: yellow;"
			sGrade = "C"
		Case Strenght < 140
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: yellow;"
			sGrade = "B"
		Case Strenght < 200
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: green;"
			sGrade = "A"
		Case Strenght >= 200
			pbPasswdStrenght.Style = "-fx-box-border: black; -fx-accent: green;"
			sGrade = "A++"
		#End If
		
	End Select
	
	If  sGrade <>"" Then
	pbPasswdStrenght.Progress = ( Strenght /200)
	LblGrade.Text = sGrade
	Else
		#IF B4A
		ToastMessageShow("NO DATA !",True)
		#ELSE IF B4J
		xui.MsgboxAsync("NO DATA !",True)
		#END IF
	End If 
End Sub



'Sub RemoveDontUseChars(Password As String, sDontUse As String) As String
'	For i = 0 To sDontUse.Length -1
'		Password = Password.Replace(sDontUse.CharAt(i), "")
'	Next
'	Return Password
'End Sub



'0-25 		F--	deficient Dont use
'20-45		F	poor
'40-65		E	sufficient	
'60-85		D	satisfactory
'80-120		C	good
'100-145	B	strong enough
'140-200	A	very strong
'200+		A++	best choice
Sub CheckPasswordStrenght( Password As String) As Int
	'according to an idea by:
	'http://www.passwordmeter.com/

	Dim CountChars 		As Int = Password.Length

	Dim hasDigits 		As Boolean = Regex.IsMatch( ".*\d.*", Password)
	Dim hasUpperCases 	As Boolean = Regex.IsMatch( ".*\p{Lu}.*", Password)
	Dim hasLowerCases 	As Boolean = Regex.IsMatch( ".*\p{Ll}.*", Password)
	Dim hasSymbols 		As Boolean = Regex.IsMatch( ".*\p{P}.*", Password)
	
	Dim OnlyDigits 		As Boolean = Regex.IsMatch( "\d+", Password)
	Dim OnlyUpperCases 	As Boolean = Regex.IsMatch( "\p{Lu}+", Password)
	Dim OnlyLowerCases 	As Boolean = Regex.IsMatch( "\p{Ll}+", Password)
	Dim OnlyLetters		As Boolean = Regex.IsMatch( "\p{L}+", Password)
	
	Dim Digits3Times 	As Boolean = Regex.IsMatch( ".*\d{3,}.*", Password)
	Dim Upper3Times		As Boolean = Regex.IsMatch( ".*\p{Lu}{3,}.*", Password)
	Dim Lower3Times		As Boolean = Regex.IsMatch( ".*\p{Ll}{3,}.*", Password)
	Dim Letters3Times	As Boolean = Regex.IsMatch( ".*\p{L}{3,}.*", Password)
	
	Dim Strenght 		As Int = 0
	
	Strenght = Strenght +( CountChars*4)
	If CountChars > 11 Then Strenght = Strenght +( CountChars*4)
	
	If hasDigits Then
		Dim nDigits As Int = CountMatches( "\d", Password)
		Strenght = Strenght +(nDigits*4)
	End If
	If hasUpperCases Then
		Dim nUpper As Int = CountMatches( "\p{Lu}", Password)
		Strenght = Strenght +(( CountChars-nUpper)*2)
	End If
	If  hasLowerCases Then
		Dim nLower As Int = CountMatches( "\p{Ll}", Password)
		Strenght = Strenght +(( CountChars-nLower)*2)
	End If
	If hasSymbols Then
		Dim nSpecial As Int = CountMatches( "\p{P}", Password)
		Strenght = Strenght +(nSpecial*6)
	End If
	If hasDigits And hasLowerCases And hasUpperCases And hasSymbols Then
		Strenght = Strenght +((nDigits+nUpper+nLower+nSpecial) *2)
	End If
	
	If OnlyDigits 		Then Strenght = Strenght - nDigits
	If OnlyUpperCases 	Then Strenght = Strenght - nUpper
	If OnlyLowerCases 	Then Strenght = Strenght - nLower
	If OnlyLetters 		Then Strenght = Strenght - (nUpper+nLower)
	If Digits3Times 	Then Strenght = Strenght - (nDigits *3)
	If Upper3Times		Then Strenght = Strenght - (nUpper *3)
	If Lower3Times		Then Strenght = Strenght - (nLower *3)
	If Letters3Times 	Then Strenght = Strenght - ((nLower+nUpper) *3)

	If Strenght < 0 Then Strenght = 0
	Return Strenght
End Sub

Sub CountMatches( Match As String, toMatch As String) As Int
	Dim nCount As Int = 0
	Dim mt As Matcher
	mt = Regex.Matcher( Match, toMatch)
	Do While mt.Find
		nCount=nCount+1
	Loop
	Return nCount
End Sub
#End Region


Private Sub Bntcopy_Click
	#if b4a
	Dim CP As BClipboard
	CP.clrText
	CP.setText(tfRandomYourPassword.text)
	#end if 
	#if b4j
	fx.Clipboard.SetString(tfRandomYourPassword.text)
	#End If
End Sub

#if B4A
Private Sub SpnSel_ItemClick (Position As Int, Value As Object)
	Sel_Value = Value
End Sub
#END IF

 Sub btnRandomPassword_Click
	Dim Strenght As Int = 0
	Dim Password As String = ""
	Dim sInclude As String = ""
'	Dim sDontUse As String = ""
'	If cbxDontUse.Checked Then sDontUse = "iILl10oO"
	If cbxInclude.Checked Then sInclude = tfInclude.Text


#if b4a
	Password = GeneratePassword(Sel_Value, cbxUpper.Checked, cbxLower.Checked, cbxSpecial.Checked, cbxDigits.Checked, cbxSymbols.Checked,cbxBrackets.Checked, cbxDontUse.Checked, sInclude)
#end if
#if b4j
	Password = GeneratePassword(SpnSel.Value, cbxUpper.Checked, cbxLower.Checked, cbxSpecial.Checked, cbxDigits.Checked, cbxSymbols.Checked, cbxBrackets.Checked, cbxDontUse.Checked,sInclude)
#End If
	tfRandomYourPassword.Text = Password
	Strenght = CheckPasswordStrenght( Password)
	ShowPasswordStrenght(Strenght)
End Sub

