# deploy_agent_bsemakula-blip
Run it from the repo folder with ./deploy_agent.sh, and it needs python3 and zip (checked at startup).
Menu: 1 Deploy, 2 Run, 3 Archive, 4 Exit.
Roster: Option A copies the first N rows from the template (max 10). Option B generates N rows from the script’s arrays with counts at 0.
total_sessions is 5 for A and 1 for B (sed sets it), because it’s prior sessions + 1.
Permissions: chmod +x on the script, chmod 600 on config.json.
Thresholds: defaults 75 and 50 on empty input. Both must be numbers, and failure must be lower than warning, otherwise the old values are kept.
Archiving: mv into archives/attendance/ and archives/absent/ as name_YYYYMMDD_HHMMSS.log. Missing logs are skipped with a message.
Trap: active from after the overwrite prompt until setup ends. On Ctrl+C or Ctrl+Z it zips the partial project to attendance_tracker_<name>_archive.zip, deletes the folder, and exits. Test it by pressing the keys at a prompt mid-deploy, then run ls and unzip -l.

Tests Run

**Deployed structure:** After deploying, I ran `ls -R attendance_tracker_<name>`
and confirmed it matched the required layout: attendance_checker.py, Helpers/
(assets.csv, config.json) and reports/. I also checked permissions with `ls -l`
and ran the app as part of the deploy step.

**Ctrl+C / Ctrl+Z:** Start a deploy and press Ctrl+C (or Ctrl+Z) at any prompt
before it finishes. The script zips what exists so far into
attendance_tracker_<name>_archive.zip, deletes the incomplete folder, and exits.
Check with `ls` and `unzip -l attendance_tracker_<name>_archive.zip`.
The zip contains whatever had been created when the interrupt happened.

 unzip -l attendance_tracker_test_archive.zip
Archive:  attendance_tracker_test_archive.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  2026-10-14 22:56   attendance_tracker_test/
        0  2026-10-14 22:56   attendance_tracker_test/Helpers/
      123  2026-10-14 22:56   attendance_tracker_test/Helpers/config.json
     8147  2026-10-14 22:56   attendance_tracker_test/attendance_checker.py
        0  2026-10-14 22:56   attendance_tracker_test/reports/
---------                     -------
     8270                     5 files
