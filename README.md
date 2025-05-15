# siem-internship-phase-1
# 🔍 Detection Use Case Repository

## 🛠️ Lab Setup & Attack Simulation Procedure

This section outlines the tools, environment, and step-by-step procedures followed to simulate real-world attack scenarios in a controlled lab environment using **Wazuh SIEM**, **Windows VMs**, and **Sysmon + Winlogbeat**.

---

### ✅ Environment Setup

| Component         | Details                                                                    |
| ----------------- | -------------------------------------------------------------------------- |
| **SIEM**          | Wazuh Manager (Ubuntu 22.04) + ELK Stack (Kibana, Elasticsearch, Logstash) |
| **Endpoints**     | Windows 11 VM (Victim), Windows 7 VM (Attacker), Kali Linux (optional)     |
| **Log Forwarder** | Winlogbeat 9.x installed on Windows VMs                                    |
| **Sysmon**        | Installed on Victim machine for detailed event logging (Process/Network)   |
| **Network**       | All machines on same VirtualBox internal NAT network                       |

---

### 🔗 Integration & Logging Flow

```
[Windows Logs / Sysmon] → Winlogbeat → Wazuh Agent → Wazuh Manager → Elasticsearch → Kibana
```

---

## 🧪 Attack Simulation Procedures

### 1. 🔐 RDP Brute Force Attack Detection

**Goal**: Trigger multiple failed logins (`Event ID 4625`) followed by a successful RDP login (`4624`).

#### Steps:

1. From Attacker (Win 7 VM), run:

   ```powershell
   for ($i=1; $i -le 10; $i++) {
     net use \\192.168.x.x\IPC$ /user:WrongUser WrongPassword
   }
   ```
2. Then, use correct credentials to RDP into Victim machine.
3. Check Wazuh alerts for correlation of multiple `4625` followed by `4624`.

---

### 2. 🕗 Suspicious Logon Time Detection

**Goal**: Detect successful logins during off-hours (8:00PM–7:00AM).

#### Steps:

1. Wait until off-hours or manually adjust system time.
2. Perform login using `RDP` or console.
3. Wazuh rule triggers on `4624` with time filtering logic in UTC.

---

### 3. 🔁 RDP Lateral Movement Detection (T1021.001)

**Goal**: Simulate attacker using RDP to move laterally across systems.

#### Steps:

1. From Attacker machine:

   * Attempt multiple failed RDP logins to Target.
   * Use correct creds for successful RDP (`LogonType 10`).
2. Enable Sysmon to capture:

   * `Event ID 3`: Network connection from attacker IP
   * `Event ID 1`: mstsc.exe launch
3. Wazuh detects multiple `4625`, followed by `4624`, and Sysmon network/process data.

---

### 4. 🧹 Log Tampering Detection (T1562.002)

**Goal**: Simulate attacker clearing logs to hide activity.

#### Steps:

1. On Victim (Win11), open PowerShell as admin.
2. Run commands like:

   ```powershell
   wevtutil cl Security
   Clear-EventLog -LogName Security
   auditpol /clear
   ```
3. Wazuh rules trigger on:

   * Sysmon `Event ID 1` (command execution)
   * PowerShell `4104` (script block logging)
   * Windows Log `1102` (Security log cleared)

---

### 5. 🧑‍💻 Hidden User Account Creation (T1136)

**Goal**: Simulate stealthy persistence by creating a hidden admin account.

#### Steps:

1. On Victim, run:

   ```cmd
   net user support1 password123 /add
   net localgroup administrators support1 /add
   ```
2. Wazuh rules monitor:

   * `4720`: New account creation
   * `4728` / `4732`: Added to privileged groups
3. Cross-reference with timestamp, user, and logon behavior for anomalies.

---

### 🔎 Detection Verification

Each scenario was validated using:

* **Kibana Dashboard**
* **Wazuh alerts in `/var/ossec/logs/alerts/alerts.json`**
* **Screenshots captured under `/screenshots` folder**
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reflection & Evaluation questions
### 1. What is the role of SIEM in modern cybersecurity?

SIEM (Security Information and Event Management) collects, aggregates, and analyzes security logs from multiple sources to detect threats in real-time. It enables centralized monitoring, alerting, and correlation of security events, helping organizations respond quickly to attacks and maintain compliance.

---

### 2. What challenges did you face while setting up your SOC lab?

Challenges included configuring log forwarding properly, ensuring time synchronization across VMs, handling different log formats, tuning detection rules to reduce false positives, and setting up a network environment that simulates real-world conditions without complexity overwhelming the system.

---

### 3. What are the differences between Sysmon logs and Windows Security logs?

* **Sysmon logs** provide detailed, process-level information like process creation, network connections, and file changes, offering granular visibility into system activity.
* **Windows Security logs** focus on audit events such as login attempts, account changes, and policy modifications, providing insight into security-relevant user and system activities.

