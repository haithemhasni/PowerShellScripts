Param (
        [parameter(Mandatory=$true)][string]$WebAppUrl,         
        [parameter(Mandatory=$true)][string]$MimeType
      )

Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue
Start-SPAssignment -Global

try
{
	$webApp = Get-SPWebApplication($WebAppUrl)
	$existingMimeTypes = $webApp.AllowedInlineDownloadedMimeTypes
	$mimeTypeExist = $false
	ForEach($mimeTypeItem in $existingMimeTypes)
	{
		if ($mimeTypeItem -eq $MimeType)
		{
			$mimeTypeExist = $true
		}		
	}
	
	if ($mimeTypeExist -eq $true)
	{
		write-host -f green "Mime type already exists. No need to re added"
	}
	else
	{
		$webApp.AllowedInlineDownloadedMimeTypes.Add($MimeType)
		$webApp.Update()
		write-host -f green "Mime type added"
		
		write-host "List of all allowed MIME types "
		ForEach($mimeTypeItem in $existingMimeTypes)
		{
			write-host $mimeTypeItem
		}
	}
}
catch [System.SystemException]
{ 
	write-host -f Red "The script has stopped because there has been an error.  "$_
}