# Detection Use Case: Lateral Movement via RDP (T1021.001)

## Scenario Description
An attacker attempts multiple failed Remote Desktop Protocol (RDP) logins from a non-standard internal IP address to a target machine. After several failures, a successful login (Logon Type 10) occurs from the same IP address, indicating potential lateral movement within the network.

## Objective
To detect and alert on successful RDP connections from suspicious IPs, especially when preceded by multiple failed login attempts. Bonus: detect access from geolocated VPN or external IPs.

## Tools Used
**SIEM**: Wazuh  
- **Log Source**: Windows Event Logs  
- **Lab Setup**:  
  - Attacker Machine: Windows 7 VM  
  - Target Machine: Windows 11 VM  
  - SIEM: Wazuh OVA with Filebeat integration  
  - Kali Linux used for network-level visibility (optional)  

## Event ID / Data Source Mapping

| Source        | Event ID / Field         | Description                         |
|---------------|--------------------------|-------------------------------------|
| Windows Logs  | 4625                     | Failed RDP login attempt            |
| Windows Logs  | 4624 (LogonType=10)      | Successful RDP login (RemoteInteractive) |
| Sysmon        | Event ID 3               | Network connection initiated        |
| Sysmon        | Event ID 1               | Process creation (e.g., mstsc.exe)  |

## Detection Logic/Query

**Wazuh Custom Rule** in `local_rules.xml`:

```xml
<group name="windows,rdp,lateral_movement,">
  <rule id="100100" level="10">
    <if_sid>18107</if_sid>
    <field name="win.system.eventID">4624</field>
    <field name="win.system.eventData.LogonType">10</field>
    <description>Suspicious successful RDP login from external IP</description>
    <regex field="srcip">^(?!192\.168\.|10\.).*</regex>
  </rule>

  <rule id="100101" level="12">
    <if_matched_sid>18109</if_matched_sid>
    <field name="srcip">!192.168.*</field>
    <same_source_ip />
    <frequency>5</frequency>
    <description>Multiple failed RDP logon attempts</description>
  </rule>

  <rule id="100102" level="15">
    <if_matched_sid>100100</if_matched_sid>
    <if_matched_sid>100101</if_matched_sid>
    <description>Potential Lateral Movement via RDP detected</description>
  </rule>
</group>
````

## Sample Alert Screenshot
![Screenshot 2025-06-13 184639](https://github.com/user-attachments/assets/ae5371fe-b326-49f4-9e83-b86ce7248d29)



## Analyst Notes/Recommendations

* Investigate the source IP and verify if it's within your trusted internal range.
* Correlate with other artifacts like process creation logs (mstsc.exe).
* Check if the login occurred outside business hours.
* Validate whether the user was expected to RDP at that time.
* Review for VPN or external access if GeoIP is enabled.

**Possible False Positives:**

* Legitimate administrative access from non-standard IPs (e.g., IT support).
* Misconfigured systems using alternate IP ranges.

## Detection Status

✅ **Successfully Triggered**
