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
	Public Const APP_RELEASE_INDEX As Int = 7
	Public Const APP_LAST_UPDATE_TEXT As String = "2026-10-01"
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
	Public Const DB_SCHEMA_VERSION As Int = 3
	Public SQL1 As SQL
	Public const getEvents As String = "Select * FROM events WHERE  year = ? And month = ? And id_user = ? order by RowID desc"
	Public const updateEvents As String = "UPDATE events SET event_type = ?,description = ?,value = ?,tags = ?,attachments_json = ?,timestamp = ?,changed = ?,lunar_text = ? WHERE RowID = ?"
	Public const deleteEvents As String  = "DELETE FROM events WHERE rowid = ?"
	Public const addEvents As String = "INSERT INTO events (id_user,month,event_type,description,value,year,time,timestamp,sync_flag,new,changed,uuid,tags,attachments_json,created_at,updated_at,archived_at,lunar_text) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
	Public const addPsw As String = "INSERT INTO psw VALUES (?,?,?,?,?,?,?,?,?,?,?)"
	Public const sycEvents As String = "UPDATE events SET event_type = ?,description = ?,value = ?,tags = ?,attachments_json = ?,timestamp = ?,sync_flag = ?,new = ?,changed = ?,lunar_text = ? WHERE RowID = ?"
	Public const sycPsw As String = "UPDATE psw SET description = ?,username = ?,password = ?,email = ?,remark= ?,timestamp = ?,sync_flag = ?,new = ?,changed = ? WHERE RowID = ?"
	Public const searchEvents As String = "Select * FROM events WHERE  id_user = ? order by rowid desc"
	Private Const LEGACY_DB_NAME As String = "notesql.db"
	Private Const LATEST_DB_NAME As String = "notesql_v2.db"
	Private Const KVS_ACTIVE_DB_NAME As String = "active_db_name"
	Private Const KVS_LEGACY_DB_STATE As String = "legacy_db_state"
	Private Const LEGACY_STATE_PENDING As String = "pending"
	Private Const LEGACY_STATE_COMPLETED As String = "completed"
	Private ActiveDbName As String
	Private MigrationWorkflowHandled As Boolean
	Private pnlMigrationOverlay As B4XView
	Private lblMigrationStatus As B4XView
	Private Const LUNAR_BASE_YEAR As Int = 1901
	Private Const LUNAR_MAX_YEAR As Int = 2100

	Private BntForget As B4XView
	Private Bntmodify As B4XView
	Private Bntregist As B4XView
End Sub

Public Sub GetAppVersionText As String
	Return "第" & APP_RELEASE_INDEX & "版"
End Sub

'You can add more parameters here.
Public Sub Initialize
	B4XPages.GetManager.LogEvents = True
	jRDC.Initialize
	xui.SetDataFolder("mynote")
	EncDec.InitializationVector = "Q.6qYq0_C+mGmymX" 'Must be 16 characters in length
	EncDec.SecretKey = "3hba8fOumOPrMG0.G?-mkF-scGOkPwyW" 'Must be 16 or 32 characters in length

	KVS.Initialize(xui.DefaultFolder,"kvs") 'We use KVS to save the logged user (Usaremos KVS para guardar el usuario que inicia sesión)
	EnsureActiveDatabase
End Sub

Private Sub EnsureActiveDatabase
	ActiveDbName = KVS.GetDefault(KVS_ACTIVE_DB_NAME, "")
	If ActiveDbName <> "" And File.Exists(xui.DefaultFolder, ActiveDbName) Then
		OpenDatabase(ActiveDbName)
		If ActiveDbName = LATEST_DB_NAME Then
			CreateLatestSchema(SQL1)
			Return
		End If
	End If
	If File.Exists(xui.DefaultFolder, LATEST_DB_NAME) Then
		ActiveDbName = LATEST_DB_NAME
		OpenDatabase(ActiveDbName)
		CreateLatestSchema(SQL1)
		KVS.Put(KVS_ACTIVE_DB_NAME, ActiveDbName)
		Return
	End If
	If File.Exists(xui.DefaultFolder, LEGACY_DB_NAME) Then
		ActiveDbName = LEGACY_DB_NAME
		OpenDatabase(ActiveDbName)
		KVS.Put(KVS_ACTIVE_DB_NAME, ActiveDbName)
		Return
	End If
	ActiveDbName = LATEST_DB_NAME
	OpenDatabase(ActiveDbName)
	CreateLatestSchema(SQL1)
	KVS.Put(KVS_ACTIVE_DB_NAME, ActiveDbName)
End Sub

Private Sub OpenDatabase(DatabaseName As String)
	If SQL1.IsInitialized Then SQL1.Close
	#If B4J
	SQL1.InitializeSQLite(xui.DefaultFolder, DatabaseName, True)
	#Else
	SQL1.Initialize(xui.DefaultFolder, DatabaseName, True)
	#End If
End Sub

