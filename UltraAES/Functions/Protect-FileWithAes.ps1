Function Protect-FileWithAes {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$InputFile,
        [Parameter(Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory, Position=2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        [bool]$IsIVDefault = $false
    )

    process {
        
    }
}