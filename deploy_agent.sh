#!/bin/bash

# Pre flight check
check_prereq() {
    local missing=0

    for cmd in python3 zip; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "[OK] $cmd found"
        else
            echo "[ERROR] $cmd is not installed."
            missing=1
        fi
    done

    if [ "$missing" -eq 1 ]; then
	    echo "Install what is missing (from zip or python above) and try again."
        exit 1
    fi

    python3 --version
}

#Number of students to be in the table
getcount() {
	read -p "How many students? (1-$1): " count
	if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ] || [ "$count" -gt "$1" ]; then
		echo "Error: enter a whole number from 1 to $1"
		return 1
	fi
	}

# Roster with random names and detials
build_roster() {
echo "Roster options:"
echo " A) Copy from template (4 prior sessions each)"
echo " B) Generate a fresh roster (counts start at 0)"
read -p "Choose A or B: " opt

case "$opt" in
	[Aa])
		getcount 10 || return 1
		head -n $((count + 1)) templates/assets.csv > "$projdir/Helpers/assets.csv" || {
			echo "Error, could not copy roster."
		return 1
}
;;
[Bb])
	getcount 10 || return 1
	names=("Ian" "Gold" "Miriam" "Kevine" "Noah" "Zach" "Benji" "Simon" "Tim" "Amanda")
	emails=("ian@example.com" "gold@example.com" "miriam@example.com" "kevine@example.com" "noah@example.com" "zach@example.com" "benji@example.com" "simon@example.com" "tim@example.com" "amanda@example.com")

echo "Email,Names,Attendance Count,Absence Count" > "$projdir/Helpers/assets.csv"
            for ((i=0; i<count; i++)); do
                echo "${emails[$i]},${names[$i]},0,0" >> "$projdir/Helpers/assets.csv"
            done

            sed -i 's/"total_sessions": [0-9]*/"total_sessions": 1/' "$projdir/Helpers/config.json"
            ;;
        *)
            echo "Invalid option."
            return 1
      ;;
    esac

    echo "Roster created with $count students."

}

# Update the alert thresholds in config.json
update_thresholds() {
    read -p "Update the alert thresholds? y/n: " ans
    if [ "$ans" != "y" ]; then
        return 0
    fi

    # Empty input returns to the defaults
    read -p "Warning threshold (default 75): " warn
    warn=${warn:-75}
    read -p "Failure threshold (default 50): " fail
    fail=${fail:-50}

    # Both must be numbers before sed touches the file
    if ! [[ "$warn" =~ ^[0-9]+$ ]] || ! [[ "$fail" =~ ^[0-9]+$ ]]; then
        echo "Thresholds must be numbers. Keeping the current values."
        return 0
    fi

    # Failure has to be lower than warning
    if [ "$fail" -ge "$warn" ]; then
        echo "Failure must be lower than warning. Keeping the current values."
        return 0
    fi

    # Change only the warning and failure lines
    sed -i "s/\"warning\": [0-9]*/\"warning\": $warn/" "$projdir/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $fail/" "$projdir/Helpers/config.json"
    echo "Thresholds updated: warning $warn, failure $fail"
}

# Deploys the project
deploy() {

    read -p "Enter the project name: " name

    if [ -z "$name" ]; then
	    echo "Cannot be empty, enter a name."
	    return 1
    fi

    projdir="attendance_tracker_$name"

    if [ -d "$projdir" ]; then
	    read -p "$projdir already exists. Overwrite y/n :" ans
	    if [ "$ans" = "y" ]; then
	        rm -rf "$projdir"
	    else
	        echo "Aborted. Nothing was changed"
	        return 1
	    fi
    fi
#Make the directory

    mkdir -p "$projdir/Helpers" "$projdir/reports" || {
	    echo "Error: could not create directories."
            return 1
    }

#Copy the files according to instructions

    cp templates/attendance_checker.py "$projdir/" || {
	    echo "Error: could not copy attendance_checker.py"
            return 1
    }


    cp templates/config.json "$projdir/Helpers/" || {
	    echo "Error: could not copy config.json"
            return 1
    }

build_roster || return 1

#Necessary permisions given and checked
chmod +x "$projdir/attendance_checker.py"
chmod 600 "$projdir/Helpers/config.json"
ls -l "$projdir/attendance_checker.py"
ls -l "$projdir/Helpers/config.json"


echo "Folder structure created in $projdir"

}

run_app() {
    echo "run app"
}

archive_log() {
    echo "archive"
}

#Main Menu
check_prereq

while true; do
    echo ""
    echo "Attendance tracker"
    echo "1. Deploy the app"
    echo "2. Run the app"
    echo "3. Archive the log files"
    echo "4. Exit"
    read -p "Choose an option from 1 to 4: " choice

    case "$choice" in
        1) deploy ;;
        2) run_app ;;
        3) archive_log ;;
        4) echo "Exited."; exit 0 ;;
        *) echo "Invalid choice. Enter a number from 1 to 4." ;;
    esac
done

