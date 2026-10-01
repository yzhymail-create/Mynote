# CHAT_HISTORY.md

本文件用于在仓库内保存简洁的对话/决策记录，作为后续 AI 会话的项目上下文补充。

> 说明：是否会被“自动读取”，取决于所使用的 IDE / Copilot 是否支持读取仓库级指令文件（如 `.github/copilot-instructions.md`）以及项目内文档。这里已经把可复用的历史记录落在仓库里，便于跨编辑器共享。

## 记录规则
- 记录与项目有关的用户请求、已做修改、关键决策、后续待办。
- 优先写“摘要”和“结论”，不要原样粘贴冗长聊天。
- 不要写入密钥、密码、令牌等敏感信息。
- 每次完成一个有意义的任务后，追加一条带日期的记录。

## 2026-05-24
- 用户：更新项目根目录 `AGENTS.md`，用于指导 AI 编码代理。
  - 处理结果：已按代码现状最小化更新，补充了搜索高亮/命中定位、密码删除日志不对称、页面 ID 大小写/拼写不一致等约定。
- 用户：在当前文件夹中创建 Git 仓库，用于管理过程变化。
  - 处理结果：已在 `D:\B4X\MYDESIGN\MySuperNote` 执行 `git init`，当前分支为 `master`，尚未首次提交。
- 用户：把对话 CHAT 记录也建立在当前文件夹下，便于下次在不同应用中打开时复用。
  - 处理结果：已创建本文件，并新增 `.github/copilot-instructions.md`，要求后续 Copilot/AI 代理优先阅读 `AGENTS.md` 与本文件。
- 用户：优化搜索结果高亮，要求从搜索结果打开日记后，在搜索查看状态下持续保持目标文字高亮，退出搜索状态后自动取消。
  - 处理结果：已在 `NoteView.bas` 增加搜索态只读高亮预览，用 `WebView` 在打开搜索结果时持续显示高亮并自动滚动到首个命中；关闭/离开页面时恢复普通编辑视图。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：修复 `NoteView` 搜索高亮改动后出现的编译错误/警告，并处理 Android `targetSdkVersion` 建议值。
  - 处理结果：已在 `NoteView.bas` 用 `Chr(13)` 替代未声明的 `CR`，并删除旧版搜索定位遗留的未使用方法；同时将 `B4A/MyNote.b4a` manifest editor 中的 `android:targetSdkVersion` 从 `30` 调整为 `35`。
  - 涉及文件：`NoteView.bas`、`B4A/MyNote.b4a`、`CHAT_HISTORY.md`
- 用户：继续检查 `NoteView` 编译报错，发现 `LF` 也未声明。
  - 处理结果：已在 `NoteView.bas` 的 `HtmlEncode` 中将未声明的 `LF` 改为 `Chr(10)`，并再次做静态错误检查，结果无错误。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：处理 Android 资源链接错误：`drawable/icon` 同时由 `icon.png` 和 `icon.ico` 定义而冲突。
  - 处理结果：已删除 `B4A/Objects/res/drawable/` 下残留的生成文件 `icon.ico`，保留 `icon.png` 作为唯一的 `@drawable/icon` 资源；该问题来自生成目录中的陈旧文件，而不是源码中的重复引用。
  - 涉及文件：`CHAT_HISTORY.md`（运行时清理了生成文件 `B4A/Objects/res/drawable/icon.ico`）
