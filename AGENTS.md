# AGENTS.md

## Scope and active app shape
- This repo is a B4X multi-target app: shared logic lives in root-level `.bas` modules, while platform entry projects live in `B4A/MyNote.b4a`, `B4J/MySuperNote.b4j`, and `B4i/B4iProject.b4i`.
- The active note app is driven by `B4XMainPage.bas` plus pages such as `B4XPageData.bas`, `NoteView.bas`, `Search.bas`, `Psw_Page.bas`, `Gpsw_page.bas`, `Login_Page.bas`, `Regist_Page.bas`, and `Synchorize.bas`.
- `B4i/B4iProject.b4i` points at `B4XPage2.bas` / `B4XPage3.bas`, which are older sample-style pages and not part of the main note/password workflow used by B4A/B4J.

## Architecture and data flow
- `B4XMainPage.bas` is the hub: it initializes `AESEncryption`, `KeyValueStore`, local `SQL1`, creates the SQLite schema (`events`, `users`, `psw`, `delevents`, `delPSW`), and registers all B4X pages.
- Local-first behavior is the default. On first run, `notesql.db` is copied from assets if present; otherwise the schema is created in `xui.DefaultFolder`.
- Authentication is local SQLite by default (`btnLogin_Click` in `B4XMainPage.bas`). The jRDC path exists but is commented out.
- Main note flow: `B4XPageData.bas` lists rows from `events` -> `NoteView.bas` edits/adds a note -> changes are written back through `PageData.Note_Paremeters` and page flags (`Add_Flag`, `Edit_Flag`, `Re_Flag`).
- Search flow: `Search.bas` does not hit SQL `LIKE`; it loads all user events via `MP.searchEvents` and filters in code with case-insensitive `IndexOf` checks (`FindWordInText`), then highlights matches with `BuildHighlightedText`.
- Password flow: `Psw_Page.bas` shows `psw` records in `B4XTable`; `Gpsw_page.bas` is a separate password generator/strength checker.
- Sync flow: `Synchorize.bas` is peer-to-peer socket sync on port `51042`, driven by `MyMessage` lists and row flags (`sync_flag`, `new`, `changed`) plus delete journals in `delevents` / `delpsw`.
- Current delete-journal behavior is asymmetric: note deletes write tombstones (`B4XPageData.bas` -> `delevents`), but password deletes in `Psw_Page.bas` currently remove from `psw` directly without inserting into `delpsw`.

## Project-specific conventions
- Preserve B4X conditional branches exactly (`#If B4A`, `#If B4J`, etc.). Many handlers are duplicated with platform-specific event names like `..._Click` vs `..._MouseClicked`.
- Shared modules are referenced from platform projects with `|relative|..\ModuleName`; editing a root `.bas` file changes both Android and desktop builds.
- SQL is mostly centralized as constants in `B4XMainPage.bas` (`getEvents`, `updateEvents`, `addEvents`, `sycEvents`, `sycPsw`), but many pages still embed direct SQL strings. Search both the page and `B4XMainPage.bas` before changing queries.
- The code often identifies rows indirectly through the `time` column and then queries `RowId` (for example in `B4XPageData.bas`, `NoteView.bas`, `Search.bas`, `Psw_Page.bas`). Do not assume a map already carries the SQLite row id unless you trace where it was built.
- Search edit handoff depends on extra map keys from `Search.bas` (`kw`, `hit_field`, `hit_start`, `hit_len`); `NoteView.bas` uses these in `ApplySearchHit` to select/scroll the matched description text.
- `NoteView.bas` can persist changes on `B4XPage_Disappear` even when the user did not explicitly press OK, as long as `Add_Flag` / `Edit_Flag` is still set.
- Deleting notes should usually record tombstones (`INSERT INTO delevents ...`) before removing the row, as done in `B4XPageData.bas`; this is part of the sync protocol.
- `Psw_Page.bas` updates both `B4XTable1.sql1`'s internal `data` table and the app-level `psw` table. Keep both in sync when changing password-note editing behavior.
- User passwords are AES-encrypted through `MP.EncDec`; do not mix this with the separate jRDC/MySQL login config without checking both sides.
- Page IDs are stringly-typed and include inconsistent casing/spelling (for example `"synchorize"`, `"Gpsw_page"`, `"GPsw_Page"`, `"login_Page"` / `"Login_Page"`). Reuse existing literals from call sites instead of normalizing names in isolated edits.

## External integrations
- `jRDC2.bas` contains a hardcoded remote endpoint (`/rdc`) and is paired with the bundled server project under `mynote_jrdc2/jRDC/`.
- Server-side SQL commands live in `mynote_jrdc2/jRDC/Files/config.properties`; treat it as environment-specific and avoid copying secrets from it into new docs or code.
- Desktop packaging depends on B4J Packager plus a local Inno Setup install, configured in `B4J/MySuperNote.b4j` and `B4J/InstallerScript.iss`.

## Working in this repo
- Prefer editing root `.bas` modules and shared asset/layout references; only touch `B4A/Objects`, `B4J/Objects`, `Output`, or `AutoBackups` when explicitly asked, as they are generated artifacts.
- There is no discoverable automated test suite. Validate changes by compiling the affected B4A/B4J project in the B4X IDE and smoke-testing the relevant flow: login -> notes list -> add/edit/delete/search -> password notes -> sync.
- If you add a new page or shared module, register it in `B4XMainPage.B4XPage_Created` and make sure the platform projects reference the module if it is not already linked.
- Persistent AI session notes live in `CHAT_HISTORY.md`. Read it together with `AGENTS.md` before non-trivial work, and append concise dated summaries after meaningful tasks.

