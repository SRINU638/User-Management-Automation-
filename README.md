Here’s a clean, professional **README.md** you can include with your **User Management Automation (SysOps Challenge)** project 

---

# User Management Automation — SysOps Challenge

## Overview

This project automates the creation and management of Linux user accounts from a formatted text file.
It is designed for SysOps or DevOps engineers who need to quickly onboard multiple developers while ensuring consistent user setup, permissions, and logging.

The automation script — `create_users.sh` — reads a list of users and their groups, creates accounts, assigns home directories, sets permissions, generates random passwords, and logs every action.

---

## Features
 Reads input file (`users.txt`) containing usernames and group memberships
 Ignores comments (`#`) and blank line Creates users, groups, and home directories if missing
 Generates secure 12-character random passwords
 Saves credentials to a password file (with `600` permissions)
 Logs all actions, warnings, and errors
 Handles existing users and groups gracefully
 Works in both Linux and WSL environments

---

## Project Structure

```
├── create_users.sh           # Main automation script
├── Users.txt                 # Input file containing usernames and groups
├── /var/secure/              # Secure storage for generated password file (optional)
└── /mnt/c/Users/User/Desktop/UMA/
      ├── user_passwords.txt  # Passwords saved for each user
      └── user_management.log # Detailed execution log
```

---

##  Input File Format

Each line should follow:

```
username;group1,group2,group3
```

### Example:

```
# Developer Accounts
light; sudo,dev,www-data
siyoni; sudo
manoj; dev,www-data
```

* Lines starting with `#` are ignored.
* Whitespace is automatically trimmed.
* Groups are optional.

---

## Usage Instructions


```bash
chmod +x create_users.sh
```

###  Run the script as root:

```bash
sudo ./create_users.sh Users.txt
```

>  If you’re on Windows Subsystem for Linux (WSL), use the full path to the input file:
>
> ```bash
> sudo ./create_users.sh /mnt/c/Users/User/Documents/Users.txt
> ```

### Verify the results:

```bash
cat /mnt/c/Users/User/Desktop/UMA/user_passwords.txt
cat /mnt/c/Users/User/Desktop/UMA/user_management.log
```

---

##  Example Output

**Terminal Log:**

```
2025-11-13 09:55:12 - ===== Starting user creation process =====
2025-11-13 09:55:12 - Group 'light' exists
2025-11-13 09:55:12 - User 'light' exists — updating groups
2025-11-13 09:55:12 - Added 'light' to groups: sudo,dev,www-data
2025-11-13 09:55:12 - Ensured home directory for 'light'
2025-11-13 09:55:12 - Set password for 'light'
```

**Password File:**

```
light:4hR#T2sQw9pZ
siyoni:M1n&F7uLx0kP
manoj:Z8s@K3yBp2vQ
```

---

## Security Considerations

* Passwords and logs are stored with `chmod 600` permissions (owner-only access).
* Use a secure directory such as `/var/secure` for production deployments.
* Avoid sharing the generated password file; rotate passwords after first login.
* Always run the script with **root privileges** to ensure full access to user and group management.

---

##  Design Explanation (Step-by-Step)

1. **Configuration Section**
   Defines paths for logs, passwords, and base directories.

2. **Validation & Setup**
   Ensures the script is run as root, verifies input, and prepares working directories.

3. **Main Loop**

   * Reads each line from the input file
   * Skips empty or commented lines
   * Creates user and primary group
   * Adds to supplementary groups
   * Generates a random password
   * Writes credentials and logs

4. **Logging and Syncing**

   * Writes timestamped logs to both Linux and Windows paths
   * Syncs data safely between systems

---

## Testing Checklist

 Run the script with valid and invalid inputs
 Check for skipped users (invalid format or empty lines)
 Verify permissions on `/home/username`
 Confirm password and log file creation
 Re-run to ensure idempotence (existing users handled gracefully)

---

## Dependencies

* `bash`
* `tr`
* `tee`
* `chpasswd` (standard on most Linux distros)
* `dos2unix` *(optional for WSL)*

---

##  Example Demo Commands

```bash
sudo ./create_users.sh Users.txt
id light
ls -ld /home/light
sudo cat /mnt/c/Users/User/Desktop/UMA/user_passwords.txt
sudo cat /mnt/c/Users/User/Desktop/UMA/user_management.log
```

---

**Author:** *Lallu Srinivas*
**Project:** *User Management Automation (SysOps Challenge)*


---

Would you like me to give you this README in a **.md (Markdown file)** ready for submission (you can open it in VS Code or upload it)?
