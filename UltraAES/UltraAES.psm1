Get-ChildItem -Path "$PSScriptRoot\Private" -Filter '*.ps1' | Foreach-Object {
    . $_.FullName
}

. "$PSScriptRoot\ConvertTo-AesEncryptedString"
. "$PSScriptRoot\ConvertFrom-AesEncryptedString"