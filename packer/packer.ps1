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

return @{
    server = "hashi-server-{0}" -f $ImageSuffix
    client = "hashi-client-{0}" -f $ImageSuffix
    output = $output | Select -Last 10
} | ConvertTo-Json