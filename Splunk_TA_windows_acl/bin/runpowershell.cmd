@ECHO OFF

:: ######################################################
:: #
:: # Splunk for Microsoft Windows
:: # 
:: # Copyright (C) 2019 Splunk, Inc.
:: # All Rights Reserved
:: #
:: ######################################################

set SplunkApp=Splunk_TA_windows_acl

%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -executionPolicy RemoteSigned -command ". '%SPLUNK_HOME%\etc\apps\%SplunkApp%\bin\powershell\%1'"
