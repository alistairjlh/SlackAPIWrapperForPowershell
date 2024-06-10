using module '.\SlackAPIWrapper.psm1'

$token = Read-Host "Token"
$channel = Read-Host "Channel"

$messageText = "
*Date:* $((Get-Date).ToString())
*Message* Lorem ipsum dolor sit amet 
" 

function postMessage($channel, $message) { 

    $query = [SlackAPIWrapper]::NewQuery()
    $query.Add('channel', $channel)
    $query.Add('text', $message)

    $messageResponse = $slack.SendCommand("chat.postMessage", $query)

    return $messageResponse

}

function updateMessage($channel, $ts, $message) {

    $query = [SlackAPIWrapper]::NewQuery()
    $query.Add('channel', $channel)
    $query.Add('ts', $ts)
    $query.Add('text', $message)
 
    $messageResponse = $slack.SendCommand("chat.update", $query)

    return $messageResponse

}

[SlackAPIWrapper]$slack= [SlackAPIWrapper]::new($token) 

$postMessageResponse = postMessage -channel $channel -message $messageText 

Start-Sleep -Seconds 5

$updateMessageResponse = updateMessage -channel $channel -ts $postMessageResponse.ts -message "$messageText `n*Updated* "