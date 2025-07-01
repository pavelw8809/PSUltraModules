Function ConvertTo-AesEncryptedString {
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
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
        if (!(@(16,24,32).Contains($KeyBytes.Length))) {
            throw [System.ArgumentException]::new("Invalid key length. Key must be 16, 24 or 32 bytes (128, 256 or 256 bits) long.")
        }

        $IV = [byte[]]::new(16)

        if (!($IsIVDefault)) {
            $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
            $rng.GetBytes($IV)
            Write-Verbose "Random IV generated."
        }
        else {
            Write-Verbose "Using default zero IV"
        }

        if ($PSCmdlet.ShouldProcess("Content", "Encrypt")) {
            try {
                $aes = [System.Security.Cryptography.Aes]::Create()
                $aes.Mode = 'CBC'
                $aes.Padding = 'PKCS7'
                $aes.Key = $KeyBytes
                $aes.IV = $IV

                $encryptor = $aes.CreateEncryptor()

                $ms = New-Object System.IO.MemoryStream
                $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
                $sw = New-Object System.IO.StreamWriter($cs)

                $sw.Write($Content)
                $sw.Flush()
                $cs.FlushFinalBlock()
                $sw.Close()

                $EncryptedBytes = $ms.ToArray()

                if ($IsIVDefault) {
                    $Base64Output = [Convert]::ToBase64String($EncryptedBytes)
                } else {
                    $ResultBytes = New-Object byte[] ($IV.Length + $EncryptedBytes.Length)
                    [Array]::Copy($IV, 0, $ResultBytes, 0, $IV.Length)
                    [Array]::Copy($EncryptedBytes, 0, $ResultBytes, $IV.Length, $EncryptedBytes.Length)

                    $Base64Output = [Convert]::ToBase64String($ResultBytes)
                }

                return $Base64Output
            } catch {
                throw "Encryption error: $_"
            } finally {
                if ($sw) { $sw.Dispose() }
                if ($cs) { $cs.Dispose() }
                if ($ms) { $ms.Dispose() }
                if ($encryptor) { $encryptor.Dispose() }
                if ($aes) { $aes.Dispose() }
            }
        }

    }
}