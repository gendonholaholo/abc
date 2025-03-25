$inputText = [Console]::In.ReadToEnd()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($inputText)
$Encrypted = [System.Convert]::ToBase64String(
    [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
)
[Console]::Out.WriteLine($Encrypted)
