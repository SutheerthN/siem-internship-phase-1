# Detection Use Case: Log Tampering Detection (T1562.002)

## Scenario Description
After a brute force attack simulation, the attacker attempts to hide their tracks by clearing Windows Event Logs using commands like `wevtutil cl Security`, `Clear-EventLog`, or `auditpol /clear`.

## Objective
Detect when event logs are cleared using log tampering commands. This includes monitoring for process execution, script block logging, and log clear audit events.

## Tools Used
**SIEM**: Wazuh  
- **Log Source**: Windows Event Logs, Sysmon, PowerShell Logs  
- **Lab Setup**:  
  - Attacker Machine: Kali Linux  
  - Victim Machine: Windows 11 VM with Sysmon, Wazuh Agent, and PowerShell logging enabled  
  - SIEM Server: Wazuh Manager OVA  

## Event ID / Data Source Mapping

| Source           | Event ID / Field | Description                             |
|------------------|------------------|-----------------------------------------|
| Windows Logs     | 1102             | Security log was cleared                |
| Sysmon           | 1                | Process creation for wevtutil/auditpol  |
| PowerShell Logs  | 4104             | PowerShell script block execution logged|
| Windows Logs     | 4625             | (Precursor) Failed login attempts       |

## Detection Logic/Query

**Wazuh Custom Rules (local_rules.xml):**
```xml
<group name="windows,sysmon,logtampering">
  <rule id="100010" level="10">
    <if_sid>61602</if_sid>
    <field name="win.system.eventID">1</field>
    <match>wevtutil</match>
    <description>Log tampering attempt: wevtutil command used</description>
  </rule>

  <rule id="100011" level="10">
    <if_sid>61602</if_sid>
    <match>Clear-EventLog</match>
    <description>Log tampering attempt: PowerShell Clear-EventLog used</description>
  </rule>

  <rule id="100012" level="10">
    <if_sid>61602</if_sid>
    <match>auditpol</match>
    <description>Log tampering attempt: auditpol used</description>
  </rule>

  <rule id="100013" level="12">
    <field name="win.system.eventID">1102</field>
    <description>Security log was cleared (Log Tampering Detected)</description>
  </rule>
</group>
````
## Analyst Notes/Recommendations

* Investigate if this event follows a suspicious login attempt.
* Check if this was an administrative maintenance task or a potential attacker trying to cover tracks.
* Correlate with failed logins, lateral movement, or privilege escalation.
* Check the timestamp of log clearing against other suspicious activity.

### Possible False Positives

* Legitimate system administrator clearing logs as part of routine maintenance.
* Security software or scripts designed to rotate/clear logs.

## Detection Status

✅ **Successfully Triggered**
