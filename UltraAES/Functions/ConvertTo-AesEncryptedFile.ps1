Function ConvertTo-AesEncryptedFile {
    [CmdLetBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Content,
        [Parameter(Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory, Position=2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        [bool]$IsIVDefault = $false
    )

    process {
        if ($PSCmdlet.ShouldProcess($OutputFile, "Write encrypted content to file")) {
            try {
                $EncryptedContent = ConvertTo-AesEncryptedString -Content $Content -Key $Key -IsIVDefault $IsIVDefault

                $EncryptedContent | Out-File -FilePath $OutputFile -Encoding UTF8 -Force
                Write-Verbose "Encrypted content was written to file: $OutputFile"
                
            } catch {
                throw "Cannot write encrypted content to file: $OutputFile. Error details: $_"
            }
        }
    }
}