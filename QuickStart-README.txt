Windows 11 Single-Folder SHA-256 Hash Checker (v1.3) - Quick Start
===================================================================

1. Extract all files from the ZIP into a folder on your Windows 10/11 PC.
   - SmartScreen Note: If Windows SmartScreen warns you when launching
     RUN_CHECKER.bat or Check-Folder-SHA256.ps1, click "More info" ->
     "Run anyway", or right-click the ZIP before extracting -> Properties ->
     check "Unblock" -> OK.
2. Double-click RUN_CHECKER.bat.
3. Paste or drag-and-drop any folder or bare drive letter (e.g., D:)
   into the window and press Enter.
4. The script hashes top-level files (non-recursive) and writes
   folder_hashes.csv inside the target folder.
   - Empty folders still produce a valid UTF-8 with BOM header-only CSV.
   - Locked or restricted files are recorded as ACCESS_DENIED without
     crashing the scan.

License: MIT License (see LICENSE.txt, Copyright 2026 Taylor Smith).
