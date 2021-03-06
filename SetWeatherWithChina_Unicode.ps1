if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null) {
     Add-PSSnapin Microsoft.SharePoint.PowerShell;
}
$webURL="http://www.mysblink.com/sites/weather/";
$weatherListName="Weather";
$locationArrary=
    @{ 
        CountryCode="Hong Kong";#101320101=香港
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101320101";
    },
    @{ 
        CountryCode="Guangdong";#101280101=广州
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101280101";
    },
    @{
        CountryCode="Hangzhou";#//101210101=杭州
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101210101";
    },
    @{
        CountryCode="Hefei";#//101220101=合肥
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101220101";
    },
    @{
        CountryCode="Nanjing";#//101190101=南京
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101190101";
    },
    @{
        CountryCode="Xiamen";#101230201=厦门
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101230201";
    },
    @{
        CountryCode="Xian";#101110101=西安
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101110101";
    },
    @{
        CountryCode="Zhengzhou";#101180101=郑州
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101180101";
    },
    @{
        CountryCode="Hainan";#101310101=海口
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101310101";
    },
    @{
        CountryCode="Yunnan";#101290101=昆明
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101290101";
    },
    @{
        CountryCode="Shanghai";#101020100=上海
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101310101";
    },
    @{
        CountryCode="Zhanjiang";#110.30 21.20 101281001=湛江
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101281001";
    },
    @{
        CountryCode="Jiangxi";#101240101=南昌 
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101240101";
    },
    @{
        CountryCode="Guangxi";#101300101=南宁
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101300101";
    },
    @{
        CountryCode="Hubei";#101200101=武汉
        CountryURL="http://wthrcdn.etouch.cn/weather_mini?citykey=101200101";
    };

function GetTemperature{
    [CmdletBinding()]
    Param(        
        [string] $tempString
    )
    #high: "高温 17℃"
  
    $temp=0;
    IF([string]::IsNullOrEmpty($tempString)) {  
          Write-Host "$tempString is empty"
    }else{
        $tempArray=$tempString.Split(" ");
        IF($tempArray.Length -gt 1){
            $tempe=$tempArray[1];
            $temp=$tempe.Substring(0,$tempe.Length-1)
        }
    }   
Write-Host "temperature: "$tempString" return temp:"$temp
    return  $temp 
}
function GetDayofWeekW{
     [CmdletBinding()]
    Param(        
        [string] $dateT
    )
    Write-Host "date:"$dateT;
    $dayArray=$dateT.Split("日");
   Write-Host "dayArray length:"$dayArray.Length
    $dayofWeekWea="";
    if($dayArray.Length -gt 1){
        $dayofWeekCN=$dayArray[1];  
        switch($dayofWeekCN.Trim())
            {
                "星期一" {$dayofWeekWea="Monday";break}
                "星期二" {$dayofWeekWea="Tuesday";break}
                "星期三" {$dayofWeekWea="Wednesday";break}
                "星期四" {$dayofWeekWea="Thursday";break}
                "星期五" {$dayofWeekWea="Friday"; break}
                "星期六" {$dayofWeekWea="Saturday";break}
                "星期天" {$dayofWeekWea="Sunday";break}
                Default {$dayofWeekWea="Sunday";break}
            }
    }
    Write-Host "dayofWeekWea:"$dayofWeekWea;
    return $dayofWeekWea;
}
function GetIcon{
    [CmdletBinding()]
    Param(
        [string] $iconType
    )
    $weatherType="";
 Write-Host "iconType:"$iconType;
    switch($iconType)
    {
        "晴"{$weatherType="sunny";break}
        "多云"{$weatherType="cloudy";break}
        "晴间多云"{$weatherType="partlycloudy"; break}
        "大部多云" {$weatherType="mostlycloudy";break}   
        "阴" {$weatherType="cloudy";break}
        "阵雨"{$weatherType="chancerain";break}                         
        "雷阵雨"{$weatherType="chancerain"; break}      
        "雷阵雨伴有冰雹"{$weatherType="chancerain"; break}
        "小雨" {  $weatherType="rain"; break}  
        "小到中雨"{$weatherType="rain"; break}                  
        "中雨"{  $weatherType="rain"; break}      
        "大雨"{  $weatherType="rain"; break}
        "暴雨" {$weatherType="tstorms";break}
        "大暴雨"{$weatherType="tstorms";break}
        "特大暴雨" {$weatherType="tstorms";break}                           
        "冰雨" {$weatherType="tstorms";break}
        "雨夹雪"{ $weatherType="sleet";break}
        "阵雪"{ $weatherType="snow";break}
        "小雪"{ $weatherType="snow";break}
        "中雪" { $weatherType="snow";break}                          
        "大雪" { $weatherType="snow";break} 
        "暴雪"{  $weatherType="snow"; break}
        "雾" {$weatherType="fog";break}
        "雾霾"{$weatherType="fog";break}
        Default {$weatherType="clear";break}
    }
Write-Host "iconType"$iconType" return weatherType" +$weatherType;
    return $weatherType;
}
function GetCurrentRegionForecast 
{
    [CmdletBinding()]
    Param(
        [string]$url,
        #脚本命令行参数绑定例子 powershell传教士 制作 分享
        [string]$countryCode 
    )
    #$web_client = new-object system.net.webclient;
    #$dataString=$web_client.DownloadString($url)
    #$build_infoJsonObj =ConvertFrom-Json –InputObject $dataString
    # simpleforecast forecastday has 10 array object
    #$url = "http://wthrcdn.etouch.cn/weather_mini?citykey=101200101"
    $webRequest = [System.Net.HttpWebRequest]::Create($url)
    $webRequest.Method = "GET"
    $webRequest.UserAgent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"
    $webRequest.Timeout=30000
    $webRequest.Headers.Add("Accept-Encoding","gzip,deflate")
    #$encoding = New-Object -TypeName System.Text.UTF8Encoding
    $response = $webRequest.GetResponse()
    $stream = $response.GetResponseStream()
    $gzipstream = New-Object System.IO.Compression.GZipStream($stream, [System.IO.Compression.CompressionMode]::Decompress, $True)
    #$reader = New-Object System.IO.StreamReader($gzipstream,$encoding)
    $reader = New-Object System.IO.StreamReader($gzipstream)
    $str=$reader.ReadToEnd()
    $strJsonObj =ConvertFrom-Json -InputObject  $str
    $forecastdays=$strJsonObj.data.forecast ;
    $forecastdaysArraryList = New-Object -TypeName System.Collections.ArrayList 
    $index=0;
    $tempDayofWeek;
    $tempH;
    $tempL;
    $tempIcon;
    foreach ($forecastday in $forecastdays) { 
        $tempDayofWeek=  GetDayofWeekW -dateT $forecastday.date;
        $tempH=GetTemperature -tempString $forecastday.high; 
        $tempL=GetTemperature -tempString $forecastday.low;  
        $tempIcon=GetIcon -iconType $forecastday.type;            
        $forecastdaysArraryList.add(@{
            Title=$countryCode ;
            Date=$forecastday.date;
            High= $tempH;
            Low= $tempL;
            T= $tempDayofWeek;
            D=$index;
            Icon=$tempIcon;
        })  | Out-Null;    
        $index++;     
    }
    $reader.Close();
    $reader.Dispose();
    $gzipstream.Close();
    $gzipstream.Dispose();
    $stream.Close();
    $stream.Dispose();
   return $forecastdaysArraryList;
}