- 用户：检查 `Page2Left` 里的 `TO TEXT` 按钮，点击后应用卡死退出。
  - 处理结果：已定位到 `B4XPageData.bas` 的 `Bntcsv_Click -> ExportTableToCSV`。共享导出逻辑里原本会在 Android 上执行 `File.Copy(..., "D:\", ...)`，并且在系统文档保存流程前过早弹框，导致导出流程异常。现已移除硬编码 `D:\` 拷贝，Android 改为先生成临时文件再通过 `SaveFile` 让用户选择保存位置，且只在保存成功后提示 `OK`。
  - 涉及文件：`B4XPageData.bas`、`CHAT_HISTORY.md`
- 用户：`HamburgerIcon = xui.LoadBitmapResize(File.DirAssets, "hamburger.png", 32dip, 32dip, True)` 实际显示太黑，希望改成白色以便从背景中突显。
  - 处理结果：已在 `B4XPageData.bas` 中移除对黑色 `hamburger.png` 的直接加载，改为运行时用 `B4XCanvas` 绘制白色汉堡图标并复用到侧栏入口/ActionBar 指示器。
  - 涉及文件：`B4XPageData.bas`、`CHAT_HISTORY.md`

## 2026-06-21
- 用户：评估 `MySuperNote设计优化20260621.txt` 中的长期日记架构方案，判断现有代码是否能演进实现。
  - 处理结果：已完成现状对照分析。结论是“可以演进实现，但需要分阶段重构而不是局部优化”。当前主要约束包括：`events` 表以 `time` 作为主键、无 `uuid`/标签/附件元数据/归档索引；搜索为全量读库后内存过滤；导出仅支持文本/CSV；同步协议也绑定现有表结构与 `time` 标识。
  - 关键建议：先做 SQLite 模式升级兼容层（引入稳定 `uuid` 与扩展字段），再逐步补 `diary_archive_index`、`.diarybak` 导出/导入、ArchiveReader、标签/关键词筛选与更高效搜索，最后再调整同步协议适配新主键与删除日志。
  - 涉及文件：`CHAT_HISTORY.md`
- 用户：要求将当前代码用 Git 保存，并使用当天日期作为注释，方便后续回退；同时要求把本次对话结论保存在项目文件夹中，便于以后打开项目时追溯修改历史。
  - 处理结果：已将本次请求和上面的架构评估结论写入 `CHAT_HISTORY.md`，并准备基于当前工作区内容创建一次带日期的 Git 快照提交，用于后续按提交点回退。
  - 说明：项目内的对话追溯采用 `CHAT_HISTORY.md` 保存摘要与结论，代码级差异以 Git 提交历史为准，二者结合即可定位“聊了什么”与“改了什么”。
  - 涉及文件：`CHAT_HISTORY.md`
- 用户：要求补一份更严格的 `.gitignore`，把 B4A/B4J 与内置 jRDC 的生成物从后续提交中排除掉。
  - 处理结果：已更新 `.gitignore`，补充忽略根目录 `Output/`、`B4J/shell/`、`B4J/temp/` 以及 `mynote_jrdc2/jRDC/Objects/`、`mynote_jrdc2/jRDC/AutoBackups/`；同时执行 `git rm --cached` 将这些已被跟踪的生成物从 Git 索引中移除，但保留本地文件不删除。
  - 说明：`.gitignore` 只影响后续跟踪；对已经提交过的生成物，必须同时做一次索引清理，后面的提交历史才会真正变干净。
  - 涉及文件：`.gitignore`、`CHAT_HISTORY.md`
- 用户：提出数据库升级策略：APP 更新时先检测旧库结构；如果不是最新结构，则读取当前数据库，新建一个新结构数据库，将旧数据迁移过去，并暂时保留原数据库不删除。
  - 处理结果：已确认这是比“原表直接 ALTER”更稳的一类方案，尤其适合当前项目这种旧代码大量依赖既有字段与查询方式的场景。后续建议按“双库迁移 + 旧库保留 + 成功后切换”实施，并补充迁移状态标记、失败回滚与校验逻辑。
  - 说明：该方案的核心收益是降低结构演进风险，避免在旧表上连续打补丁后留下长期兼容负担；但落地时必须避免迁移过程中同时写旧库和新库，且要保证切换动作原子化。
  - 涉及文件：`CHAT_HISTORY.md`
- 用户：要求进一步补充迁移交互：检测到旧库时要提示用户迁移；迁移过程要显示进度；并记录旧库事件，避免以后再次检测到同一个旧库时重复给出初次迁移提示；如果该旧库大小未变化且已迁移过，则应改为提示用户是否删除旧库。
  - 处理结果：已确认需要把“旧库识别 + 迁移状态 + 旧库清理提示”设计成显式状态机，而不是仅靠一次性结构检测。建议为每个旧库记录文件名、大小、修改时间、结构版本、迁移结果、新库目标名与时间戳，并根据这些状态分流首次迁移提示、迁移中提示、迁移完成后删除旧库提示。
  - 关键建议：优先把这类元数据存到当前主库之外的稳定位置，例如 `KVS` 或独立元数据表，避免仅因切换数据库文件而丢失迁移记录；同时 UI 上要明确区分“需要迁移”和“旧库已成功迁移，是否清理”两类提示。
  - 涉及文件：`CHAT_HISTORY.md`
- 用户：要求开始优化 APP 代码，先把旧库检测、迁移提示、迁移进度和迁移后旧库清理提示的主流程落地。
  - 处理结果：已在 `B4XMainPage.bas` 落地第一版数据库迁移骨架：引入 `notesql_v2.db` 作为新结构数据库；启动时根据 `KVS` 记录和数据库文件存在情况决定打开旧库或新库；检测 `events` 表是否缺少 `uuid/tags/attachments_json/created_at/updated_at/archived_at`；检测到旧库时提示用户迁移；迁移时创建覆盖层显示阶段进度；迁移成功后切换到新库并保留旧 `notesql.db`；若后续再次检测到同一份已迁移且未变化的旧库，则改为提示用户是否删除旧库备份。
  - 重要实现细节：新结构 `events` 表暂时保留旧字段和 `time` 主键，以便现有页面逻辑继续运行；`addEvents` 已改为显式列插入，避免以后 `events` 扩列后被 `INSERT INTO events VALUES (...)` 这类语句破坏。
  - 当前边界：本轮主要完成启动入口与旧库迁移骨架，尚未把页面层编辑/同步/搜索逻辑改成真正使用 `uuid`，新插入的记录目前仍沿用旧写法字段集，后续需要继续补 UUID 生成与各模块对新字段的正式使用。
  - 涉及文件：`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：选择先完成“新建/编辑日记时生成并保存 UUID”。
  - 处理结果：已在 `B4XMainPage.bas` 增加 `NormalizeEventInsertParameters` 与 `EnsureEventUuidForRow`，统一把旧 11 列事件参数补成新 17 列结构并生成稳定 `uuid`；`B4XPageData.bas`、`NoteView.bas`、`Synchorize.bas` 的新增写入路径已切到该规范化入口；编辑旧记录时若该行 `uuid` 为空，会先按 `id_user + time` 补齐再执行更新。
  - 说明：这样做的目的，是在不先大改页面和同步协议的前提下，确保“从现在开始写入的新记录有 `uuid`，以及被用户重新编辑过的旧记录也会补上 `uuid`”。由于现有同步协议仍按 `time` 传输，新建事件的 `uuid` 暂时采用基于 `id_user + time` 的稳定生成策略，保证跨设备落库时能生成相同标识。
  - 校验：已对 `B4XMainPage.bas`、`B4XPageData.bas`、`NoteView.bas`、`Synchorize.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`B4XPageData.bas`、`NoteView.bas`、`Synchorize.bas`、`CHAT_HISTORY.md`
- 用户：继续把列表、搜索、编辑定位从 `time -> RowId` 逐步改成优先使用 `uuid`。
  - 处理结果：已在 `B4XMainPage.bas` 增加 `EventsUseUuid`、`ResolveEventRowId`、`ResolveEventRowIdFromMap`，统一采用“先按 `uuid` 找 `rowid`，失败再按 `time` 回退”；`B4XPageData.bas` 和 `Search.bas` 现在会把 `uuid` 一并放入事件 `Map`；`NoteView.bas` 的编辑保存路径和两处删除入口已改为使用该统一定位逻辑。
  - 说明：这一步的目标不是立刻让全项目只认 `uuid`，而是先把最脆弱、最分散的 `time -> RowId` 查询收口，降低后续继续改同步和搜索时的耦合成本。
  - 校验：已对 `B4XMainPage.bas`、`B4XPageData.bas`、`Search.bas`、`NoteView.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`B4XPageData.bas`、`Search.bas`、`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：继续升级同步协议，让设备间直接传 `uuid`，而不是再靠 `time` 间接生成。
  - 处理结果：已在 `Synchorize.bas` 的事件同步载荷中附带 `uuid`：新建事件在发送列表末尾追加 `uuid`，变更事件用原本未使用的尾部槽位承载 `uuid`；接收端在处理变更事件时已改为优先调用 `ResolveEventRowId(uuid, time)` 合并记录，找不到时仍会按 `time` 回退。`NormalizeEventInsertParameters` 也已更新为接收端若收到同步方提供的 `uuid`，则直接落库该 `uuid`，不再本地重算。
  - 说明：这一步保持了与旧设备的兼容边界，因为旧设备仍可发送旧长度数组，新设备接收时会继续回退到 `time`；而新设备之间已经开始真正同步 `uuid`。
  - 校验：已对 `B4XMainPage.bas`、`Synchorize.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`Synchorize.bas`、`CHAT_HISTORY.md`
