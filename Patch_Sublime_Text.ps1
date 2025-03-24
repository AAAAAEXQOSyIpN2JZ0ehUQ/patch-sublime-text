[Console]::OutputEncoding = [System.Text.Encoding]::UTF8 # Codificación para PowerShell

# ====================================================
#   SCRIPT:                   Patch Sublime Text
#   DESARROLLADO POR:         Jony Rivera (Dzhoni)
#   FECHA DE ACTUALIZACIÓN:   05-05-2025
#   CONTACTO TELEGRAM:        https://t.me/Dzhoni_dev
#   GITHUB OFICIAL:           https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/patch-sublime-text
# ====================================================

Clear-Host # Pantalla limpia. Continuando con la ejecución...

# Colores de texto
$Black = [ConsoleColor]::Black
$Red = [ConsoleColor]::Red
$Green = [ConsoleColor]::Green
$Yellow = [ConsoleColor]::Yellow
$blue = [ConsoleColor]::Blue
$Magenta = [ConsoleColor]::Magenta
$Cyan = [ConsoleColor]::Cyan
$White = [ConsoleColor]::White

# Mostrar el banner
Write-Host "====================================================" -ForegroundColor $Cyan
Write-Host "   SCRIPT:                   Patch Sublime Text" -ForegroundColor $Green
Write-Host "   DESARROLLADO POR:         Jony Rivera (Dzhoni)" -ForegroundColor $White
Write-Host "   FECHA DE ACTUALIZACIÓN:   05-05-2025" -ForegroundColor $Yellow
Write-Host "   CONTACTO TELEGRAM:        https://t.me/Dzhoni_dev" -ForegroundColor $White
Write-Host "   GITHUB OFICIAL:           https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/patch-sublime-text" -ForegroundColor $White
Write-Host "====================================================" -ForegroundColor $Cyan
Write-Host ""  # Espacio en blanco para mayor claridad visual

# Verificar y establecer la política de ejecución para evitar restricciones
Write-Host "[*] Verificando política de ejecución..." -ForegroundColor $Yellow
$executionPolicy = Get-ExecutionPolicy

if ($executionPolicy -ne "RemoteSigned") {
    Write-Host "[*] Configurando política de ejecución a 'RemoteSigned'..." -ForegroundColor $Cyan
    Set-ExecutionPolicy RemoteSigned -Force
    Write-Host "[+] Política de ejecución configurada correctamente." -ForegroundColor $Green
} else {
    Write-Host "[+] La política de ejecución ya está establecida en 'RemoteSigned'" -ForegroundColor $Green
}

# Función para descargar el archivo de configuración a una carpeta temporal
function Download-ConfigFile {
    param (
        [string]$url,             # URL de donde descargar el archivo
        [string]$destinationPath  # Ruta de destino donde guardar el archivo
    )

    Write-Host "[*] Descargando archivo de configuración desde: $url" -ForegroundColor $Yellow

    try {
        # Descargar el archivo desde la URL
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "[+] Archivo descargado correctamente a: $destinationPath" -ForegroundColor $Green
    } catch {
        Write-Host "[-] Error al descargar el archivo: $_" -ForegroundColor $Red
        Exit
    }
}

# Ruta del archivo de configuración
$configFilePath = "patch_config.txt"

# URL desde donde descargar el archivo de configuración si no existe localmente
$configFileUrl = "https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/patch-sublime-text/refs/heads/main/patch_config.txt"

# Verificar si el archivo de configuración existe
if (-not (Test-Path -Path $configFilePath)) {
    Write-Host "[-] El archivo de configuración no existe localmente. Intentando descargarlo..." -ForegroundColor $Red
    
    # Obtener una ruta temporal para guardar el archivo descargado
    $tempConfigFilePath = Join-Path -Path $env:TEMP -ChildPath "patch_config.txt"

    # Llamar a la función para descargar el archivo
    Download-ConfigFile -url $configFileUrl -destinationPath $tempConfigFilePath

    # Actualizar la ruta del archivo de configuración a la descargada
    $configFilePath = $tempConfigFilePath
}

# Leer las líneas del archivo de configuración
$configLines = Get-Content -Path $configFilePath

