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
