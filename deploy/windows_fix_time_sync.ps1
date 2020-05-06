# Run this in Windows PowerShell if you get errors from AWS about timestamps
# being too far apart. The root cause of this is that Docker provides a time
# to its containers that is not automatically synchronized with the host's
# system time, and the time can drift if you machine is put in sleep mode.
#
# See https://thorsten-hans.com/docker-on-windows-fix-time-synchronization-issue
# fix-docker-machine-time-sync.ps1
$vm = Get-VM -Name DockerDesktopVM
$feature = "Time Synchronization"

Disable-VMIntegrationService -vm $vm -Name $feature
Enable-VMIntegrationService -vm $vm -Name $feature