# Mostrar las últimas 5 versiones disponibles en la base de datos
Write-Host "[>] Últimas 5 versiones disponibles en la base de datos:" -ForegroundColor $Cyan
Write-Host ""  # Espacio en blanco para mayor claridad visual
$versions = @()
foreach ($line in $configLines) {
    if ($line -match "Version:\s+Sublime Text 4 (\d+)") {
        $versions += $matches[1]
    }
}

# Mostrar las últimas 5 versiones (si hay suficientes)
$latestVersions = $versions | Select-Object -Last 5
foreach ($version in $latestVersions) {
    Write-Host "  - Versión $version" -ForegroundColor $White
}

Write-Host ""  # Espacio en blanco para mayor claridad visual

# Solicitar al usuario que ingrese la versión de Sublime Text
$installedVersion = Read-Host "Por favor ingrese la versión de Sublime Text (por ejemplo, 4192)"

# Validar la versión ingresada (solo números)
if ($installedVersion -notmatch '^\d+$') {
    Write-Host "[-] Versión no válida. Asegúrese de ingresar un número válido." -ForegroundColor $Red
    Exit
}

# Variable para verificar si encontramos el parche
$patchFound = $false

# Buscar la línea de configuración para la versión ingresada
foreach ($line in $configLines) {
    if ($line -match "Version:\s+Sublime Text 4 (\d+)\s+FindBytes:\s+(.+?)\s+ReplaceBytes:\s+(.+)$") {
        $versionInConfig = $matches[1]
        $findBytes = $matches[2]
        $replaceBytes = $matches[3]

        # Si encontramos la versión correcta, asignamos los valores de bytes
        if ($versionInConfig -eq $installedVersion) {
            $patchFound = $true
            Write-Host ""  # Espacio en blanco para mayor claridad visual
            Write-Host "[+] Parche encontrado para la versión $installedVersion" -ForegroundColor $Green
            Write-Host "FindBytes: $findBytes"
            Write-Host "ReplaceBytes: $replaceBytes"
            break
        }
    }
}

# Si no encontramos el parche, salimos
if (-not $patchFound) {
    Write-Host ""  # Espacio en blanco para mayor claridad visual
    Write-Host "[-] No se encontró el parche para la versión $installedVersion" -ForegroundColor $Red
    Exit
}

# Opción de modificar el archivo hosts
Write-Host ""  # Espacio en blanco para mayor claridad visual
$modifyHosts = Read-Host "¿Deseas modificar el archivo hosts para bloquear las licencias de Sublime Text?`n" `
                "Este proceso puede fallar si no tienes los permisos adecuados para modificar el archivo hosts.`n" `
                "Actualmente no es necesario bloquear el host. (S/N)"

# Establecer "n" como valor predeterminado
if ($modifyHosts -eq '') {
    $modifyHosts = 'n'
}

if ($modifyHosts -eq 'S' -or $modifyHosts -eq 's') {
    Write-Host "[*] Modificando archivo hosts..." -ForegroundColor $Yellow
    
    $hostsFile = "C:\Windows\System32\drivers\etc\hosts"

    # Verificamos si el archivo hosts existe
    if (Test-Path -Path $hostsFile) {
        # Intentar dar permisos de escritura al archivo hosts
        try {
            Write-Host "[*] Intentando cambiar permisos del archivo hosts..." -ForegroundColor $Yellow
            $acl = Get-Acl $hostsFile
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "Write", "Allow")
            $acl.AddAccessRule($accessRule)
            Set-Acl -Path $hostsFile -AclObject $acl
            Write-Host "[+] Permisos cambiados para permitir escritura." -ForegroundColor $Green
        } catch {
            Write-Host "[-] No se pudieron cambiar los permisos del archivo hosts." -ForegroundColor $Red
        }

        $existingHosts = Get-Content -Path $hostsFile

        # Entradas que queremos agregar al archivo hosts
        $entries = @(
            "# Sublime Text Blocker Key Verificator",
            "127.0.0.1 license.sublimehq.com",
            "127.0.0.1 45.55.255.55",
            "127.0.0.1 45.55.41.223"
        )

        # Asegurarnos de que las entradas no estén ya en el archivo
        foreach ($entry in $entries) {
            if ($existingHosts -notcontains $entry) {
                Add-Content -Path $hostsFile -Value $entry
                Write-Host "[+] Entrada agregada: $entry" -ForegroundColor $Green
            }
        }
    } else {
        Write-Host "[-] El archivo hosts no se encuentra en la ubicación esperada." -ForegroundColor $Red
    }
}

