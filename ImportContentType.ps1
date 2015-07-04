Param (
        [parameter(Mandatory=$true)][string]$SiteUrl,
        [parameter(Mandatory=$true)][string]$XmlFilePath
     )

Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue
Start-SPAssignment -Global

$destWeb = Get-SPWeb -Identity $SiteUrl

#Create Site Content Types
$ctsXML = [xml](Get-Content($XmlFilePath))
$ctsXML.ContentTypes.ContentType | ForEach-Object {

    #Create Content Type object inheriting from parent
    $spContentType = New-Object Microsoft.SharePoint.SPContentType ($_.ID,$destWeb.ContentTypes,$_.Name)
    
    #Set Content Type description and group
    $spContentType.Description = $_.Description
    $spContentType.Group = $_.Group
    
    $_.Fields.Field  | ForEach-Object {
        if(!$spContentType.FieldLinks[$_.DisplayName])
        {
            #Create a field link for the Content Type by getting an existing column
            $spFieldLink = New-Object Microsoft.SharePoint.SPFieldLink ($destWeb.Fields[$_.DisplayName])
        
            #Check to see if column should be Optional, Required or Hidden
            if ($_.Required -eq "TRUE") {$spFieldLink.Required = $true}
            if ($_.Hidden -eq "TRUE") {$spFieldLink.Hidden = $true}
        
            #Add column to Content Type
            $spContentType.FieldLinks.Add($spFieldLink)
        }
    }
    
    #Create Content Type on the site and update Content Type object
    $ct = $destWeb.ContentTypes.Add($spContentType)
    $spContentType.Update()
    write-host "Content type" $ct.Name "has been created"
}

$destWeb.Dispose()