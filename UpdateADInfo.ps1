Write-host "|--> List sites"
$sites = Get-SPSite -Limit ALL
Write-host "|--> Sites to process :"
$sites
$userType = "i:0#.w|"; 
$groupType="c:0+.w|";
foreach($site in $sites) {
    $web = $site.RootWeb
    if($web -ne $null) {
		$SiteUrl =  $site.url
		Write-host "============================================================================" -fore Yellow
		Write-host "== Start user synchronization for $SiteUrl ($web)" -fore Yellow
        $list= $web.SiteUserInfoList
        $spQuery = New-Object Microsoft.SharePoint.SPQuery
        $spQuery.ViewXml = "@
        <View Scope='RecursiveAll'>
            <Query>
                <Where>
                <Or>
                    <Contains>
                        <FieldRef Name='Name'/><Value Type='Text'>$userType</Value>
                    </Contains>
                     <Contains>
                        <FieldRef Name='Name'/><Value Type='Text'>$groupType</Value>
                    </Contains>
                </Or>
                </Where>
            </Query>
        </View>"
        $items=$list.GetItems($spQuery);
        foreach ($item  in $items)
            {               
                IF($item["ows_EMail"]) { 
                    $oldEmail=$item["ows_EMail"].Tolower();
                    $newEmail=$oldEmail.Replace("swirebev.com","swirecocacola.com")
                    $item["ows_EMail"]=$newEmail;
                    $item.update();
                }              
            }
    }
}
Write-host "|--> Sites to process done!!"


 