Function ConvertFrom-AesEncryptedString {
    [CmdLetBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Content,
        [Parameter(Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,
        [bool]$IsIVDefault = $false
    )

    process {
        if ($PSCmdlet.ShouldProcess("Content", "Decrypt")) {
            $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
            if (!(@(16,24,32).Contains($KeyBytes.Length))) {
                throw [System.ArgumentException]::new("Invalid key length. Key must be 16, 24 or 32 bytes (128, 256 or 256 bits) long.")
            }

            $CipherBytes = [Convert]::FromBase64String($Content)

            $IV = if ($IsIVDefault) {
                Write-Verbose "Using default zero IV"
                [byte[]]::new(16)
            } else {
                Write-Verbose "Using IV included in the content"
                if ($CipherBytes.Length -lt 17) {
                    throw "Encrypted content is too short to contain both IV and the content"
                }
                $IVPart = $CipherBytes[0..15]
                $IVPart
            }

            $ContentPart = if ($IsIVDefault) {
                $CipherBytes
            } else {
                $CipherBytes[16..($CipherBytes.Length-1)]
            }

            try {
                $aes = [System.Security.Cryptography.Aes]::Create()
                $aes.Mode = 'CBC'
                $aes.Padding = 'PKCS7'
                $aes.Key = $KeyBytes
                $aes.IV = $IV

                $decryptor = $aes.CreateDecryptor()
                $ms = New-Object System.IO.MemoryStream(,$ContentPart)
                $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
                $sr = New-Object System.IO.StreamReader($cs)

                return $sr.ReadToEnd()
            } catch {
                throw "Decryption error: $_"
            }
        }
    }
}