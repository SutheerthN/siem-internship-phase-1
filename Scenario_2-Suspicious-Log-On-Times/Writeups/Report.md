# Detection Use Case: Suspicious Logon Time Detection (8:00PM to 7:00AM)

## Scenario Description
An attacker gains access to valid credentials and logs in to the system during non-standard business hours (8:00PM to 7:00AM), which is considered suspicious in the organization's context.

## Objective
To detect successful logon attempts occurring during predefined suspicious hours (8:00PM to 7:00AM), which may indicate unauthorized access or lateral movement.

## Tools Used
**SIEM**: Wazuh  
- **Log Source**: Windows Security Event Logs  
- **Lab Setup**:  
  - One Windows 11 machine configured as the endpoint with Winlogbeat agent installed.  
  - Wazuh manager running on a Debian-based server.  
  - Filebeat and Elasticsearch set up to receive, analyze, and visualize logs.  

## Event ID / Data Source Mapping

| Source        | Event ID / Field           | Description                         |
|---------------|-----------------------------|-------------------------------------|
| Windows Logs  | 4624                        | Successful logon event              |
| Windows Logs  | `win.system.systemTime`     | Time of the event in UTC            |
| Windows Logs  | `win.eventdata.targetUserName` | User who logged in              |

## Detection Logic/Query
Detection implemented via Wazuh custom rule and time-based filtering
Code snippet is at "screenshots/photos.md"


## Logs or Sample Event

```json
{
  "data": {
    "win": {
      "system": {
        "eventID": "4624",
        "systemTime": "2025-06-10T16:35:17.2524911Z"
      },
      "eventdata": {
        "targetUserName": "Administrator"
      }
    }
  },
  "agent": {
    "name": "windows11",
    "ip": "192.168.1.8"
  }
}
```

## Analyst Notes/Recommendations

* Cross-check login time with known working hours and legitimate user activity.
* Review source IP and geolocation, if available.
* Correlate with previous failed login attempts or lateral movement attempts.
* Investigate further if login occurred from a new device or IP.

### Possible False Positives?

* Legitimate logins by IT or admin staff after hours.
* Scheduled tasks running under Administrator account.

## Detection Status

✅ Successfully Triggered
