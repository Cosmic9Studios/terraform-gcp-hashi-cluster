Param
(
    [parameter(Position=0)]
    [string]$Project,

    [parameter(Position=1)]
    [string]$ImageSuffix,

    [parameter(Position=2)]
    [string]$SSHUser,

    [parameter(Position=3)]
    [string]$AccountJson
)

$command = "packer build -var 'project={0}' -var 'image_suffix={1}' -var 'ssh_username={2}' -var 'account_json_path={3}' packer.json" -f $Project, $ImageSuffix, $SSHUser, $AccountJson
$output = Invoke-Expression $command | Out-String

$server = $output | Select-String -Pattern 'hashi-server-[^\s]+' -AllMatches
$client = $output | Select-String -Pattern 'hashi-client-[^\s]+' -AllMatches

return @{
    server = $server.Matches.value | Select-Object -Last 1
    client = $client.Matches.value | Select-Object -Last 1
} | ConvertTo-Json