##
## Note 1: this is a PS profile optimized for a portable non-root setup
##       it's very challenging to setup a dev environment on non-root windows 
##       so expect some hacky workarounds
##
## Note 2: Assumes you can & have ran the following commands
##       Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser 
##       Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
##

Import-Module posh-git
Import-Module Terminal-Icons
Import-Module PSFzf

# Set PATH for portable installs
$env:path = "$HOME\portable\VSCode-latest;" + $env:path
$env:path = "$Env:ProgramFiles\Git\bin;" + $env:path
$env:path = "$Env:ProgramFiles\Git\usr\bin;" + $env:path
$env:path = "$HOME\Tooling\node-v22.13.1-win-x64;" + $env:path
$env:path = "$Env:LOCALAPPDATA\Programs\Microsoft VS Code;" + $env:path
$env:path = "$Env:LOCALAPPDATA\Programs\WinSCP;" + $env:path
$env:path = "$HOME\Downloads\npp.8.7.8.portable.x64;" + $env:path


##
### 
# AWS Enviornment variables 
###
##

$Env:AWS_ACCESS_KEY_ID=""
$Env:AWS_SECRET_ACCESS_KEY=""

# Zed related stuff to run in windows
# remote build option
# https://github.com/zed-industries/zed/issues?q=ZED_BUILD_REMOTE_SERVER
# https://github.com/zed-industries/zed/pull/36069
# https://github.com/zed-industries/zed/pull/33391
# ZED_BUILD_REMOTE_SERVER=nomusl, ZED_BUILD_REMOTE_SERVER=cross
$Env:ZED_BUILD_REMOTE_SERVER="cross"


# PsFzf options
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# See https://github.com/PowerShell/PSReadLine
## emulate bash behavior for displaying items on tab
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

####
## TODO: decide whether to use https://github.com/dahlbyk/posh-sshell and/or or https://github.com/JanDeDobbeleer/oh-my-posh
## might want to start from scratch, remove ohmyposh stuff
## Get-InstalledModule -Name posh-sshell | Uninstall-Module
## Get-InstalledModule -Name posh-git | Uninstall-Module
####

## Helpful shortcuts fyi, see `Function env` for more
# ${env:ProgramFiles} = C:\Program Files
# ${env:ProgramFiles(x86)} = C\Program Files (x86)
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

#################
# Windows Alias's
#################

# use notepad++
Set-Alias -Name npp -Value "notepad++.exe"
Set-Alias -Name getps -Value "Get-PSReadlineOption"
Set-Alias -Name ll -Value "ls"
Set-Alias -Name aws -Value "awscliv2"
Set-Alias -Name codep -Value "$HOME\portable\VSCode-win32-x64-1.103.1\bin\code"
# Set-Alias -Name grep -Value "Select-String" -Description "grep/findstr alias"


#################
# Functions
#################

# get all env vars
Function get-env { [System.Environment]::GetEnvironmentVariables() }
Function edit-profile { npp $PROFILE }
# (Get-PSReadlineOption).HistorySavePath
Function hist { cat (getps).HistorySavePath }
# Function grep { $Input | Out-String -Stream | Select-String $args[0] }
Function grep($name) { $Input | Out-String -Stream | Select-String $name }

Function hgrep($searchStr) { cat (getps).HistorySavePath | grep $searchStr }

Function vm {
        $host.ui.RawUI.WindowTitle = "Personal Dev VM (Kube Access)"
        ssh east_vm
}

Function dev {
	$host.ui.RawUI.WindowTitle = "Dev"
	ssh dev-bastion
}

Function stage {
	$host.ui.RawUI.WindowTitle = "Stage"
	ssh stg-bastion
}


Function pp1 {
	$host.ui.RawUI.WindowTitle = "PP1"
	ssh pp1-bastion
}

Function pp2 {
	$host.ui.RawUI.WindowTitle = "PP2"
	ssh pp2-bastion
}


# ssh one-offs
Function getnodes {
	# ssh dev-bastion kubectl get nodes -o wide 
	ssh -t dev-bastion "sudo kubectl get nodes -o wide | tail -n 1 | tr -s ' ' | cut -d ' ' -f 1"
}


Function ssh-forward-bastion {
	$ing=& ssh -t dev-bastion "sudo kubectl get nodes -o wide | tail -n 1 | tr -s ' ' | cut -d ' ' -f 1"
	Start-Process "${env:ProgramFiles}\Git\bin\bash.exe" -NoNewWindow -ArgumentList "./ssh_forward.sh $ing"
}

Function ssh-forward {
  param([string]$ip)
  # ssh forwarding, add -f for background
        ssh -v -N -L 8443:$ip:443 pp1-bastion
}

Function viewports {
	netstat -an | grep "LISTENING"
}

## Powershell Snippets

## Get your current public IP
Function Get-PubIP {
        (Invoke-WebRequest <ins>http://ifconfig.me/ip</ins> ).Content
}

## Get the date and time in UTC**
Function Get-Zulu {
        Get-Date -Format u
}

Function Get-Pass {
        -join(48..57+65..90+97..122|ForEach-Object{[char]$_}|Get-Random -C 20)
}

function uptime {
        Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
        EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function reload-profile {
        & $profile
}

function find-file($name) {
        ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
                $place_path = $_.directory
                echo "${place_path}\${_}"
        }
}

function unzip ($file) {
        $dirname = (Get-Item $file).Basename
        echo("Extracting", $file, "to", $dirname)
        New-Item -Force -ItemType directory -Path $dirname
        expand-archive $file -OutputPath $dirname -ShowProgress
}

### Linux-like Scripts

function grep($regex, $dir) {
        if ( $dir ) {
                ls $dir | select-string $regex
                return
        }
        $input | select-string $regex
}

function touch($file) {
        "" | Out-File $file -Encoding ASCII
}

function df {
        get-volume
}

function sed($file, $find, $replace){
        (Get-Content $file).replace("$find", $replace) | Set-Content $file
}


function which($name) {
        Get-Command $name | Select-Object -ExpandProperty Definition
}


function export($name, $value) {
        set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
        ps $name -ErrorAction SilentlyContinue | kill
}


function pgrep($name) {
        ps $name
}

#################
# Debugging, $args means different things depending on powershell version
#################
## get process of ghost ssh process, TODO: kill it
# powershell Get-Process -Id (Get-NetTCPConnection -LocalPort 8241).OwningProcess


Function repeatme { $Input | Write-Error "$args" } 

Function grep2 { 
        param([string]$pattern)
        $Input | Out-String -Stream | Select-String -Pattern $pattern
}

Function clear-ssh-agent { 
	remove-item env:\SSH_AGENT_PID
	remove-item env:\SSH_AUTH_SOCK
}

Function stop-team-viewer {
        cmd.exe /c "taskkill /t /f /im teamviewer*"
}

Function stop-process {
        param([string]$in)
        Stop-Process -Name "$in"
}
