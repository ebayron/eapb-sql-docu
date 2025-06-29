# Get events related to a stopping of a service (latest 10 records)
Get-EventLog Application -Message "*service*stop*" -Newest 10 | Select TimeGenerated, Source, Message

# Get events with Error EntryType (for the past hour)
Get-EventLog Application -EntryType Error -After (Get-Date).AddHours(-24) |
Where-Object -FilterScript {$_.Source -ne 'Perflib' -and $_.Source -ne 'PerfNet'} |
Select TimeGenerated, Source, Message | Format-List

# Get events with Warning EntryType (for the past hour)
Get-EventLog Application -EntryType Warning -After (Get-Date).AddHours(-1) | Select TimeGenerated, Source, Message #| Format-List