# Detection Use Case: Hidden User Account Creation (T1136)

## Scenario Description
A hidden local user account was created on a Windows system using command-line tools, followed by adding the account to a privileged group (Administrators). This activity could be used by attackers for persistence or privilege escalation.

## Objective
Detect the creation of a new user account and its addition to a privileged group, especially if performed outside business hours or by non-standard means.

## Tools Used
**SIEM:** Wazuh  
- **Log Source:** Windows Event Logs  
- **Lab Setup:**  
  - Attacker Machine: Kali Linux  
  - Victim Machines: Windows 11 VM and Windows 7 VM  
  - SIEM: Wazuh OVA VM  
  - All machines connected in a virtual environment for event correlation.

## Event ID / Data Source Mapping

| Source         | Event ID / Field | Description                                  |
|----------------|------------------|----------------------------------------------|
| Windows Logs   | 4720             | A user account was created                   |
| Windows Logs   | 4728             | A user was added to a global security group  |
| Windows Logs   | 4732             | A user was added to a local security group   |

## Detection Logic/Query

**Wazuh Rule Example:**
```xml
<group name="windows,">
  <rule id="100200" level="10">
    <if_sid>18107</if_sid>
    <field name="win.eventdata.TargetUserName">support1</field>
    <description>Suspicious User Account Created: support1</description>
  </rule>

  <rule id="100201" level="12">
    <if_sid>18110</if_sid>
    <field name="win.eventdata.MemberName">support1</field>
    <field name="win.eventdata.GroupName">Administrators</field>
    <description>Suspicious User Added to Administrators Group: support1</description>
  </rule>
</group>
````
## Analyst Notes/Recommendations

* Confirm whether the account creation was authorized.
* Investigate the actor or process that initiated the change.
* Check if the account is hidden, unused, or has suspicious logon activity.
* Disable or delete the user account if unauthorized.
* Review audit logs for additional signs of compromise.

**Possible False Positives:**

* Legitimate IT admin actions during after-hours maintenance
* Account creation via automated scripts or software deployment systems

## Detection Status

✅ **Successfully Triggered**