Private Sub CreateLatestSchema(Db As SQL)
	Db.ExecNonQuery("CREATE TABLE IF NOT EXISTS events (id_user TEXT, month TEXT, event_type TEXT, description TEXT, value TEXT, year TEXT, time TEXT PRIMARY KEY, timestamp TEXT, sync_flag BOOLEAN, new BOOLEAN, changed BOOLEAN, uuid TEXT, tags TEXT, attachments_json TEXT, created_at TEXT, updated_at TEXT, archived_at TEXT, lunar_text TEXT)")
	Db.ExecNonQuery("CREATE TABLE IF NOT EXISTS users (id_user TEXT PRIMARY KEY, password TEXT, name TEXT, nickname TEXT, level INTEGRE, active BOOLEAN)")
	Db.ExecNonQuery("CREATE TABLE IF NOT EXISTS psw (id_user TEXT, description TEXT, username TEXT, password TEXT, email TEXT, remark TEXT, time TEXT PRIMARY KEY, timestamp TEXT, sync_flag BOOLEAN, new BOOLEAN, changed BOOLEAN)")
	Db.ExecNonQuery("CREATE TABLE IF NOT EXISTS delevents (id_user TEXT, deltime TEXT)")
	Db.ExecNonQuery("CREATE TABLE IF NOT EXISTS delPSW (id_user TEXT, delpsw TEXT)")
	If HasColumn(Db, "delevents", "deluuid") = False Then
		Db.ExecNonQuery("ALTER TABLE delevents ADD COLUMN deluuid TEXT")
	End If
	If HasColumn(Db, "events", "lunar_text") = False Then
		Db.ExecNonQuery("ALTER TABLE events ADD COLUMN lunar_text TEXT")
	End If
	BackfillMissingEventLunarText(Db)
	Db.ExecNonQuery("CREATE UNIQUE INDEX IF NOT EXISTS idx_events_uuid ON events(uuid)")
	Db.ExecNonQuery("CREATE INDEX IF NOT EXISTS idx_events_user_month_year ON events(id_user, year, month)")
End Sub

Private Sub B4XPage_Appear
	If MigrationWorkflowHandled = False Then
		Wait For (HandleLegacyDatabaseWorkflow) Complete (Ready As Boolean)
		MigrationWorkflowHandled = True
	End If
	If KVS.ContainsKey("user") And BntHome_Flag= False Then  'If we've logged before, go directly to PageData
		User_Name = KVS.Get("user")
		B4XPages.ShowPageAndRemovePreviousPages("Login_Page")
	Else
		User_Name = ""
		BntHome_Flag= False
	End If
End Sub

Private Sub HandleLegacyDatabaseWorkflow As ResumableSub
	Dim legacyExists As Boolean = File.Exists(xui.DefaultFolder, LEGACY_DB_NAME)
	If legacyExists = False Then Return True
	Dim legacyInfo As Map = BuildLegacyDbInfo(LEGACY_DB_NAME)
	Dim legacyState As Map = GetLegacyDbState
	If ActiveDbName = LATEST_DB_NAME And legacyState.IsInitialized And legacyState.GetDefault("state", "") = LEGACY_STATE_COMPLETED Then
		If SameLegacySnapshot(legacyInfo, legacyState) Then
			Dim sfDelete As Object = xui.Msgbox2Async("The old database has already been migrated and has not changed. Delete the old database backup now?", "Legacy Database", "Delete", "Keep", "", Null)
			Wait For (sfDelete) Msgbox_Result (DeleteResult As Int)
			If DeleteResult = xui.DialogResponse_Positive Then
				File.Delete(xui.DefaultFolder, LEGACY_DB_NAME)
				legacyState.Put("cleanup_prompted", True)
				legacyState.Put("deleted", True)
				KVS.Put(KVS_LEGACY_DB_STATE, legacyState)
			End If
			Return True
		End If
	End If
	Dim needsMigration As Boolean
	If ActiveDbName = LEGACY_DB_NAME Then
		needsMigration = DatabaseNeedsMigration(SQL1)
	Else
		needsMigration = DatabaseNeedsMigrationByName(LEGACY_DB_NAME)
	End If
	If needsMigration = False Then Return True
	SaveLegacyDbState(legacyInfo, LEGACY_STATE_PENDING, "")
	Dim sf As Object = xui.Msgbox2Async("An old database format was detected. The app needs to migrate your data to the new structure before continuing. Start migration now?", "Database Migration", "Migrate", "Later", "", Null)
	Wait For (sf) Msgbox_Result (Result As Int)
	If Result = xui.DialogResponse_Positive Then
		Wait For (MigrateLegacyDatabase(legacyInfo, LEGACY_DB_NAME)) Complete (Success As Boolean)
		If Success Then
			xui.MsgboxAsync("Migration completed. The old database was kept as a backup. Next time you open the app, you can choose whether to delete it.", "Database Migration")
		End If
	End If
	Return True
End Sub

Private Sub DatabaseNeedsMigrationByName(DatabaseName As String) As Boolean
	Dim db As SQL
	Dim needsMigration As Boolean = False
	Try
		#If B4J
		db.InitializeSQLite(xui.DefaultFolder, DatabaseName, True)
		#Else
		db.Initialize(xui.DefaultFolder, DatabaseName, True)
		#End If
		needsMigration = DatabaseNeedsMigration(db)
	Catch
		needsMigration = False
	End Try
	If db.IsInitialized Then db.Close
	Return needsMigration
End Sub

Private Sub DatabaseNeedsMigration(Db As SQL) As Boolean
	If HasColumn(Db, "events", "uuid") = False Then Return True
	If HasColumn(Db, "events", "tags") = False Then Return True
	If HasColumn(Db, "events", "attachments_json") = False Then Return True
	If HasColumn(Db, "events", "created_at") = False Then Return True
	If HasColumn(Db, "events", "updated_at") = False Then Return True
	If HasColumn(Db, "events", "archived_at") = False Then Return True
	If HasColumn(Db, "events", "lunar_text") = False Then Return True
	Return False
