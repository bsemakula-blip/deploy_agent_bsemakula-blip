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

# Feature to be implemented
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

    mkdir -p "$projdir/Helpers" "$projdir/reports" || {
	    echo "Error: could not create directories."
            return 1
    }


    cp templates/attendance_checker.py "$projdir/" || {
	    echo "Error: could not copy attendance_checker.py"
            return 1
    }


    cp templates/config.json "$projdir/Helpers/" || {
	    echo "Error: could not copy config.json"
            return 1
    }

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
