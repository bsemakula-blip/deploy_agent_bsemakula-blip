# deploy_agent_bsemakula-blip

A shell script (`deploy_agent.sh`) that deploys, runs, and archives logs for the
Student Attendance Tracker, and cleans up if the deployment is interrupted.

## Requirements

- bash, `python3`, and `zip` (checked at startup; the script stops with a message if one is missing)
- Run the script **from the repo folder**, because template paths are relative:

```bash
cd deploy_agent_bsemakula-blip
./deploy_agent.sh
```

## Repo layout

```
deploy_agent_bsemakula-blip/
├── deploy_agent.sh
├── README.md
└── templates/
    ├── attendance_checker.py
    ├── assets.csv
    └── config.json
```

## Choosing a feature

I used an interactive menu:

```
1. Deploy the app
2. Run the app
3. Archive the log files
4. Exit
```

## Feature 1: Deploy

1. Asks for a project name and creates `attendance_tracker_<name>/`.
   If it already exists, it asks whether to overwrite; answering anything but `y` aborts with nothing changed.
2. Creates `Helpers/` and `reports/`, then copies `attendance_checker.py` and `config.json` from `templates/`.
3. Builds the roster in `Helpers/assets.csv`:
   - **Option A:** copies the header plus the first N students from `templates/assets.csv` (N from 1 to 10). These rows carry 4 prior sessions each.
   - **Option B:** generates N students from name/email arrays in the script, with Attendance and Absence counts at 0.
4. Sets permissions: `chmod +x` on `attendance_checker.py` and `chmod 600` on `Helpers/config.json`, then prints both with `ls -l`.
5. Offers to update the alert thresholds (see below).
6. Verifies the deployment by running the app.

### How `total_sessions` stays consistent

`total_sessions` is always **prior sessions + 1** (today's session).
Option A rows have 4 prior sessions, so it stays **5**. Option B starts at 0 prior sessions, so the script sets it to **1** with `sed`.

### Threshold update

The script asks whether to update the thresholds. If yes:

- It reads `warning` (default 75) and `failure` (default 50). Empty input uses the default.
- Both values must be whole numbers, and `failure` must be lower than `warning`. Otherwise the current values are kept and a message is shown.
- Valid values are written with `sed`, which changes only the `"warning"` and `"failure"` lines of `config.json`.

## Feature 2: Run

Asks for the project name and runs `python3 attendance_checker.py` inside that project folder (in a subshell, so the script stays in the repo folder). If the project doesn't exist, it shows an error.

## Feature 3: Archive logs

Asks for the project name, then for each of `reports/attendance.log` and `reports/absent.log`:

- If the log exists, it is **moved** into its own folder with a timestamp in the name:

```
attendance_tracker_<name>/archives/attendance/attendance_YYYYMMDD_HHMMSS.log
attendance_tracker_<name>/archives/absent/absent_YYYYMMDD_HHMMSS.log
```

- If the log doesn't exist (for example, nobody was absent), it prints that it is skipping it and continues.

Both logs from one run share the same timestamp. The final path of each archived log is printed.

## Interrupt handling (Ctrl+C and Ctrl+Z)

During deployment the script traps `SIGINT` and `SIGTSTP`. The trap is installed **after** the overwrite prompt and **before** anything is created, so an interrupt can never delete a project the user chose to keep. It is removed when setup finishes, so it doesn't affect the marking session.

On either signal the script:

1. prints that the deployment was interrupted,
2. zips whatever exists of `attendance_tracker_<name>/` into `attendance_tracker_<name>_archive.zip`,
3. deletes the incomplete folder,
4. exits.

### How to test it

Start a deploy and press Ctrl+C (or Ctrl+Z) at any prompt before it finishes, then check:

```bash
ls
unzip -l attendance_tracker_<name>_archive.zip
```

The folder should be gone and the zip should hold whatever had been created at that moment. Example from interrupting right after the template copy (the roster step hadn't run yet, so there is no `assets.csv`):

```
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
```

## How I tested

- **Structure:** after deploying, ran `ls -R attendance_tracker_<name>` and confirmed `attendance_checker.py`, `Helpers/` (`assets.csv`, `config.json`) and `reports/`. Checked permissions with `ls -l`.
- **Both roster options:** checked `assets.csv` and `total_sessions` (5 for A, 1 for B).
- **Invalid input:** empty project name, student counts of `0`, `11` and `abc`, non-numeric thresholds, and a failure value above the warning.
- **Existing directory:** answered `n` (nothing changed) and `y` (overwritten).
- **Archiving:** ran after a marking session with and without absences to check the skip message.
- **Interrupts:** Ctrl+C and Ctrl+Z mid-deploy, checking the zip and that the folder was removed.

## Video folder
https://drive.google.com/drive/folders/1jnc-PLy_eFNM-BMwEwkZKqihBm4OA3zo?usp=sharing
