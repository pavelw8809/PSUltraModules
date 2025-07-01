Function ConvertFrom-AesEncryptedFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$InputFile,
        [Parameter(Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,
        [bool]$IsIVDefault = $false
    )

    process {
        if ($PSCmdlet.ShouldProcess($InputFile, "Read and encrypt content from file")) {
            try {
                $FileContent = Get-FileContent -FilePath $InputFile
                $DecryptedContent = ConvertFrom-AesEncryptedString -Content $FileContent -Key $Key -IsIVDefault $IsIVDefault
                Write-Verbose "Decrypted content was read and encrypted from file: $OutputFile"
                
                return $DecryptedContent
            } catch {
                throw "Cannot read and encrypt content from file: $InputFile. Error details: $_"
            }
        }
    }
}