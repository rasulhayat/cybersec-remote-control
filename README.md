# RemoteControl

RemoteControl is a bash-based network reconnaissance tool that automates anonymous scanning using a remote server via SSH. It leverages `nipe`, `whois`, and `nmap` to gather intelligence from a remote target while preserving the operator’s anonymity.

---

## 🧭 Project Objectives

- Automate connection to a remote Linux server over SSH
- Perform Whois and Nmap scans on user-specified targets
- Ensure anonymity through TOR routing using `nipe`
- Log scanning activities for future audit or analysis

---

## 📁 Project Structure

### 1. Installations and Anonymity Check
- Installs required tools (`geoip-bin`, `tor`, `sshpass`, `vsftpd`, and `nipe`)
- Ensures anonymity through the `nipe` Perl module
- Displays the spoofed IP address and country

### 2. Automated Remote Execution via SSH
- Prompts the user for IP address, credentials, and scanning target
- Connects to a remote server and validates access
- Executes `whois` and `nmap` remotely and retrieves results via FTP

### 3. Logging and Output
- Stores logs at `/var/log/nr.log`
- Saves retrieved scan data (`whois` and `nmap`) in the local directory
- Uses `figlet` for UI banners

---

## 🛠️ Dependencies

The script checks and installs the following:
- `geoip-bin`
- `tor`
- `sshpass`
- `vsftpd`
- `nipe`
- `cpan` and `cpanm` (Perl modules)
- `figlet` (for visual banners)

---

## 🚀 How to Use

### Step 1: Launch with `sudo`

```bash
sudo ./remote-control.sh
```

### Step 2: Enter Remote Server Details

- Remote IP address
- Username and password

### Step 3: Enter the Target

- Specify domain/IP to scan
- The script will validate the domain using remote `whois`

### Step 4: Review Output

- Whois and Nmap results are pulled to your local machine
- Log is updated at `/var/log/nr.log`

---

## 📂 Files Generated

- `whois_<domain>` — Whois results
- `nmap_<domain>` — Nmap scan report
- `/var/log/nr.log` — History of scanned domains and tools used

---

## 🔐 Security Notes

- Passwords are not stored and are masked during entry
- SSH host key checking is disabled (`StrictHostKeyChecking=no`)
- Runs only with `sudo` for privilege-dependent operations (e.g., FTP, TOR)

---

## 📌 Tips

- If the remote server blocks FTP, ensure `vsftpd` is allowed through firewalls
- Use IP addresses for consistency if DNS fails during Whois
- `nipe` helps ensure that your scans appear to originate from outside your true region

---

## 👨‍💻 Author

Cybersecurity Automation Script — Created by Rasul Al-Hayat

---

## 🧪 Sample Output

```
[*] You are anonymous..
[*] Your Spoofed IP address is: 185.220.101.202, Spoofed country: Germany

[*] Enter Credentials for the Remote Server
[?] Enter Remote IP Address: 123.45.67.89
[?] Enter Remote User: admin
[?] Enter Remote Password: ********

Uptime: 14:32:05 up 10 days
IP address: 123.45.67.89
Country: United States

[*] Whoising victim's address...
[@] Whois data was saved into /home/user/whois_example.com

[*] Scanning victim's address...
[@] nmap scan was saved into /home/user/nmap_example.com
```

## 🛠️ Future works

- removal of sudo excution within script. Sudo only required when executing script.
- Validating package installation.
- replacing sshpass with ssh keys to improve security.
