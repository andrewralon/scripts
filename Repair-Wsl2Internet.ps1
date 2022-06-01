# Repair-Wsl2Internet.ps1
# Purpose:  Fix outbound internet DNS lookups through WSL2 Linux Subsystem.
# Requires: PowerShell, WSL2, Linux (Ubuntu or other)
# Usage:    .\Repair-Wsl2Internet.ps1
# Source:   https://gist.github.com/andrewvc/fe22397c554ac3e6255681bfc864e62e

# NOTE: Manually add these lines to /etc/wsl.conf so changes don't revert
# [network]
# generateResolvConf = false

Write-Host " * Disable IPv6"
bash -c "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1"
bash -c "sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1"

Write-Host " * Get Guest IP"
$guest_ip = bash -c "/sbin/ifconfig eth0 | egrep -o 'inet [0-9\.]+' | cut -d ' ' -f2"
Write-Host "Guest IP:  $guest_ip"

Write-Host " * Get Gateway IP"
$gateway_ips = Get-NetIPAddress -InterfaceAlias "vEthernet (WSL)" | Select-Object IPAddress
$gateway_ip = $gateway_ips[1].IPAddress
Write-Host "Gateway (local WSL adapter) IP: $gateway_ip"

Write-Host " * Fix broken internet in WSL2"
bash -c "sudo ifconfig eth0 netmask 255.255.240.0"
bash -c "sudo ip route add default via $gateway_ip"

Write-Host " * Copy Gateway IP to bottom of /etc/resolv.conf"
bash -c "sudo echo 'nameserver $gateway_ip' >> /etc/resolv.conf"

Write-Host " * Run 'Enable-PSRemoting -SkipNetworkProfileCheck -Force'"
Enable-PSRemoting -SkipNetworkProfileCheck -Force

Write-Host " * Done"