# Espacio visual para separar la parte de modificación de archivos
Write-Host "" 

# Obtener la ruta de Sublime Text (ajusta si es necesario)
$filePath = "C:\Program Files\Sublime Text\sublime_text.exe"

# Función para calcular el hash de un archivo
function Get-FileHashValue {
    param (
        [string]$filePath
    )
    $hash = Get-FileHash -Path $filePath -Algorithm SHA256
    return $hash.Hash
}

# Verificar el hash antes del parche
Write-Host "[*] Calculando el hash del archivo original..." -ForegroundColor $Yellow
$originalHash = Get-FileHashValue -filePath $filePath
Write-Host "[>] Hash original: $originalHash" -ForegroundColor $Cyan

# Confirmar si el archivo está en uso
Write-Host "[*] Esperando que el archivo sublime_text.exe no esté en uso..." -ForegroundColor $Yellow
Start-Sleep -Seconds 3

# Intentar modificar el archivo sublime_text.exe
try {
    Write-Host "[*] Leyendo el archivo sublime_text.exe..." -ForegroundColor $Yellow
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)

    Write-Host "[*] Reemplazando bytes en el archivo sublime_text.exe..." -ForegroundColor $Yellow
    $findBytesArray = $findBytes -split ' '
    $replaceBytesArray = $replaceBytes -split ' '


    # Convertimos los bytes en una matriz de bytes
    $findBytesBytes = $findBytesArray | ForEach-Object { [byte]::Parse($_, 'HexNumber') }
    $replaceBytesBytes = $replaceBytesArray | ForEach-Object { [byte]::Parse($_, 'HexNumber') }

    # Buscar y reemplazar bytes
    for ($i = 0; $i -lt $fileBytes.Length - $findBytesBytes.Length + 1; $i++) {
        $match = $true
        for ($j = 0; $j -lt $findBytesBytes.Length; $j++) {
            if ($fileBytes[$i + $j] -ne $findBytesBytes[$j]) {
                $match = $false
                break
            }
        }

        if ($match) {
            # Reemplazar bytes encontrados con los nuevos bytes
            for ($j = 0; $j -lt $replaceBytesBytes.Length; $j++) {
                $fileBytes[$i + $j] = $replaceBytesBytes[$j]
            }
            break
        }
    }

    Write-Host "[*] Guardando el archivo modificado..." -ForegroundColor $Yellow
    [System.IO.File]::WriteAllBytes($filePath, $fileBytes)
    Write-Host "[+] Proceso completado exitosamente." -ForegroundColor $Green
} catch {
    Write-Host "[-] Hubo un error al modificar el archivo: $_" -ForegroundColor $Red
}

# Verificar si el parche fue exitoso comparando el hash después del parche
Write-Host "[*] Calculando el hash del archivo modificado..." -ForegroundColor $Yellow
$modifiedHash = Get-FileHashValue -filePath $filePath
Write-Host "[>] Hash modificado: $modifiedHash" -ForegroundColor $Cyan

# Comparar los hashes
if ($originalHash -eq $modifiedHash) {
    Write-Host "[-] El parche NO fue exitoso. El archivo no ha cambiado." -ForegroundColor $Red
} else {
    Write-Host "[+] El parche fue exitoso. El archivo ha sido modificado." -ForegroundColor $Green
}

Write-Host "[*] Restaurando política de ejecución a 'Restricted'..." -ForegroundColor $Yellow
Set-ExecutionPolicy Restricted -Force
Write-Host "[+] Política de ejecución actual: $(Get-ExecutionPolicy)" -ForegroundColor $Green

# Evitar que la ventana de PowerShell se cierre automáticamente
Write-Host "[*] La ventana no se cerrará automáticamente. Puedes cerrarla manualmente." -ForegroundColor $Yellow
Write-Host ""  # Espacio en blanco para mayor claridad visual