- 用户：继续把删除同步也补到 `uuid` 优先，不再只靠删除日志里的 `time`。
  - 处理结果：已将 `delevents` 升级为可带 `deluuid` 的兼容结构；`B4XPageData.bas` 的列表删除和 `Search.bas` 的搜索删除现在都会写入包含 `uuid` 的 tombstone；`Synchorize.bas` 在发送删除日志时会携带 `deluuid`，接收端删除记录时优先按 `ResolveEventRowId(deluuid, deltime)` 定位，找不到再回退 `time`。
  - 说明：这一步补齐了此前删除链上的两个缺口：一是搜索页删除之前未写 `delevents`，二是删除同步之前只有 `time` 没有 `uuid`。当前实现仍保留 `deltime`，便于和旧设备继续兼容。
  - 校验：已对 `B4XMainPage.bas`、`B4XPageData.bas`、`Search.bas`、`Synchorize.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`B4XPageData.bas`、`Search.bas`、`Synchorize.bas`、`CHAT_HISTORY.md`
- 用户：选择开始真正启用 `tags`，先不扩到附件。
  - 处理结果：已将 `tags` 字段接入业务流。`B4XMainPage.bas` 里新增 `BuildTagsPayload`，会从 `event_type`、`description`、`value` 中自动提取 `#标签` 并去重排序；旧库迁移到新库时会为历史数据补 `tags`；新建事件在 `NormalizeEventInsertParameters` 时会自动写入 `tags`；编辑事件的更新 SQL 已扩展为同步更新 `tags`；`Synchorize.bas` 在接收变更事件时也会重算并同步 `tags`；`Search.bas` 搜索时会把 `tags` 一并纳入匹配。
  - 说明：这一版没有新增专门的标签输入控件，而是先采用“正文/标题/备注中的 `#标签` 自动提取”方案，让 `tags` 列先真正发挥作用，再决定后续是否需要独立标签 UI。
  - 校验：已对 `B4XMainPage.bas`、`NoteView.bas`、`Synchorize.bas`、`Search.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`NoteView.bas`、`Synchorize.bas`、`Search.bas`、`CHAT_HISTORY.md`
- 用户：要求继续做 `attachments_json`，做完后准备进行一次实际使用测试。
  - 处理结果：已接入第一版附件元数据链路。当前不依赖新 UI 控件，而是从笔记文本中的 `@attach 路径` 标记提取附件声明，写入 `attachments_json`；旧库迁移时会为历史笔记补该字段；新建/编辑保存、同步接收变更、搜索匹配、文本导出都已纳入 `attachments_json`。
  - 说明：这是一条“先把数据链路打通，再补文件选择界面”的最小可用实现。由于当前环境无法直接运行 B4A/B4J IDE 编译和设备交互，本轮只完成了静态错误检查，尚未执行真正的端到端实机/桌面使用测试。
  - 校验：已对 `B4XMainPage.bas`、`NoteView.bas`、`Synchorize.bas`、`Search.bas`、`B4XPageData.bas` 做静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`NoteView.bas`、`Synchorize.bas`、`Search.bas`、`B4XPageData.bas`、`CHAT_HISTORY.md`
- 用户：反馈 B4J 仍然报错很多，要求继续排查运行环境。
  - 处理结果：已确认 B4J 编译时实际使用的是 `C:\JAVA\jdk-11.0.1`，对应的 `hs_err_pid15016.log` 显示 JVM 在 `javac.Main` 阶段发生 `EXCEPTION_ACCESS_VIOLATION`；当前工作区和常见安装目录里未发现可替代的 11/17 JDK，仅找到 `C:\Program Files\Java\jdk1.8.0_291`。初步判断这是 JDK/B4J 环境问题，不是当前 `.bas` 源码语法错误。
  - 后续建议：优先切换到更新的 JDK 11/17 再复编 B4J；如果需要继续，我可以接着帮你把当前 B4J 的 Java 配置路径核对出来，或者给出一套可直接执行的 JDK 切换步骤。
  - 涉及文件：`B4J/Objects/hs_err_pid15016.log`、`CHAT_HISTORY.md`
- 用户：明确要求继续使用 JDK 11.0.1，不接受切换版本。
  - 处理结果：已进一步验证 `C:\JAVA\jdk-11.0.1` 本体也会崩溃：无论直接执行 `javac.exe -version`、`java.exe -version`，还是加 `JAVA_TOOL_OPTIONS=-Xshare:off`、`-XX:-UseAOT`、`-Xint`，都会立刻触发同类 `EXCEPTION_ACCESS_VIOLATION`。这说明问题不在 B4A/B4J 配置，而在当前这套 11.0.1 安装本身。
  - 结论：如果必须坚持 11.0.1，唯一可行方向是用一份干净的 11.0.1 重新安装/替换当前损坏的 JDK 目录，然后再把 B4A/B4J 的 `JavaBin` 继续指向它。
  - 涉及文件：`B4A/Objects/hs_err_pid2928.log`、`B4J/Objects/hs_err_pid15016.log`、`CHAT_HISTORY.md`

## 2026-06-28
- 用户：反馈首页登录/注册/修改密码流程有多个问题，特别是“完成注册”总给通用提示、隐私政策页无法返回，以及平板上“忘记密码”按钮位置异常。
  - 处理结果：已在 `Regist_Page.bas` 保留并强化具体失败提示，移除 `Bntok_Click` 里的二次通用提示覆盖；注册查重从 `name` 统一为 `nickname` 以对齐登录逻辑；隐私政策弹窗改为基于 `Root` 的自适应尺寸，避免按钮被挤出可视区（B4A/B4J 都调整，并在 B4J 显式等待关闭结果）。
  - 处理结果（布局）：已在 `B4XMainPage.bas` 增加 `AdjustLoginLayout`，并在 `B4XPage_Created` 与 `B4XPage_Resize` 调用，确保“忘记密码”按钮在平板和小屏下不会越界到屏幕外。
  - 涉及文件：`Regist_Page.bas`、`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：反馈密码记录编辑页从“整页编辑”变成了“一条条字段弹窗”，要求恢复为点击后在一页中显示并编辑全部字段。
  - 处理结果：已在 `Psw_Page.bas` 重构编辑输入流程：`btnEdit` 现在打开一个单页编辑面板（Description/Username/Password/Email/Remark 同屏显示），点击 `Save` 后一次性回写，不再按字段依次弹出多个 `InputTemplate` 对话框。
  - 说明：保留原有数据校验与保存路径，不改变新增/编辑后写入 `psw` 和同步标记的逻辑，仅替换交互方式。
  - 涉及文件：`Psw_Page.bas`、`CHAT_HISTORY.md`
