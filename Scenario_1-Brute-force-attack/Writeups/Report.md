# Detection Use Case: RDP Brute Force Attack Detection

## Scenario Description
Simulated a brute force attack using repeated failed RDP login attempts from one Windows system to another, followed by a successful login. The goal was to identify and detect suspicious login patterns indicative of brute force behavior.

## Objective
Detect a sequence of multiple failed login attempts (Event ID 4625) followed by a successful login (Event ID 4624), especially if originating from a single IP, potentially indicating brute force behavior.

## Tools Used

- **SIEM:** Wazuh + ELK Stack  
  - **Log Source:** Windows Security Event Logs, Sysmon (planned for advanced process detection)  
  - **Lab Setup:**  
    - Two Windows 11 VMs: one attacker, one victim  
    - Wazuh Manager running on Ubuntu  
    - Winlogbeat configured to ship Windows logs to Wazuh

## Event ID / Data Source Mapping

| Source         | Event ID / Field | Description                        |
|----------------|------------------|------------------------------------|
| Windows Logs   | 4625             | Failed login attempt               |
| Windows Logs   | 4624             | Successful login                   |
| Sysmon         | 1                | Process creation (for future use)  |

## Detection Logic/Query

**Wazuh Rule:**

```xml
<group name="windows,authentication_failed,">
  <rule id="100010" level="10">
    <if_sid>18107</if_sid>
    <field name="win.system.eventID">4625</field>
    <description>Multiple failed logon attempts from same source</description>
    <frequency>5</frequency>
    <timeframe>300</timeframe>
    <same_source_ip />
    <group>brute_force,rdp</group>
  </rule>
</group>

<group name="windows,authentication_successful,">
  <rule id="100011" level="7">
    <if_sid>18107</if_sid>
    <field name="win.system.eventID">4624</field>
    <field name="win.event_data.LogonType">10</field> <!-- RDP logon -->
    <description>Successful RDP login after brute force</description>
    <group>rdp,successful_logon</group>
  </rule>
</group>
````

## Sample Alert Screenshot

Located at screenshots folder

## Logs:

**Failed Logon (4625):**

```json
{
  "event_id": "4625",
  "source_ip": "192.168.0.7",
  "status": "0xC000006A",
  "logon_type": "3",
  "user": "MAVERICK",
  "message": "An account failed to log on."
}
```

**Successful Logon (4624):**

```json
{
  "event_id": "4624",
  "source_ip": "192.168.0.7",
  "logon_type": "10",
  "user": "MAVERICK",
  "message": "An account was successfully logged on."
}
```

## Analyst Notes/Recommendations

* Correlate multiple failed attempts from the same IP followed by a successful RDP login.
* Review the user account involved and check for any privilege escalation.
* Possible false positives include mistyped passwords or legitimate users attempting multiple logins.

## Detection Status

✅ Successfully Triggered