End Sub

Public Sub HasColumn(Db As SQL, TableName As String, ColumnName As String) As Boolean
	Dim rs As ResultSet = Db.ExecQuery("PRAGMA table_info(" & TableName & ")")
	Do While rs.NextRow
		If rs.GetString("name").ToLowerCase = ColumnName.ToLowerCase Then
			rs.Close
			Return True
		End If
	Loop
	rs.Close
	Return False
End Sub

Private Sub BuildLegacyDbInfo(DatabaseName As String) As Map
	Dim m As Map
	m.Initialize
	m.Put("name", DatabaseName)
	m.Put("size", File.Size(xui.DefaultFolder, DatabaseName))
	m.Put("last_modified", File.LastModified(xui.DefaultFolder, DatabaseName))
	m.Put("schema_version", GetSchemaVersionForDbName(DatabaseName))
	Return m
End Sub

Private Sub GetSchemaVersionForDbName(DatabaseName As String) As Int
	Dim db As SQL
	#If B4J
	db.InitializeSQLite(xui.DefaultFolder, DatabaseName, True)
	#Else
	db.Initialize(xui.DefaultFolder, DatabaseName, True)
	#End If
	Dim version As Int = DB_SCHEMA_VERSION
	If DatabaseNeedsMigration(db) Then version = 1
	db.Close
	Return version
End Sub

Private Sub GetLegacyDbState As Map
	If KVS.ContainsKey(KVS_LEGACY_DB_STATE) Then
		Return KVS.Get(KVS_LEGACY_DB_STATE)
	End If
	Dim m As Map
	m.Initialize
	Return m
End Sub

Private Sub SaveLegacyDbState(Info As Map, StateValue As String, NewDbName As String)
	Dim m As Map
	m.Initialize
	m.Put("name", Info.Get("name"))
	m.Put("size", Info.Get("size"))
	m.Put("last_modified", Info.Get("last_modified"))
	m.Put("schema_version", Info.Get("schema_version"))
	m.Put("state", StateValue)
	m.Put("new_db_name", NewDbName)
	m.Put("updated_at", DateTime.Now)
	KVS.Put(KVS_LEGACY_DB_STATE, m)
End Sub

Private Sub SameLegacySnapshot(Info As Map, State As Map) As Boolean
	If State.IsInitialized = False Then Return False
	If Info.GetDefault("name", "") <> State.GetDefault("name", "") Then Return False
	If Info.GetDefault("size", -1) <> State.GetDefault("size", -2) Then Return False
	If Info.GetDefault("last_modified", -1) <> State.GetDefault("last_modified", -2) Then Return False
	If Info.GetDefault("schema_version", -1) <> State.GetDefault("schema_version", -2) Then Return False
	Return True
End Sub

Private Sub EnsureMigrationOverlay
	If pnlMigrationOverlay.IsInitialized Then Return
	pnlMigrationOverlay = xui.CreatePanel("")
	pnlMigrationOverlay.Color = 0xAA000000
	Dim lbl As Label
	lbl.Initialize("")
	lblMigrationStatus = lbl
	lblMigrationStatus.SetTextAlignment("CENTER", "CENTER")
	lblMigrationStatus.TextColor = xui.Color_White
	lblMigrationStatus.TextSize = 18
	pnlMigrationOverlay.AddView(lblMigrationStatus, 20dip, 0, Root.Width - 40dip, Root.Height)
End Sub

Private Sub ShowMigrationStatus(Message As String)
	EnsureMigrationOverlay
	lblMigrationStatus.Text = Message
	If pnlMigrationOverlay.Parent.IsInitialized = False Then
		Root.AddView(pnlMigrationOverlay, 0, 0, Root.Width, Root.Height)
	End If
	B4XPages.SetTitle(Me, Message)
End Sub

Private Sub HideMigrationStatus
	If pnlMigrationOverlay.IsInitialized And pnlMigrationOverlay.Parent.IsInitialized Then
		pnlMigrationOverlay.RemoveViewFromParent
	End If
	B4XPages.SetTitle(Me, "LOGIN")
End Sub