- 用户：指出导出格式应为 TXT（而非 CSV），并希望搜索结果也可导出。
  - 处理结果：已将导出呈现统一为 TXT：`B4XPageData.bas` 的导出文件名从 `mynote.text` 调整为 `mynote.txt`，提示文案改为 TXT；`Search.bas` 新增“导出结果TXT”按钮，支持将当前搜索结果按纯文本（UTF-8）导出为 `.txt` 并调用系统保存流程。
  - 说明：`B4XPageData.bas` 底层仍沿用 `SaveCSV` 生成逗号分隔文本，但文件扩展名和用户可见文案统一为 TXT；`Search.bas` 导出内容为可直接阅读的结构化纯文本。
  - 涉及文件：`B4XPageData.bas`、`Search.bas`、`CHAT_HISTORY.md`
- 用户：反馈平板上搜索导出按钮布局不完整，已在布局中改为 `Button2`（名称 `output`）并要求代码配合。
  - 处理结果：已在 `Search.bas` 改为优先绑定布局中的导出按钮（`output` 或 `Button2`），不再强制创建悬浮按钮；新增 `Button2_Click` / `output_Click` 与 `btnExportSearch_Click` 三个兼容入口，统一调用同一导出流程，按钮文案统一为 `TO TXT`。
  - 涉及文件：`Search.bas`、`CHAT_HISTORY.md`
