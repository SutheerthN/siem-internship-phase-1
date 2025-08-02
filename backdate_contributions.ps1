# Total number of commits
$totalCommits = 36

# Define date range
$startDate = Get-Date "2025-04-26"
$endDate = Get-Date "2025-06-15"

# Function to generate a random date
function Get-RandomDate($start, $end) {
    $range = ($end - $start).Days
    return $start.AddDays((Get-Random -Minimum 0 -Maximum $range))
}

# Generate random dates
$dates = @()
for ($i = 0; $i -lt $totalCommits; $i++) {
    $dates += Get-RandomDate $startDate $endDate
}

# Group commits by day and sort times in ascending order
$grouped = $dates | Group-Object | Sort-Object Name

# Loop through each day and commit in time order
$commitNum = 1
foreach ($group in $grouped) {
    $date = [datetime]$group.Name
    $times = 7..20 | Get-Random -Count $group.Count | Sort-Object  # hours from 7AM to 8PM
    $minute = 0

    foreach ($hour in $times) {
        $commitTime = $date.AddHours($hour).AddMinutes($minute)
        $timestamp = $commitTime.ToString("yyyy-MM-ddTHH:mm:ss")

        # Set env for backdated commit
        $env:GIT_AUTHOR_DATE = $timestamp
        $env:GIT_COMMITTER_DATE = $timestamp

        # Simulate a small change
        Add-Content -Path "README.md" -Value "`n# Backdated commit $commitNum on $timestamp"

        git add README.md
        git commit -m "Backdated commit $commitNum on $timestamp"

        # Clean up
        Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
        Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

        $commitNum++
    }
}