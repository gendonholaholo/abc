$files = Get-ChildItem -Path "." -Recurse -File | Where-Object {
    $_.Name -notmatch 'encrypt\.ps1|decrypt\.ps1|\.git' -and
    $_.FullName -notmatch '\\.git\\'
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    if ($content.StartsWith("ENC::")) {
        Write-Host "Lewat: $($file.FullName) sudah terenkripsi."
        continue
    }

    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
    Set-Content $file.FullName ("ENC::" + $encoded)
    Write-Host "Terenkripsi: $($file.FullName)"
}