- 用户：反馈登录 LOGIN 界面在平板上没有居中，要求优化布局适配。
  - 处理结果：已在 `B4XMainPage.bas` 增强 `AdjustLoginLayout`，将登录页主要控件（用户名、密码、登录、注册、修改密码、忘记密码）统一改为按屏幕宽度水平居中，并保持小屏安全边距，避免平板宽屏左偏和小屏越界。
  - 涉及文件：`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：反馈“打包闪退，不能完成打包”。
  - 处理结果：已复核 `B4J/Objects/hs_err_pid7504.log` 与当前环境，确认崩溃并非业务代码导致，而是 `C:\JAVA\jdk-11.0.1` 本体在启动 `java`/`javac` 时发生 `EXCEPTION_ACCESS_VIOLATION`（`jvm.dll+0x1e8e99`）；同时验证 `C:\JAVA\jdk-19.0.2` 可正常输出版本。`ide_state.json` 显示 B4JPackager11 使用 19.0.2 可完成 `jar/jdeps/javac/jlink` 并记录 `Done!`。
  - 结论：当前“打包闪退”的根因是 JDK 11.0.1 安装损坏或不稳定；需避免让编译链路落到该 JDK，统一改为稳定 JDK（当前机器上 19.0.2 已验证可用）。
  - 涉及文件：`B4J/Objects/hs_err_pid7504.log`、`B4J/Objects/ide_state.json`、`CHAT_HISTORY.md`
- 用户：反馈切到 `C:\JAVA\jdk-19.0.2\bin\javac.exe` 后可以生成 `MyNote.exe`，但启动即闪退。
  - 处理结果：已用 `run_debug.bat` 捕获到明确异常：`NoClassDefFoundError: javafx/scene/web/WebView`，说明打包运行时镜像缺少 `javafx.web` 模块；已在项目配置 `B4J/MySuperNote.b4j` 的 `#PackagerProperty: IncludedModules` 增加 `javafx.web`，并同步更新 `B4J/Objects/packager.json`。
  - 结论：EXE 闪退是运行模块缺失（非业务逻辑崩溃）；需基于新模块配置重新执行一次完整打包，生成包含 `javafx.web` 的新运行镜像。
  - 涉及文件：`B4J/MySuperNote.b4j`、`B4J/Objects/packager.json`、`CHAT_HISTORY.md`
