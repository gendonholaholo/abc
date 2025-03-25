$files = Get-ChildItem -Path "." -Recurse -File | Where-Object {
    $_.Name -notmatch 'encrypt\.ps1|decrypt\.ps1|\.git' -and
    $_.FullName -notmatch '\\.git\\'
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    if (-not $content.StartsWith("ENC::")) {
        Write-Host "Lewat: $($file.FullName) bukan file terenkripsi."
        continue
    }

    $base64 = $content.Substring(5)
    try {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
        Set-Content $file.FullName $decoded
        Write-Host "Didekripsi: $($file.FullName)"
    } catch {
        Write-Host "Gagal dekripsi: $($file.FullName)"
    }
}
