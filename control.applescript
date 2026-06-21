-- Auto-Quit control panel
set stateDir to (POSIX path of (path to home folder)) & "Library/Application Support/auto-quit/"
set excludeFile to stateDir & "excludes.txt"
set enabledFlag to stateDir & "enabled"
set logFile to (POSIX path of (path to home folder)) & "Library/Logs/auto-quit.log"
set plistPath to (POSIX path of (path to home folder)) & "Library/LaunchAgents/com.user.autoquit.plist"

on readStatus(enabledFlag)
	try
		set v to do shell script "cat " & quoted form of enabledFlag
		if v is "0" then return "DISABLED"
	end try
	return "ENABLED"
end readStatus

repeat
	set currentStatus to readStatus(enabledFlag)
	set btns to {"Edit Exclusions", "View Log", "Quit"}
	if currentStatus is "ENABLED" then
		set toggleBtn to "Disable"
	else
		set toggleBtn to "Enable"
	end if
	set btns to {toggleBtn, "Edit Exclusions", "Quit"}

	set msg to "Auto-Quit: " & currentStatus & return & "Idle apps are quit after 10 minutes."
	try
		set choice to button returned of (display dialog msg buttons btns default button toggleBtn with title "Auto-Quit Control")
	on error number -128
		return
	end try

	if choice is "Disable" then
		do shell script "echo 0 > " & quoted form of enabledFlag
	else if choice is "Enable" then
		do shell script "echo 1 > " & quoted form of enabledFlag
	else if choice is "Edit Exclusions" then
		do shell script "open -a TextEdit " & quoted form of excludeFile
	else if choice is "Quit" then
		return
	end if
end repeat