- 用户：要求把密码规则改为“数字不少于 4 位”，并确认旧版 4 位密码用户升级后是否还能登录。
  - 处理结果：已在 `Regist_Page.bas` 将注册与修改密码校验从 `^\d{6}$` 调整为 `^\d{4,}$`，提示文案改为“请设置不少于4位的数字密码！”。登录校验逻辑未改动，仍按数据库中已保存的加密密码比对。
  - 结论：已存在的 4 位数字密码账号升级后可继续登录；本次调整只影响“新注册/改密时”的输入规则。
  - 涉及文件：`Regist_Page.bas`、`CHAT_HISTORY.md`
- 用户：在 `Page2Left` 新增了名为 `user` 的标签，希望显示当前登录用户名，避免用户忘记简写昵称。
  - 处理结果：已在 `B4XPageData.bas` 新增 `RefreshUserLabel`，并在 `B4XPage_Created` 与 `B4XPage_Appear` 调用；标签优先显示 `KVS("user")`，为空时回退 `MP.User_Name`，未登录时显示“用户: 未登录”。
  - 涉及文件：`B4XPageData.bas`、`CHAT_HISTORY.md`
- 用户：指出数据库迁移提示在用户点“Later/不合并”后，后续不再询问，询问何时会再次合并。
  - 处理结果：已修复 `B4XMainPage.bas` 迁移触发逻辑。此前当当前激活库不是旧库时会直接 `Return`，导致不再提示；现改为始终检查 `notesql.db` 是否仍是旧结构，并在每次进入主页面时继续询问迁移。迁移执行也改为显式从旧库文件读取（不依赖当前激活库），确保“先用新库运行，稍后再合并”场景可正常完成。
  - 新行为：只要旧库存在且仍需迁移，用户下次启动/回到主页面仍会被再次询问；迁移完成后进入“是否删除旧库备份”提示分支。
  - 涉及文件：`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：编译报错 `Undeclared variable 'finally'`（`B4XMainPage`），提示 `FinallyB4A/Objects/MyNote.json`。
  - 处理结果：已修复 `B4XMainPage.bas` 中 `DatabaseNeedsMigrationByName` 的异常处理写法，移除不被 B4X 语法支持的 `Finally` 块，改为 `Try/Catch` 后显式关闭 `db` 并返回结果。
  - 校验：已对 `B4XMainPage.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：移除 `NoteView` 浮球后出现 `EnsureEditorCaretVisible` / `UpdateFloatingBallLayout` 相关编译错误，并伴随 `Search` 未使用 warning。
  - 处理结果：已在 `NoteView.bas` 删除残留的 `UpdateFloatingBallLayout` 调用，补齐 Android 下 `EnsureEditorCaretVisible`、`Btx3_TextChanged`、`Btx3_FocusChanged`，保留自动滚动到当前输入行的能力；同时清理 `Search.bas` 中未使用的 `FindMatches` 和无效 `Keyword` 逻辑残留。
  - 校验：已对 `NoteView.bas`、`Search.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`NoteView.bas`、`Search.bas`、`CHAT_HISTORY.md`
- 用户：反馈长篇输入时输入法会遮挡正在编辑的日记内容，并指出浮球没有作用，要求移除。
  - 处理结果：已在 `NoteView.bas` 保留“输入位置自动可见”的 Android 自动滚动逻辑（文本变化、获得焦点、页面尺寸变化时自动滚动到当前光标行），同时移除了浮球相关 UI 与拖动滚动代码。
  - 校验：已对 `NoteView.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：希望在左侧拉出栏（TO TXT 所在侧栏）增加“关于说明”入口，用户点击后可查看 APP 最近更新时间和版本，而不必回登录页查看。
  - 处理结果：已在 `B4XPageData.bas` 增加侧栏“关于说明”能力。代码会优先绑定布局中已有的 `about` / `btnAbout` / `BntAbout` 按钮；若布局未提供，则自动在左侧栏追加一个“关于说明”按钮。点击后弹出说明框，显示应用名、版本（当前为 `V1`）以及最近更新时间（当前写为 `2026-07-19`）。
  - 校验：已对 `B4XPageData.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`B4XPageData.bas`、`CHAT_HISTORY.md`
- 用户：补充确认 `Page2Left` 中“关于说明”按钮的实际名称是 `BntAbout`，要求代码按真实名称更新以避免错误。
  - 处理结果：已在 `B4XPageData.bas` 调整 `BindAboutButton`，改为优先绑定布局中的 `BntAbout`，其余 `btnAbout` / `about` 仅作为兼容后备分支保留。
  - 校验：已对 `B4XPageData.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`B4XPageData.bas`、`CHAT_HISTORY.md`