---

### 4. How does a brute force attack appear in logs? Mention specific Event IDs.

A brute force attack typically shows multiple failed login attempts followed by a successful login.
Key Event IDs:

* **4625**: Failed login attempts.
* **4624 (LogonType 3 or 10)**: Successful logins (network or remote interactive).

---

### 5. How would you detect a login outside normal business hours?

Define business hours in the SIEM or detection logic and create rules to alert on successful logins occurring outside these hours by filtering event timestamps. Typically, look for Event ID **4624** with logon type indicating interactive or remote login outside the defined time window.

---

### 6. Describe how RDP lateral movement is tracked in event logs.

RDP lateral movement is detected by monitoring for:

* Multiple failed RDP login attempts (Event ID **4625**).
* Followed by a successful RDP login (Event ID **4624**, LogonType 10).
* Correlate source IPs with internal network addresses and process creation events (e.g., `mstsc.exe` via Sysmon) to confirm suspicious lateral movement activity.

---

### 7. What is the risk of log tampering, and how can we detect it?

Log tampering hides attacker activity by deleting or clearing logs, preventing forensic analysis and detection.
Detection methods include:

* Monitoring event IDs like **1102** (log cleared).
* Detecting process executions of tools like `wevtutil`, `Clear-EventLog`, or suspicious PowerShell commands via Sysmon and PowerShell logs.

---

### 8. What improvements would you make in your lab setup if given more time?

Improvements could include integrating more diverse log sources (firewalls, IDS), automating alert response workflows, implementing threat intelligence feeds, refining correlation rules to reduce false positives, and testing more complex attack simulations for advanced detection capabilities.

---

### 9. How will this phase help you in real-world interviews or jobs?

It provides hands-on experience with SIEM setup, attack simulation, log analysis, and detection rule creation. This practical knowledge demonstrates my understanding of security monitoring, incident detection, and response workflows, which are highly valued in cybersecurity roles.

---

### 10. What was your biggest takeaway from Phase 1?

Understanding how crucial log collection and correlation are to effective threat detection, and how even basic simulated attacks can reveal gaps in security posture. Also, learning the importance of continuous tuning and validation of detection rules to build a reliable SOC environment.

# Backdated commit 1 on 2025-01-05T07:00:00

# Backdated commit 2 on 2025-02-05T13:00:00

# Backdated commit 3 on 2025-02-05T19:00:00

# Backdated commit 4 on 2025-02-06T09:00:00

# Backdated commit 5 on 2025-03-05T10:00:00

# Backdated commit 6 on 2025-03-06T09:00:00

# Backdated commit 7 on 2025-03-06T16:00:00

# Backdated commit 8 on 2025-04-05T10:00:00

# Backdated commit 9 on 2025-04-06T08:00:00

# Backdated commit 10 on 2025-04-06T15:00:00

# Backdated commit 11 on 2025-05-05T15:00:00

# Backdated commit 12 on 2025-05-05T17:00:00

# Backdated commit 13 on 2025-08-06T09:00:00

# Backdated commit 14 on 2025-08-06T15:00:00

# Backdated commit 15 on 2025-10-05T09:00:00

# Backdated commit 16 on 2025-10-06T11:00:00

# Backdated commit 17 on 2025-11-05T07:00:00

# Backdated commit 18 on 2025-12-05T09:00:00

# Backdated commit 19 on 2025-12-05T20:00:00

# Backdated commit 20 on 2025-12-05T15:00:00

# Backdated commit 21 on 2025-12-05T11:00:00

# Backdated commit 22 on 2025-12-05T07:00:00

# Backdated commit 23 on 2025-12-05T13:00:00

# Backdated commit 24 on 2025-12-05T14:00:00

# Backdated commit 25 on 2025-12-05T17:00:00

# Backdated commit 26 on 2025-12-05T07:00:00

# Backdated commit 27 on 2025-12-05T09:00:00

# Backdated commit 28 on 2025-12-05T17:00:00

# Backdated commit 29 on 2025-12-05T16:00:00

# Backdated commit 30 on 2025-12-05T19:00:00

# Backdated commit 31 on 2025-12-05T14:00:00

# Backdated commit 32 on 2025-12-05T16:00:00

# Backdated commit 33 on 2025-12-05T16:00:00

# Backdated commit 34 on 2025-12-05T08:00:00

# Backdated commit 35 on 2025-12-05T17:00:00

# Backdated commit 36 on 2025-12-05T17:00:00

Commit #1 on 2025-05-06 09:01

Commit #2 on 2025-05-04 09:01

Commit #3 on 2025-05-15 09:04

Commit #4 on 2025-05-15 09:14

Commit #5 on 2025-05-15 09:23