Private Sub MigrateLegacyDatabase(LegacyInfo As Map, SourceDbName As String) As ResumableSub
	Dim targetDb As SQL
	Dim sourceDb As SQL
	Dim sourceIsActive As Boolean = (ActiveDbName = SourceDbName)
	Try
		ShowMigrationStatus("Preparing migration (1/5)")
		Sleep(0)
		If sourceIsActive Then
			sourceDb = SQL1
		Else
			#If B4J
			sourceDb.InitializeSQLite(xui.DefaultFolder, SourceDbName, True)
			#Else
			sourceDb.Initialize(xui.DefaultFolder, SourceDbName, True)
			#End If
		End If
		If File.Exists(xui.DefaultFolder, LATEST_DB_NAME) Then File.Delete(xui.DefaultFolder, LATEST_DB_NAME)
		#If B4J
		targetDb.InitializeSQLite(xui.DefaultFolder, LATEST_DB_NAME, True)
		#Else
		targetDb.Initialize(xui.DefaultFolder, LATEST_DB_NAME, True)
		#End If
		CreateLatestSchema(targetDb)
		ShowMigrationStatus("Migrating users (2/5)")
		Sleep(0)
		CopyUsersTable(sourceDb, targetDb)
		ShowMigrationStatus("Migrating notes (3/5)")
		Sleep(0)
		Wait For (CopyEventsToLatest(sourceDb, targetDb)) Complete (EventsDone As Boolean)
		ShowMigrationStatus("Migrating passwords and delete logs (4/5)")
		Sleep(0)
		CopyPswTable(sourceDb, targetDb)
		CopyDeleteTable(sourceDb, targetDb, "delevents", "id_user", "deltime")
		CopyDeleteTable(sourceDb, targetDb, "delPSW", "id_user", "delpsw")
		ShowMigrationStatus("Switching to the new database (5/5)")
		Sleep(0)
		targetDb.Close
		If sourceIsActive = False And sourceDb.IsInitialized Then sourceDb.Close
		OpenDatabase(LATEST_DB_NAME)
		CreateLatestSchema(SQL1)
		ActiveDbName = LATEST_DB_NAME
		KVS.Put(KVS_ACTIVE_DB_NAME, ActiveDbName)
		SaveLegacyDbState(LegacyInfo, LEGACY_STATE_COMPLETED, LATEST_DB_NAME)
		HideMigrationStatus
		Return True
	Catch
		If targetDb.IsInitialized Then targetDb.Close
		If sourceIsActive = False And sourceDb.IsInitialized Then sourceDb.Close
		HideMigrationStatus
		xui.MsgboxAsync(LastException.Message, "Migration Error")
		Return False
	End Try
End Sub

Private Sub CopyUsersTable(SourceDb As SQL, TargetDb As SQL)
	Dim rs As ResultSet = SourceDb.ExecQuery("SELECT * FROM users")
	Do While rs.NextRow
		TargetDb.ExecNonQuery2("INSERT OR REPLACE INTO users (id_user, password, name, nickname, level, active) VALUES (?,?,?,?,?,?)", _
			Array As Object(rs.GetString("id_user"), rs.GetString("password"), rs.GetString("name"), rs.GetString("nickname"), rs.GetString("level"), rs.GetString("active")))
	Loop
	rs.Close
End Sub

Private Sub CopyPswTable(SourceDb As SQL, TargetDb As SQL)
	Dim rs As ResultSet = SourceDb.ExecQuery("SELECT * FROM psw")
	Do While rs.NextRow
		TargetDb.ExecNonQuery2("INSERT OR REPLACE INTO psw (id_user, description, username, password, email, remark, time, timestamp, sync_flag, new, changed) VALUES (?,?,?,?,?,?,?,?,?,?,?)", _
			Array As Object(rs.GetString("id_user"), rs.GetString("description"), rs.GetString("username"), rs.GetString("password"), rs.GetString("email"), rs.GetString("remark"), rs.GetString("time"), rs.GetString("timestamp"), rs.GetString("sync_flag"), rs.GetString("new"), rs.GetString("changed")))
	Loop
	rs.Close
End Sub

Private Sub CopyDeleteTable(SourceDb As SQL, TargetDb As SQL, TableName As String, FirstColumn As String, SecondColumn As String)
	Dim rs As ResultSet = SourceDb.ExecQuery("SELECT * FROM " & TableName)
	Do While rs.NextRow
		TargetDb.ExecNonQuery2("INSERT INTO " & TableName & " (" & FirstColumn & ", " & SecondColumn & ") VALUES (?,?)", _
			Array As Object(rs.GetString(FirstColumn), rs.GetString(SecondColumn)))
	Loop
	rs.Close
End Sub

Private Sub CopyEventsToLatest(SourceDb As SQL, TargetDb As SQL) As ResumableSub
	Dim total As Int = SourceDb.ExecQuerySingleResult("SELECT COUNT(*) FROM events")
	Dim copied As Int = 0
	Dim hasLunarText As Boolean = HasColumn(SourceDb, "events", "lunar_text")
	Dim rs As ResultSet = SourceDb.ExecQuery("SELECT * FROM events ORDER BY rowid")
	Do While rs.NextRow
		copied = copied + 1
		Dim legacyTime As String = rs.GetString("time")
		Dim legacyUser As String = rs.GetString("id_user")
		Dim legacyTimestamp As String = rs.GetString("timestamp")
		Dim deterministicUuid As String = BuildEventUuid(legacyUser, legacyTime)
		Dim lunarText As String = ""
		If hasLunarText Then lunarText = rs.GetString("lunar_text")
		lunarText = ResolveEventLunarText(legacyTime, lunarText)
		TargetDb.ExecNonQuery2("INSERT OR REPLACE INTO events (id_user, month, event_type, description, value, year, time, timestamp, sync_flag, new, changed, uuid, tags, attachments_json, created_at, updated_at, archived_at, lunar_text) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", _
			Array As Object(legacyUser, rs.GetString("month"), rs.GetString("event_type"), rs.GetString("description"), rs.GetString("value"), rs.GetString("year"), legacyTime, legacyTimestamp, rs.GetString("sync_flag"), rs.GetString("new"), rs.GetString("changed"), deterministicUuid, BuildTagsPayload(rs.GetString("event_type"), rs.GetString("description"), rs.GetString("value")), BuildAttachmentsPayload(rs.GetString("event_type"), rs.GetString("description"), rs.GetString("value")), legacyTimestamp, legacyTimestamp, "", lunarText))
		If copied = 1 Or copied Mod 25 = 0 Or copied = total Then
			ShowMigrationStatus("Migrating notes " & copied & "/" & total & " (3/5)")
			Sleep(0)
		End If
	Loop
	rs.Close
	Return True
