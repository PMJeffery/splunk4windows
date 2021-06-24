## Powershell Script to collect Folder and Recursive Directory Size, Last Modified Time and ACL Permissions
## Put Multiple Directories in the splunk_win_acls.tx file
$ErrorActionPreference = 'SilentlyContinue'
## Update the splunk_win_acls_list.txt with the list of directories to get the sub directory and file count,size,acl permissions
$target_folder_list = $PSScriptRoot + '\splunk_win_acls_list.txt'
$curDate = Get-Date
ForEach ($file in (Get-Content $target_folder_list)) {
    dir -Recurse $file | where { $_.PsIsContainer } | % { 
        [datetime]$last_time = $_.LastWriteTime;
        $dataObject = New-Object PSObject
        $dataaclObject = New-Object PSObject
        $data_access = New-Object PSObject
        $path1 = $_.fullname;
        $folder_dir_cnt = (gci –force $_.fullname -Directory | Measure-Object).Count
        $folder_file_cnt = (gci –force $_.fullname -File | Measure-Object).Count
        #gci -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
        #$size= '{0:N2}' -f ($len / 1Kb)
        $size="{0:N4}" -f ((gci –force $_.fullname –Recurse| measure Length -s).sum / 1KB)
        
        $Date = Get-Date -format 'yyyy-MM-ddTHH:mm:sszzz'
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “scan_time” -value $Date
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_last_mod_time” -value $last_time
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_path” -value $path1
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_size” -value $size
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_dir_cnt” -value $folder_dir_cnt
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_file_cnt” -value $folder_file_cnt
        $data = Get-Acl $_.Fullname | % { $_.access}
        $data_access = $data| ForEach-Object {'["IdentityReference":"';$_.IdentityReference;'","FileSystemRights":"';$_.FileSystemRights;'","AccessControlType":"';$_.AccessControlType;'","IsInherited":"';$_.IsInherited;'","InheritanceFlags":"';$_.InheritanceFlags;'","PropagationFlags":"';$_.PropagationFlags;'"]'}
        $data_access_string = $data_access -join ''
        Add-Member -inputObject $dataObject -memberType NoteProperty -name “object_acl” -value $data_access_string
        $dataObject -join ''
    }
}

#ACL - Example Fields
#FileSystemRights  : FullControl
#AccessControlType : Allow
#IdentityReference : NT AUTHORITY\SYSTEM
#IsInherited       : True
#InheritanceFlags  : ContainerInherit, ObjectInherit
#PropagationFlags  : None
exit