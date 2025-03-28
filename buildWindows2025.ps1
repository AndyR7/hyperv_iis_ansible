Clear-Host
$vmNames = @(
 "iis-front",
 "iis-back",
 "iis-batch"   
)

$isoPath = "C:\IT\ISO\windows2025-unattended.iso"
$baseVhdPath = "D:\Hyper-V"
$memory = 4GB
$vhdSize = 60GB
$switchName = "Default Switch"

# === FUNCTION: Create VMs in Hyper-V ===
function Build-VMS {
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

# === FUNCTION: Mount and Ready ISO to VMs ===
function Mount-UnattendIsoToVMs {
    param (
        [string[]]$vmNames,
        [string]$isoPath
    )

    foreach ($vm in $vmNames) {
        try {
            Write-Host "`nAttaching ISO to $vm..." -ForegroundColor Cyan
            Add-VMDvdDrive -VMName $vm -Path $isoPath -ErrorAction Stop

            # Set DVD as first boot device
            $dvdDrive = Get-VM -Name $vm | Get-VMDvdDrive
            Set-VMFirmware -VMName $vm -FirstBootDevice $dvdDrive

        } catch {
            Write-Host "`n❌ Failed to mount ISO to $vm $_" -ForegroundColor Red
        }
    }

    Write-Host "`n✅ ISO mounted and boot priority set on all VMs." -ForegroundColor Green
}

# === FUNCTION: Start 'em All ===
function Start-VMS {
    foreach ($vmName in $vmNames) {
        # Step 1: Start the VM
        Start-VM -Name $vmName
        Write-Host "🚀 VM '$vmName' started. Switch to the VM window and complete setup." -ForegroundColor Cyan
    }
}

# === MAIN EXECUTION ===
Build-VMS
Mount-UnattendIsoToVMs -vmNames $vmNames -isoPath $isoPath
Start-VMS