param
(
    [Alias('ch')][string] $Channel
    , [Alias('team')][string] $TeamNickname = "gn"
)

# https://slack.com/app_redirect?team={TEAM_ID}&channel={CHANNEL_NAME|CHANNEL_ID}
# Examples:
#  https://slack.com/app_redirect?team=T04C55E8R&channel=C04C55E9X

Write-Host " * Parameters"
Write-Host "Channel:       '$Channel'"
Write-Host "TeamNickname:  '$TeamNickname'"

$baseUrl = ""
$current = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path
$configFile = "$($current)\slack.Config.json"

Write-Host " * Loading Config: '$configFile'"

$configContent = Get-Content -Raw -Path $configFile
$config = ConvertFrom-Json $configContent

if (!$Channel -and !$TeamNickname) {
    $baseUrl = "slack://open"
}
else {
    $teamItem = $config.Teams.Where( { 
        $_.Name -like $TeamNickname -or
        $_.Nickname -like $TeamNickname })
    if (!$teamItem) {
        throw "No '$TeamNickname' team found in the config...."
    }
    if ($Channel) {
        $baseUrl = "https://slack.com/app_redirect?team=$($teamItem.Id)&channel=$($Channel)"
    }
    else {
        $baseUrl = "slack://open?team=$($teamItem.Id)"
    }
}

Write-Host " * Local Variables"
Write-Host "teamItem.Name: '$($teamItem.Name)'"
Write-Host "teamItem.Id:   '$($teamItem.Id)'"
Write-Host "baseUrl:       '$($baseUrl)'"

Write-Host " * Opening Slack"
Start-Process $baseUrl

Write-Host "----"
Write-Host "BOOYAH!"