## 2026-08-16
- 用户：要求在新建/查看日志页底部保留原来的时间格式，并在下一行增加农历日期显示。
  - 处理结果：已在 `NoteView.bas` 新增底部时间展示 helper，保留原 `MM/dd/yyyy_HH:mm:ss_星期X`（或当前系统生成的同结构时间串）作为第一行，并在第二行追加农历月日；新建日志时页面底部也会即时显示“当前时间 + 农历”预览，数据库中的原始 `time` 字段未改动。
  - 实现说明：仓库内没有现成农历工具，本次在 `NoteView.bas` 内嵌了 1901-2100 年农历换算表和最小转换逻辑，只用于界面显示，不影响同步、搜索和既有存储格式。
  - 校验：已对 `NoteView.bas` 执行静态错误检查，当前无报错。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：反馈导出时没有农历，要求在不污染原 `time` 兼容链路的前提下优化数据库，增加独立农历字段。
  - 处理结果：已将事件表扩展为持久化 `lunar_text` 字段，并在 `B4XMainPage.bas` 中接入建表/补列/旧库迁移/缺失回填；新建记录保存时会同步写入农历，旧记录在升级后会按现有 `time` 自动补全；列表页、查看页和 TXT 导出现在都会优先读取该字段，缺失时再按 `time` 回退计算。
  - 实现说明：原 `time` 字段保持不变，仍用于现有兼容定位与同步回退；农历单独落库，避免把显示文本混入旧的时间标识链路。
  - 校验：已对相关 `.bas` 文件执行静态错误检查，当前无报错。
  - 涉及文件：`B4XMainPage.bas`、`NoteView.bas`、`B4XPageData.bas`、`Search.bas`、`Synchorize.bas`、`CHAT_HISTORY.md`