End Sub

Public Sub NormalizeEventInsertParameters(Values() As String) As Object()
	If Values.Length >= 18 Then Return Values
	Dim normalized(18) As Object
	For i = 0 To Min(Values.Length, 11) - 1
		normalized(i) = Values(i)
	Next
	Dim userId As String = Values(0)
	Dim eventTime As String = Values(6)
	Dim timestamp As String = Values(7)
	Dim providedUuid As String = ""
	If Values.Length > 11 Then providedUuid = Values(11)
	If providedUuid = "" Or providedUuid = Null Then
		normalized(11) = BuildEventUuid(userId, eventTime)
	Else
		normalized(11) = providedUuid
	End If
	normalized(12) = BuildTagsPayload(Values(2), Values(3), Values(4))
	normalized(13) = BuildAttachmentsPayload(Values(2), Values(3), Values(4))
	normalized(14) = timestamp
	normalized(15) = timestamp
	normalized(16) = ""
	Dim providedLunar As String = ""
	If Values.Length > 17 Then providedLunar = Values(17)
	normalized(17) = ResolveEventLunarText(eventTime, providedLunar)
	Return normalized
End Sub

Public Sub EnsureEventUuidForRow(RowId As Long)
	Dim currentUuid As String = SQL1.ExecQuerySingleResult2("SELECT uuid FROM events WHERE rowid = ?", Array As String(RowId))
	Dim currentLunar As String = ""
	If EventsUseLunarText Then currentLunar = SQL1.ExecQuerySingleResult2("SELECT lunar_text FROM events WHERE rowid = ?", Array As String(RowId))
	If (currentUuid <> Null And currentUuid <> "") And (currentLunar <> Null And currentLunar <> "") Then Return
	Dim rs As ResultSet = SQL1.ExecQuery2("SELECT id_user, event_type, description, value, time, timestamp, lunar_text FROM events WHERE rowid = ?", Array As String(RowId))
	Do While rs.NextRow
		Dim generatedUuid As String = BuildEventUuid(rs.GetString("id_user"), rs.GetString("time"))
		Dim updatedAt As String = rs.GetString("timestamp")
		Dim lunarText As String = ResolveEventLunarText(rs.GetString("time"), rs.GetString("lunar_text"))
		SQL1.ExecNonQuery2("UPDATE events SET uuid = COALESCE(NULLIF(uuid, ''), ?), tags = COALESCE(NULLIF(tags, ''), ?), attachments_json = COALESCE(NULLIF(attachments_json, ''), ?), created_at = COALESCE(created_at, ?), updated_at = COALESCE(updated_at, ?), lunar_text = COALESCE(NULLIF(lunar_text, ''), ?) WHERE rowid = ?", _
			Array As Object(generatedUuid, BuildTagsPayload(rs.GetString("event_type"), rs.GetString("description"), rs.GetString("value")), BuildAttachmentsPayload(rs.GetString("event_type"), rs.GetString("description"), rs.GetString("value")), updatedAt, updatedAt, lunarText, RowId))
	Loop
	rs.Close
End Sub

Private Sub BackfillMissingEventLunarText(Db As SQL)
	If HasColumn(Db, "events", "lunar_text") = False Then Return
	Dim rs As ResultSet = Db.ExecQuery("SELECT rowid, time FROM events WHERE COALESCE(lunar_text, '') = ''")
	Do While rs.NextRow
		Dim lunarText As String = BuildEventLunarText(rs.GetString("time"))
		If lunarText <> "" Then
			Db.ExecNonQuery2("UPDATE events SET lunar_text = ? WHERE rowid = ?", Array As Object(lunarText, rs.GetLong2(0)))
		End If
	Loop
	rs.Close
End Sub

Public Sub BuildTagsPayload(EventType As String, Description As String, ValueText As String) As String
	Dim combined As String = EventType & " " & Description & " " & ValueText
	Dim tags As Map
	tags.Initialize
	Dim token As String = ""
	Dim inTag As Boolean = False
	For i = 0 To combined.Length - 1
		Dim ch As String = combined.CharAt(i)
		If ch = "#" Then
			If inTag And token.Length > 0 Then tags.Put(token.ToLowerCase, token)
			token = ""
			inTag = True
		Else If inTag Then
			If IsTagChar(ch) Then
				token = token & ch
			Else
				If token.Length > 0 Then tags.Put(token.ToLowerCase, token)
				token = ""
				inTag = False
			End If
		End If
	Next
	If inTag And token.Length > 0 Then tags.Put(token.ToLowerCase, token)
	Dim ordered As List
	ordered.Initialize
	For Each k As String In tags.Keys
		ordered.Add("#" & tags.Get(k))
	Next
	ordered.Sort(True)
	Return JoinList(ordered, " ")
End Sub

