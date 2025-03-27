cls
$vmNames = @(
 "iis-front",
 "iis-back",
 "iis-batch"   
)

$newUser = "admin"
$newPass = "SecurePa$$123"
$isoPath = "C:\IT\ISO\windows25-unattended.iso"
$baseVhdPath = "D:\Hyper-V"
$memory = 4GB
$vhdSize = 60GB
$switchName = "Internal"

# Create the switch if it doesn't exist
if (-not (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue)) {
    Write-Host "`nCreating virtual switch '$switchName'..." -ForegroundColor Yellow
    New-VMSwitch -SwitchName $switchName -SwitchType Internal
}

function CreateVMS {
    foreach ($vmName in $vmNames) {
        try {
            Write-Host "`nCreating VM: $vmName" -ForegroundColor Cyan

            $vmPath = Join-Path -Path $baseVhdPath -ChildPath $vmName
            $vhdPath = Join-Path -Path $vmPath -ChildPath "$vmName.vhdx"

            # Create folder if not exists
            if (-Not (Test-Path $vmPath)) {
                New-Item -ItemType Directory -Path $vmPath | Out-Null
            }

            # Create the VM
            New-VM -Name $vmName `
                   -MemoryStartupBytes $memory `
                   -Generation 2 `
                   -NewVHDPath $vhdPath `
                   -NewVHDSizeBytes $vhdSize `
                   -SwitchName $switchName

            Write-Host "`nVM '$vmName' created successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "`n❌ Failed to create VM '$vmName': $_" -ForegroundColor Red
        }
    }
}

function Enable-winrm {
    foreach ($vmName in $vmNames) {

        # Step 1: Confirm before starting
        $confirmStart = Read-Host "`nStart VM '$vm' and begin ISO-based setup? (y/n)"
        if ($confirmStart -notmatch '^[Yy]$') {
            Write-Host "⏭️ Skipping $vm..." -ForegroundColor Yellow
            continue
        }

        # Step 2: Start the VM
        Start-VM -Name $vm
        Write-Host "🚀 VM '$vm' started. Switch to the VM window and complete setup." -ForegroundColor Cyan

        # Step 3: Wait for user to finish setup
        Write-Host "`n✅ Press any key once you've completed setup on '$vm'..."
        [void][System.Console]::ReadKey($true)

        
        try {
            Invoke-Command -VMName $vmName -ScriptBlock {
                param($newUser, $newPass)

                $securePass = ConvertTo-SecureString $newPass -AsPlainText -Force
                if (-not (Get-LocalUser -Name $newUser -ErrorAction SilentlyContinue)) {
                    New-LocalUser -Name $newUser -Password $securePass
                    Add-LocalGroupMember -Group "Administrators" -Member $newUser
                }

                Enable-PSRemoting -Force
                Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
                Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
                New-NetFirewallRule -Name "AllowWinRM" -DisplayName "Allow WinRM" `
                    -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow
            } -ArgumentList $newUser, $newPass

            Write-Host "`n✔️ $vmName configured." -ForegroundColor Green
        }
        catch {
            Write-Host "`n❌ Error with VM '$vmName': $_" -ForegroundColor Red
        }
    }
}

# === FUNCTION: Mount ISO to VMs ===
function Mount-UnattendIsoToVMs {
    param (
        [string[]]$vmNames,
        [string]$isoPath
    )

    foreach ($vm in $vmNames) {
        try {
            Write-Host "`nAttaching ISO to $vm..." -ForegroundColor Cyan
            Set-VMDvdDrive -VMName $vm -Path $isoPath -ErrorAction Stop

            # Set DVD as first boot device
            $dvdDrive = Get-VM -Name $vm | Get-VMDvdDrive
            Set-VMFirmware -VMName $vm -FirstBootDevice $dvdDrive

        } catch {
            Write-Host "`n❌ Failed to mount ISO to $vm $_" -ForegroundColor Red
        }
    }

    Write-Host "`n✅ ISO mounted and boot priority set on all VMs." -ForegroundColor Green
}

# === MAIN EXECUTION ===
#CreateVMS
try {
    Mount-UnattendIsoToVMs -vmNames $vmNames -isoPath $isoPath
}
catch {
    Write-Host "`n❌ ISO does not exist or created..." -ForegroundColor Red
    exit
}
Enable-winrm