# Slack API Wrapper For Powershell

## Simple Post Message Example
```
$token  =  Read-Host  "Token"
$channel  =  Read-Host  "Channel"
$messageText  =  "*Date:* $((Get-Date).ToString())`n*Message* Lorem ipsum dolor sit amet "

[SlackAPIWrapper]$slack= [SlackAPIWrapper]::new($token)

$query = [SlackAPIWrapper]::NewQuery()
$query.Add('channel', $channel)
$query.Add('text', $message)

$messageResponse = $slack.SendCommand("chat.postMessage", $query)
```