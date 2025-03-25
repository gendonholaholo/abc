$encryptedText = [Console]::In.ReadToEnd()
$bytes = [System.Convert]::FromBase64String($encryptedText)
$Decrypted = [System.Text.Encoding]::UTF8.GetString(
    [System.Security.Cryptography.ProtectedData]::Unprotect(
        $bytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
)
[Console]::Out.WriteLine($Decrypted)

# Konfigurasi Git (jalankan sekali di terminal PowerShell di root project)
# git config filter.crypt.clean "powershell -File scripts/encrypt.ps1"
# git config filter.crypt.smudge "powershell -File scripts/decrypt.ps1"