Public Sub BuildAttachmentsPayload(EventType As String, Description As String, ValueText As String) As String
	Dim blocks As List
	blocks.Initialize
	blocks.Add(EventType)
	blocks.Add(Description)
	blocks.Add(ValueText)
	Dim records As List
	records.Initialize
	Dim seen As Map
	seen.Initialize
	For Each block As String In blocks
		If block = Null Then Continue
		Dim normalizedBlock As String = block.Replace(Chr(13), "")
		Dim lines() As String = Regex.Split(Chr(10), normalizedBlock)
		For Each line As String In lines
			Dim trimmed As String = line.Trim
			If trimmed.StartsWith("@attach ") = False Then Continue
			Dim rawPath As String = trimmed.SubString(8).Trim
			If rawPath = "" Then Continue
			If seen.ContainsKey(rawPath.ToLowerCase) Then Continue
			seen.Put(rawPath.ToLowerCase, True)
			Dim item As Map = CreateMap("path":rawPath, "name":ExtractAttachmentName(rawPath), "type":InferAttachmentType(rawPath))
			records.Add(item)
		Next
	Next
	If records.Size = 0 Then Return ""
	Return BuildAttachmentJson(records)
End Sub

Private Sub BuildAttachmentJson(Records As List) As String
	Dim sb As StringBuilder
	Dim q As String = Chr(34)
	sb.Initialize
	sb.Append("[")
	For i = 0 To Records.Size - 1
		Dim item As Map = Records.Get(i)
		If i > 0 Then sb.Append(",")
		sb.Append("{")
		sb.Append(q).Append("path").Append(q).Append(":").Append(q).Append(EscapeJson(item.Get("path"))).Append(q).Append(",")
		sb.Append(q).Append("name").Append(q).Append(":").Append(q).Append(EscapeJson(item.Get("name"))).Append(q).Append(",")
		sb.Append(q).Append("type").Append(q).Append(":").Append(q).Append(EscapeJson(item.Get("type"))).Append(q)
		sb.Append("}")
	Next
	Return sb.Append("]").ToString
End Sub