- 用户：说明已在 `ViewCard` 布局中新增 `LabTime2` 标签，要求将农历单独显示到 `LabTime2`，不再和原时间共用 `LabTime`。
  - 处理结果：已在 `NoteView.bas` 调整底部时间显示逻辑，`LabTime` 仅显示原始时间串，`LabTime2` 单独显示农历文本；若旧布局未包含 `LabTime2`，则仍自动回退为原来的双行拼接显示，兼容未同步更新的布局文件。
  - 校验：已对 `NoteView.bas` 执行静态错误检查。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`
- 用户：APK 实测时发现底部只显示“农历”两个字，没有具体月日，要求分析原因。
  - 处理结果：已定位到 `B4XMainPage.bas` 的 `LunarYearDays` 循环写法错误。原实现错误地遍历了 `32768..8` 的所有整数，而不是按农历位掩码逐位右移，导致换算出的农历月/日可能超出有效范围，最终界面只剩前缀“农历”。现已改为按位掩码循环。
  - 校验：已对 `B4XMainPage.bas` 执行静态错误检查。
  - 涉及文件：`B4XMainPage.bas`、`CHAT_HISTORY.md`
- 用户：要求先用对应表做校核，不接受继续盲改，希望先确认当前农历结果以及整张表是否准确。
  - 处理结果：已用 .NET `ChineseLunisolarCalendar` 作为校核基准，逐年重建并比对 `1901-2100` 年表，确认旧表共有 `73` 个年份编码错误；已将 `B4XMainPage.bas` 中的农历年表替换为校核后的正确版本，并把 `LunarYearDays` 的月份位统计范围收紧到真实的 `12` 个月位。
  - 校核结果：`2026-08-16` 经过校核后应为 `农历七月初四`，与 .NET 直接换算结果一致；完整校核表已输出到工作区文件 `corrected_lunar_codes_1901_2100.txt` 便于复查。
  - 校验：待重新编译 APK 后做设备侧复核；当前已完成源码替换与静态错误检查。
  - 涉及文件：`B4XMainPage.bas`、`corrected_lunar_codes_1901_2100.txt`、`CHAT_HISTORY.md`
- 用户：反馈新增日记手动保存与离开页面自动保存均失效，要求排查根因。
  - 处理结果：已定位为 `NoteView.bas` 的 `B4XPage_CloseRequest` 在页面关闭前提前清空 `Add_Flag/Re_Flag/Edit_Flag` 与 `Search_view.Edit_Flag`，导致随后 `B4XPageData.B4XPage_Appear` 的提交分支无法执行，且 `B4XPage_Disappear` 自动保存分支被短路。现已移除 `CloseRequest` 中的提前清标志逻辑，保留取消按钮路径负责显式放弃编辑。
  - 事故教训：以后在没有明确修改功能说明时，不能随便改动对应功能的状态位、关闭流程、保存流程等代码；任何这类改动都必须先确认需求边界，并单独校验原有功能是否被破坏。
  - 校验：已对 `NoteView.bas` 执行静态错误检查。
  - 涉及文件：`NoteView.bas`、`CHAT_HISTORY.md`

## 2026-10-01
- 用户：要求在已登录的 GitHub 账户下创建私有仓库，并把当前项目代码导入进去。
  - 处理结果：已确认 GitHub 仓库 `yzhymail-create/Mynote` 存在且为空，准备将本地 Git 仓库连接到该远端并推送当前代码快照；同时补充 `.gitignore` 忽略 `hs_err_pid*.log`，避免 JVM 崩溃日志被误提交。
  - 说明：本次按“导入项目代码”处理，只提交项目源码与相关配置文件；运行期崩溃日志等临时产物不纳入远端仓库。
  - 涉及文件：`.gitignore`、`CHAT_HISTORY.md`

## 2026-08-22
- 用户：要求以后每次更新时，把最新更新日期和当前是第几个版本写到“关于说明”里，但不需要记录每次具体更新内容。
  - 处理结果：已将“关于说明”中的版本号与最近更新时间从 `B4XPageData.bas` 的局部常量，收口到 `B4XMainPage.bas` 统一维护；当前展示为“第2版”和“2026-08-22”。后续每次发版只需更新这一处即可，关于说明不会追加更新明细列表。
  - 涉及文件：`B4XMainPage.bas`、`B4XPageData.bas`、`CHAT_HISTORY.md`

## 2026-09-06
- 用户：反馈日记首次保存后，再次进入同一条日记补写内容时无法保存，希望恢复早期“可反复更新，离页自动保存”的行为。
  - 处理结果：已定位为日记编辑更新链路仍在使用旧参数长度，`events` 表增加 `lunar_text` 后，`NoteView.bas` 传给 `updateEvents` 的更新数组少了一项，导致已有日记更新保存异常。现已将编辑保存与离页自动保存统一改为在 `NoteView.bas` 直接构造完整更新参数并执行更新，同时兼容列表编辑与搜索编辑两种入口。
  - 额外处理：按“每次更新同步维护关于说明版本号和日期”的规则，已将关于说明更新为“第3版 / 2026-09-06”。
  - 涉及文件：`NoteView.bas`、`B4XMainPage.bas`、`CHAT_HISTORY.md`

