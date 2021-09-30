#Persistent


; Full path to MSIAfterburner.exe:
AFTERBURNER = C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe

; Full path to ethminer.exe:
ETHMINER = C:\SafeZone\ethminer\ethminer.exe

; CLI command arguments for ethminer.exe:
ETHMINER_CLI = --HWMON 2 --tstart 54 --tstop 69 --display-interval 4 -P stratum+ssl://0xCDD0A9019aB0D33C2775d2AA352b395f6e1eAB9F@eu1.ethermine.org:5555

; Afterburner profile to use while mining:
PROFILE_MINING = 4

; Afterburner profile to be reset after quitting / pausing mining:
PROFILE_RESET = 1


dir_array := StrSplit(ETHMINER, "\")
ETHMINER_EXE := dir_array[dir_array.MaxIndex()]
Run "%AFTERBURNER%" -Profile%PROFILE_MINING%
Run "%ETHMINER%" %ETHMINER_CLI%
WinWait, %ETHMINER%, , 5
Process, WaitClose, %ETHMINER_EXE%
Run "%AFTERBURNER%" -Profile%PROFILE_RESET%
ExitApp
return


; Keybind (P) to pause and resume ethminer
#If WinActive(ETHMINER)
p::
    if (toggle := !toggle) {
        Run "%AFTERBURNER%" -Profile%PROFILE_RESET%
        Process_Suspend(ETHMINER_EXE)
        Process_Suspend(PID_or_Name){
            PID := (InStr(PID_or_Name,".")) ? ProcExist(PID_or_Name) : PID_or_Name
            h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
            If !h
                Return -1
            DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
            DllCall("CloseHandle", "Int", h)
        }
    } else {
        Run "%AFTERBURNER%" -Profile%PROFILE_MINING%
        Process_Resume(ETHMINER_EXE)
        Process_Resume(PID_or_Name){
            PID := (InStr(PID_or_Name,".")) ? ProcExist(PID_or_Name) : PID_or_Name
            h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
            If !h
                Return -1
            DllCall("ntdll.dll\NtResumeProcess", "Int", h)
            DllCall("CloseHandle", "Int", h)
        }
        ProcExist(PID_or_Name=""){
            Process, Exist, % (PID_or_Name="") ? DllCall("GetCurrentProcessID") : PID_or_Name
            Return Errorlevel
        }
    }
return