Private Sub EscapeJson(Value As String) As String
	If Value = Null Then Return ""
	Return Value.Replace("\", "\\").Replace(Chr(34), "\" & Chr(34))
End Sub

Private Sub ExtractAttachmentName(PathValue As String) As String
	If PathValue = Null Or PathValue = "" Then Return ""
	Dim normalized As String = PathValue.Replace("/", "\\")
	Dim parts() As String = Regex.Split("\\\\", normalized)
	If parts.Length = 0 Then Return PathValue
	Return parts(parts.Length - 1)
End Sub

Private Sub InferAttachmentType(PathValue As String) As String
	Dim lower As String = PathValue.ToLowerCase
	If lower.EndsWith(".jpg") Or lower.EndsWith(".jpeg") Or lower.EndsWith(".png") Or lower.EndsWith(".gif") Or lower.EndsWith(".webp") Then Return "image"
	If lower.EndsWith(".pdf") Then Return "pdf"
	If lower.EndsWith(".mp3") Or lower.EndsWith(".wav") Or lower.EndsWith(".m4a") Or lower.EndsWith(".aac") Then Return "audio"
	If lower.EndsWith(".mp4") Or lower.EndsWith(".mov") Or lower.EndsWith(".avi") Or lower.EndsWith(".mkv") Then Return "video"
	Return "file"
End Sub

Private Sub IsTagChar(Ch As String) As Boolean
	If Ch.Length = 0 Then Return False
	Dim code As Int = Asc(Ch)
	If code >= Asc("0") And code <= Asc("9") Then Return True
	If code >= Asc("A") And code <= Asc("Z") Then Return True
	If code >= Asc("a") And code <= Asc("z") Then Return True
	If Ch = "_" Then Return True
	If code > 127 Then Return True
	Return False
End Sub

Private Sub JoinList(Items As List, Separator As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To Items.Size - 1
		If i > 0 Then sb.Append(Separator)
		sb.Append(Items.Get(i))
	Next
	Return sb.ToString
End Sub

Public Sub EventsUseUuid As Boolean
	Return HasColumn(SQL1, "events", "uuid")
End Sub

Public Sub EventsUseLunarText As Boolean
	Return HasColumn(SQL1, "events", "lunar_text")
End Sub

Public Sub ResolveEventRowId(EventUuid As String, EventTime As String) As Long
	Dim rowId As Long = 0
	If EventUuid <> "" And EventsUseUuid Then
		Dim uuidResult As String = SQL1.ExecQuerySingleResult2("SELECT rowid FROM events WHERE uuid = ?", Array As String(EventUuid))
		If uuidResult <> Null And uuidResult <> "" Then Return uuidResult
	End If
	If EventTime = "" Then Return 0
		Dim timeResult As String = SQL1.ExecQuerySingleResult2("SELECT rowid FROM events WHERE time = ?", Array As String(EventTime))
	If timeResult <> Null And timeResult <> "" Then rowId = timeResult
	Return rowId
End Sub

Public Sub ResolveEventRowIdFromMap(EventData As Map) As Long
	If EventData.IsInitialized = False Then Return 0
	Return ResolveEventRowId(EventData.GetDefault("uuid", ""), EventData.GetDefault("time", ""))
End Sub

Public Sub InsertDeleteEventTombstone(UserId As String, EventUuid As String, EventTime As String)
	If HasColumn(SQL1, "delevents", "deluuid") Then
		SQL1.ExecNonQuery2("INSERT INTO delevents (id_user, deltime, deluuid) VALUES (?,?,?)", Array As Object(UserId, EventTime, EventUuid))
	Else
		SQL1.ExecNonQuery2("INSERT INTO delevents VALUES(?,?)", Array As String(UserId, EventTime))
	End If
End Sub

Public Sub BuildEventUuid(UserId As String, EventTime As String) As String
	Dim safeUser As String = UserId.Replace(" ", "_")
	Dim safeTime As String = EventTime.Replace(" ", "_").Replace(":", "_").Replace("/", "_").Replace("\\", "_")
	Return "evt_" & safeUser & "_" & safeTime
End Sub

Public Sub ResolveEventLunarText(EventTime As String, ExistingLunarText As String) As String
	If ExistingLunarText <> Null And ExistingLunarText <> "" Then Return ExistingLunarText
	Return BuildEventLunarText(EventTime)
End Sub

Public Sub BuildEventDisplayTime(EventTime As String, LunarText As String) As String
	If EventTime = Null Or EventTime = "" Then Return ""
	Dim resolvedLunar As String = ResolveEventLunarText(EventTime, LunarText)
	If resolvedLunar = "" Then Return EventTime
	Return EventTime & CRLF & resolvedLunar
End Sub

Public Sub BuildEventLunarText(EventTime As String) As String
	If EventTime = Null Or EventTime = "" Then Return ""
	Dim parts() As String = Regex.Split("_", EventTime)
	If parts.Length = 0 Then Return ""
	Dim gregorian As Map = ParseEventDatePart(parts(0))
	If gregorian.IsInitialized = False Then Return ""
	Dim lunar As Map = SolarToLunar(gregorian.Get("year"), gregorian.Get("month"), gregorian.Get("day"))
	If lunar.IsInitialized = False Then Return ""
	Dim prefix As String = "农历"
	If lunar.GetDefault("isLeap", False) Then prefix = prefix & "闰"
	Return prefix & LunarMonthName(lunar.Get("month")) & LunarDayName(lunar.Get("day"))
End Sub

Private Sub ParseEventDatePart(DatePart As String) As Map
	Dim sanitized As String = DatePart.Replace(".", "/").Replace("-", "/")
	Dim segments() As String = Regex.Split("/", sanitized)
	If segments.Length <> 3 Then Return Null
	Dim first As Int = segments(0)
	Dim second As Int = segments(1)
	Dim third As Int = segments(2)
	Dim res As Map
	res.Initialize
	If segments(0).Length = 4 Then
		res.Put("year", first)
		res.Put("month", second)
		res.Put("day", third)
	Else If segments(2).Length = 4 Then
		res.Put("year", third)
		res.Put("month", first)
		res.Put("day", second)
	Else
		Return Null
	End If
	Return res
End Sub

Private Sub SolarToLunar(SolarYear As Int, SolarMonth As Int, SolarDay As Int) As Map
	If SolarYear < LUNAR_BASE_YEAR Or SolarYear > LUNAR_MAX_YEAR Then Return Null
	Dim targetTicks As Long
	Try
		targetTicks = DateUtils.SetDate(SolarYear, SolarMonth, SolarDay)
	Catch
		Return Null
	End Try
	Dim baseTicks As Long = DateUtils.SetDate(1901, 2, 19)
	Dim offsetDays As Int = Floor((targetTicks - baseTicks) / DateTime.TicksPerDay)
	If offsetDays < 0 Then Return Null
	Dim lunarYear As Int = LUNAR_BASE_YEAR
	Do While lunarYear <= LUNAR_MAX_YEAR
		Dim yearDays As Int = LunarYearDays(lunarYear)
		If offsetDays < yearDays Then Exit
		offsetDays = offsetDays - yearDays
		lunarYear = lunarYear + 1
	Loop
	If lunarYear > LUNAR_MAX_YEAR Then Return Null
	Dim leapMonth As Int = LunarLeapMonth(lunarYear)
	Dim isLeapMonth As Boolean = False
	Dim lunarMonth As Int = 1
	Do While lunarMonth <= 12
		Dim monthDays As Int
		If isLeapMonth Then
			monthDays = LunarLeapDays(lunarYear)
		Else
			monthDays = LunarMonthDays(lunarYear, lunarMonth)
		End If
		If offsetDays < monthDays Then Exit
		offsetDays = offsetDays - monthDays
		If leapMonth = lunarMonth And isLeapMonth = False Then
			isLeapMonth = True
		Else
			If isLeapMonth Then isLeapMonth = False
			lunarMonth = lunarMonth + 1
		End If
	Loop
	Dim res As Map
	res.Initialize
	res.Put("year", lunarYear)
	res.Put("month", lunarMonth)
	res.Put("day", offsetDays + 1)
	res.Put("isLeap", isLeapMonth)
	Return res
End Sub

Private Sub LunarYearDays(LunarYear As Int) As Int
	Dim total As Int = 348
	Dim yearCode As Int = LunarYearCode(LunarYear)
	Dim mask As Int = 32768
	Do While mask >= 16
		If Bit.And(yearCode, mask) <> 0 Then total = total + 1
		mask = Bit.ShiftRight(mask, 1)
	Loop
	Return total + LunarLeapDays(LunarYear)
End Sub

Private Sub LunarLeapMonth(LunarYear As Int) As Int
	Return Bit.And(LunarYearCode(LunarYear), 15)
End Sub

Private Sub LunarLeapDays(LunarYear As Int) As Int
	If LunarLeapMonth(LunarYear) = 0 Then Return 0
	If Bit.And(LunarYearCode(LunarYear), 65536) <> 0 Then Return 30
	Return 29
End Sub

Private Sub LunarMonthDays(LunarYear As Int, LunarMonth As Int) As Int
	Dim mask As Int = Bit.ShiftLeft(1, 16 - LunarMonth)
	If Bit.And(LunarYearCode(LunarYear), mask) <> 0 Then Return 30
	Return 29
End Sub

Private Sub LunarYearCode(LunarYear As Int) As Int
	Dim data() As Int = Array As Int(19168,42352,21717,53856,55632,91476,22176,39632,21970,19168,42422,42192,53840,119381,46400,54944,44450,38320,84343,18800,42160,46261,27216,27968,109396,11104,38256,21234,18800,25958,54432,59984,92821,23248,11104,100067,37600,116951,51536,54432,120998,46416,22176,107956,9680,37584,53938,43344,46423,27808,46416,86869,19872,42416,83315,21168,43432,59728,27296,44710,43856,19296,43748,42352,21088,62051,55632,23383,22176,38608,19925,19152,42192,54484,53840,54616,46400,46752,103846,38320,18864,43380,42160,45690,27216,27968,44870,43872,38256,19189,18800,25776,29859,59984,27480,23232,43872,38613,37600,51552,55636,54432,55888,30034,22176,43959,9680,37584,51893,43344,46240,47780,44368,21977,19360,42416,86390,21168,43312,31060,27296,44368,23378,19296,42726,42208,53856,60005,54576,23200,30371,38608,19195,19152,42192,118966,53840,54560,56645,46496,22224,21938,18864,42359,42160,43600,111189,27936,44448,84835,37744,18936,18800,25776,92326,59984,27424,108228,43744,37600,53987,51552,54615,54432,55888,23893,22176,42704,21972,21200,43448,43344,46240,46758,44368,21920,43940,42416,21168,45683,26928,29495,27296,44368,84821,19296,42352,21732,53856,59752,54560,55968,92838,22224,19168,43476,42192,53584,62034,54560)
	Return data(LunarYear - LUNAR_BASE_YEAR)
End Sub

Private Sub LunarMonthName(MonthValue As Int) As String
	Dim names() As String = Array As String("正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月")
	If MonthValue < 1 Or MonthValue > names.Length Then Return ""
	Return names(MonthValue - 1)
End Sub

Private Sub LunarDayName(DayValue As Int) As String
	Dim names() As String = Array As String("初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", _
		"十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", _
		"廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十")
	If DayValue < 1 Or DayValue > names.Length Then Return ""
	Return names(DayValue - 1)
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("Login")
	AdjustLoginLayout
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

Private Sub B4XPage_Resize (Width As Int, Height As Int)
	AdjustLoginLayout
End Sub

Private Sub AdjustLoginLayout
	Dim margin As Int = 12dip
	CenterViewHorizontally(etUser, margin)
	CenterViewHorizontally(etPass, margin)
	CenterViewHorizontally(btnLogin, margin)
	CenterViewHorizontally(Bntregist, margin)
	CenterViewHorizontally(Bntmodify, margin)
	CenterViewHorizontally(BntForget, margin)
	CenterLoginGroupVertically(margin)
End Sub

Private Sub CenterViewHorizontally(v As B4XView, margin As Int)
	If v.IsInitialized = False Then Return
	Dim maxWidth As Int = Max(120dip, Root.Width - 2 * margin)
	Dim targetWidth As Int = Min(GetLoginControlMaxWidth(v), maxWidth)
	Dim targetLeft As Int = Max(margin, (Root.Width - targetWidth) / 2)
	Dim targetTop As Int = v.Top
	If targetTop + v.Height > Root.Height - margin Then
		targetTop = Max(margin, Root.Height - v.Height - margin)
	End If
	v.SetLayoutAnimated(0, targetLeft, targetTop, targetWidth, v.Height)
End Sub

Private Sub GetLoginControlMaxWidth(v As B4XView) As Int
	If v = etUser Or v = etPass Then Return 360dip
	If v = btnLogin Then Return 260dip
	Return 260dip
End Sub

Private Sub CenterLoginGroupVertically(margin As Int)
	Dim views As List = GetLoginLayoutViews
	If views.Size = 0 Then Return
	Dim topMost As Int = 2147483647
	Dim bottomMost As Int = -2147483648
	For Each v As B4XView In views
		topMost = Min(topMost, v.Top)
		bottomMost = Max(bottomMost, v.Top + v.Height)
	Next
	Dim groupHeight As Int = bottomMost - topMost
	Dim targetTop As Int = Max(margin, (Root.Height - groupHeight) / 2)
	Dim offset As Int = targetTop - topMost
	For Each v As B4XView In views
		v.SetLayoutAnimated(0, v.Left, v.Top + offset, v.Width, v.Height)
	Next
End Sub

Private Sub GetLoginLayoutViews As List
	Dim views As List
	views.Initialize
	AddLoginLayoutView(views, etUser)
	AddLoginLayoutView(views, etPass)
	AddLoginLayoutView(views, btnLogin)
	AddLoginLayoutView(views, Bntregist)
	AddLoginLayoutView(views, Bntmodify)
	AddLoginLayoutView(views, BntForget)
	Return views
End Sub

Private Sub AddLoginLayoutView(views As List, v As B4XView)
	If v.IsInitialized Then views.Add(v)
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