function UpdateWeatherItems{
    [CmdletBinding()]
    Param(
        [Microsoft.SharePoint.SPList]$list,
        #脚本命令行参数绑定例子 powershell传教士 制作 分享
        [System.Collections.ArrayList]$forecastdaysArraryList ,
        [string] $regionName
    )
   # $regionName="Hong Kong";
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $CAMLQuery= "<Where><Eq><FieldRef Name='Title'/><Value Type='Text'>"+$regionName+"</Value></Eq></Where><OrderBy><FieldRef Name='d' Asceding='FALSE'/></OrderBy>";
    $spQuery.Query=$CAMLQuery;
    $spQuery.RowLimit=5;
    $items=$list.GetItems($spQuery);
    foreach($item in $items){
        $itemTemp=$forecastdaysArraryList | Where-Object {$_.Title -eq $item.Title -and $_.D -eq $item["d"] }
        $item["Date"]=$itemTemp.Date;
        $item["hi"]=$itemTemp.High;
        $item["low"]=$itemTemp.Low;
        $item["t"]=$itemTemp.T;
        $item["icon"]=$itemTemp.Icon;
        $item.update();
        Write-Host $itemTemp.Title + " " +$itemTemp.Date;
    }
} 

function UpdateEachCountry {
    [CmdletBinding()]
    Param(
        [string]$webURL,
        #脚本命令行参数绑定例子 powershell传教士 制作 分享
        [string]$weatherListName 
    )
    #$web= get-SPweb $webURL;
    #write-Host "web title"+ $web.Title
    #$list=$web.Lists.TryGetList($weatherListName)
    #Write-Host "list title"+ $list.Title
    # loop to each country
    foreach($region in $locationArrary){
        # fetch current country weather data
        $countryCode=$region.CountryCode;
        Write-Host "region:" $countryCode
        $forecastdaysArraryList=GetCurrentRegionForecast -url $region.CountryURL -countryCode $region.CountryCode;        
        #UpdateWeatherItems -list $list -forecastdaysArraryList $forecastdaysArraryList -regionName $region.CountryCode
    }
   #$web.Dispose();
    Write-Host "weather updated done!"
}
UpdateEachCountry -webURL $webURL -weatherListName $weatherListName 



