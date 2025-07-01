Function Get-FileContent {
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    if (!(Test-Path -Path $FilePath -PathType Leaf)) {
        throw "File: $FilePath was not found"
    }

    try {
        $FileContent = Get-Content -Path $FilePath -Raw -Encoding UTF8 -ErrorAction Stop
        return $FileContent
    } catch {
       throw "Failed to read file: $FilePath. Error details: $_"
    }
}