# Windows 11 SHA-256 Hash Checker (Free, Zero-Install) [v1.3]

A lightweight, read-only Windows 10/11 utility that generates a clean **SHA-256 integrity manifest (`folder_hashes.csv`)** for any folder in one double-click—no coding, no PowerShell execution-policy tweaks, and no third-party installs required.

## Features
- **1-Click Drag-and-Drop Launcher (`RUN_CHECKER.bat`):** Just unzip and double-click.
- **Native Windows PowerShell:** Uses built-in `Get-FileHash -Algorithm SHA256` with zero external dependencies.
- **Crash-Safe:** Uses `-LiteralPath` for folders with spaces/brackets and logs locked files as `ACCESS_DENIED` instead of aborting.
- **Consistent UTF-8 BOM CSV Output (v1.3):** Header row is always written—including for empty folders—with UTF-8 BOM encoding.
- **Hardened Launcher (v1.3):** Includes an empty-quote launcher guard (`if not defined target` after quote stripping), bare drive-letter support, and explicit `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe` invocation.
- **SmartScreen Unblock Note:** If Windows SmartScreen prompts on downloaded `.bat`/`.ps1` files, click **More info -> Run anyway** (or right-click the ZIP/files -> **Properties -> Unblock**).
- **License:** MIT License (`LICENSE.txt`, Copyright 2026 Taylor Smith).

## Quick Start
1. Click **Code -> Download ZIP** (or grab the pre-packaged ZIP free at [Gumroad](https://smitht365.gumroad.com/l/olkmxs)).
2. Extract the folder and double-click `RUN_CHECKER.bat`.
3. Drag and drop any folder into the window and press **Enter**.
4. Open the generated `folder_hashes.csv` inside that folder.

## Need Recursive Multi-Drive Verification, Deduplication, or SMART Health Audits?
If you manage multi-terabyte external drives or cold-storage backups, check out the full zero-install Windows 11 suites:
- **[Windows 11 SHA-256 Backup & File Deduplication Toolkit ($15)](https://smitht365.gumroad.com/l/skwuly)** — Recursive manifests, bit-rot verification, safe quarantine deduplication (moves duplicates, never deletes), and drive-to-drive diffing.
- **[Complete 2-in-1 Backup, SHA-256 & Drive Health Suite ($29 Bundle)](https://smitht365.gumroad.com/l/hvprmw)** — Includes the full SHA-256 Toolkit plus automated dry-run Robocopy sync and SMART disk health CSV auditing.).
