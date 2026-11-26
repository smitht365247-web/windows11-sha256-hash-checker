========================================================================
  Free Windows 11 Single-Folder SHA-256 Hash Checker (v1.3)
========================================================================

Just unzip this folder and double-click RUN_CHECKER.bat - zero installs
and no coding required.

- Hashes top-level files only (non-recursive) inside your chosen folder.
- Outputs folder_hashes.csv inside that folder (UTF-8, Excel-ready).
- Always writes a CSV header row, even when the folder has no files.
- Safe for paths with spaces, [brackets], and bare drive letters (E:\).
- Locked files are safely logged as ACCESS_DENIED instead of crashing.

------------------------------------------------------------------------
WINDOWS SMARTSCREEN UNBLOCK INSTRUCTIONS
------------------------------------------------------------------------
Because .bat and .ps1 files downloaded from the internet are unsigned,
Windows SmartScreen may show "Windows protected your PC" on first run:
  Option A: Click "More info" -> "Run anyway".
  Option B: Right-click the downloaded .zip file BEFORE extracting ->
            Properties -> check "Unblock" -> Apply / OK -> then extract.
