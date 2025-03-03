@echo off

CD "C:\Program Files\OpenVPN\easy-rsa"

:enter_number
    ECHO "Certificate Generator:"
    ECHO "1.Generate Certificate"
    ECHO "2.Generate Certificate (no password)"
    ECHO "3.Revoke Certificate"
    SET /P NUMBER="Enter Number: "
   
	IF %NUMBER%==1 (
        SETLOCAL ENABLEDELAYEDEXPANSION
        ECHO "Certificates list: "
        DIR "D:\OpenVPN\for users\sertificates"
        SET /P CLIENT_NAME="Enter Client Name: "
        CALL :generate_certificate !CLIENT_NAME!
        CALL :sign_request !CLIENT_NAME!
        CALL :copy_certificate_files !CLIENT_NAME!
        SET /P EXIT="Click Enter to exit: "
        EXIT
    )

    IF %NUMBER%==2 (
        SETLOCAL ENABLEDELAYEDEXPANSION
        ECHO "Certificates list: "
        DIR "D:\OpenVPN\for users\sertificates"
        SET /P CLIENT_NAME="Enter Client Name: "
        CALL :generate_certificate_no_password !CLIENT_NAME!
        CALL :sign_request !CLIENT_NAME!
        CALL :copy_certificate_files !CLIENT_NAME!
        SET /P EXIT="Click Enter to exit: "
        EXIT
    )

    IF %NUMBER%==3 (
        SETLOCAL ENABLEDELAYEDEXPANSION
        ECHO "Certificates list: "
        DIR "D:\OpenVPN\for users\sertificates"
        SET /P CLIENT_NAME="Enter Client Name: "
        CALL :revoke_certificate !CLIENT_NAME!
        CALL :delete_certificate_files !CLIENT_NAME!
        SET /P EXIT="Click Enter to exit: "
        EXIT
    )

    ECHO "Enter Number: 1-3!"
    GOTO :enter_number

:generate_certificate
	IF "%1"=="" (
        GOTO :enter_number
    )
    FOR /F "tokens=2*" %%a IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\OpenVPN" /ve') DO set "PATH=%PATH%;%%b\bin"
    ECHO "COPY THIS STRING AND ENTER TO REQUEST: ./easyrsa gen-req %1"
    ECHO "ENTER EXIT AFTER WORK WITH EASYRSA"
    bin\sh.exe "bin\easyrsa-shell-init.sh"
    GOTO :EOF

:generate_certificate_no_password
    IF "%1"=="" (
        GOTO :enter_number
    )
    FOR /F "tokens=2*" %%a IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\OpenVPN" /ve') DO set "PATH=%PATH%;%%b\bin"
    ECHO "COPY THIS STRING AND ENTER TO REQUEST: ./easyrsa gen-req %1 nopass"
    ECHO "ENTER EXIT AFTER WORK WITH EASYRSA"
    bin\sh.exe "bin\easyrsa-shell-init.sh"
    GOTO :EOF

:sign_request
    FOR /F "tokens=2*" %%a IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\OpenVPN" /ve') DO set "PATH=%PATH%;%%b\bin"
    ECHO "COPY THIS STRING AND ENTER TO REQUEST: ./easyrsa sign-req client %1"
    ECHO "ENTER EXIT AFTER WORK WITH EASYRSA"
    bin\sh.exe "bin\easyrsa-shell-init.sh"
    GOTO :EOF

:revoke_certificate
    IF "%1"=="" (
        GOTO :enter_number
    )
    FOR /F "tokens=2*" %%a IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\OpenVPN" /ve') DO set "PATH=%PATH%;%%b\bin"
    ECHO "COPY THIS STRING AND ENTER TO REQUEST: ./easyrsa revoke %1"
    ECHO "ENTER EXIT AFTER WORK WITH EASYRSA"
    bin\sh.exe "bin\easyrsa-shell-init.sh"
    GOTO :EOF

:copy_certificate_files
    MKDIR "D:\OpenVPN\for users\sertificates\%1"
    COPY "D:\OpenVPN\for users\config\client_netoffice.ovpn" "D:\OpenVPN\for users\sertificates\%1"
    COPY "D:\OpenVPN\for users\config\ca.crt" "D:\OpenVPN\for users\sertificates\%1"
    COPY "D:\OpenVPN\for users\config\ta.key" "D:\OpenVPN\for users\sertificates\%1"
    COPY "D:\OpenVPN\for users\config\dh.pem" "D:\OpenVPN\for users\sertificates\%1"
    COPY "C:\Program Files\OpenVPN\easy-rsa\pki\issued\%1.crt" "D:\OpenVPN\for users\sertificates\%1"
    COPY "C:\Program Files\OpenVPN\easy-rsa\pki\private\%1.key" "D:\OpenVPN\for users\sertificates\%1"
    ECHO cert %1.crt >> "D:\OpenVPN\for users\sertificates\%1\client_netoffice.ovpn"
    ECHO key %1.key >> "D:\OpenVPN\for users\sertificates\%1\client_netoffice.ovpn"
    GOTO :EOF

:delete_certificate_files
    ECHO "Delete certificate files?"
    SET /P YESNO="enter 'yes' if want delete files: "

    IF "%YESNO%"=="yes" (
        RD /S /Q "D:\OpenVPN\for users\sertificates\%1"
    ) ELSE (
        ECHO "Certificate files not delete."
    )
    GOTO :EOF