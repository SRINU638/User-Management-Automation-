#!/bin/bash

# ------------------------------
# Input Validation & Setup
# ------------------------------

FILE="$1"

BASE_DIR="/var/secure_store"
PASS_STORE="$BASE_DIR/passwords.txt"
LOGFILE="/var/log/user_mgmt.log"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "You must run this script as root (sudo)."
    exit 1
fi

# Validate input file
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage: $0 <user_input_file>"
    exit 1
fi

# Prepare directories & files
mkdir -p "$BASE_DIR"
touch "$PASS_STORE" "$LOGFILE"
chmod 600 "$PASS_STORE" "$LOGFILE"

# ------------------------------
# Custom Log Function
# ------------------------------
write_log() {
    printf "[%s] %s\n" "$(date '+%d-%m-%Y %H:%M:%S')" "$1" | tee -a "$LOGFILE"
}

# ------------------------------
# Password Generator
# ------------------------------
make_pass() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#%&*' | head -c 12
}

# ------------------------------
# Read File & Process Users
# ------------------------------
while IFS= read -r entry || [[ -n "$entry" ]]; do

    # Skip comments or empty
    [[ -z "$entry" || "$entry" =~ ^# ]] && continue

    # Remove whitespace
    clean="$(echo "$entry" | tr -d '[:space:]')"

    # Split username;groups
    user="$(echo "$clean" | awk -F ';' '{print $1}')"
    grps="$(echo "$clean" | awk -F ';' '{print $2}')"

    # Validate username
    if [[ -z "$user" ]]; then
        write_log "Invalid line found: '$entry' — Skipped."
        continue
    fi

    # Convert groups into array
    IFS=',' read -r -a grp_array <<< "$grps"

    # Ensure all groups exist
    for g in "${grp_array[@]}"; do
        [[ -z "$g" ]] && continue
        if ! getent group "$g" >/dev/null; then
            groupadd "$g"
            write_log "Group created: $g"
        fi
    done

    # Create user or update
    if id "$user" >/dev/null 2>&1; then
        write_log "User '$user' already exists — updating groups."
        usermod -a -G "$grps" "$user"
    else
        useradd -m -s /bin/bash -G "$grps" "$user"
        write_log "New user created: $user"
    fi

    # Validate User Home
    home_path="/home/$user"
    if [[ ! -d "$home_path" ]]; then
        mkdir -p "$home_path"
        write_log "Home directory created: $home_path"
    fi

    chown "$user:$user" "$home_path"
    chmod 700 "$home_path"

    # Generate & Assign Password
    pwd="$(make_pass)"
    echo "$user:$pwd" | chpasswd
    echo "$user:$pwd" >> "$PASS_STORE"
    write_log "Password set for '$user'"

done < "$FILE"

chmod 600 "$PASS_STORE"
write_log "User processing completed."

exit 0