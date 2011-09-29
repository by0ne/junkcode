'Barabas pure vbs downloader - tested on XP sp2
'Microsoft fixed adodbstream but guess what <img src="http://s.wordpress.com/wpincludes/
images/smilies/icon_smile.gif" alt=":)" class="wp-smiley">
'(c)dec 2004
'First argument = complete url to download
'Second Argument = filename you want to save
'thnks to http://www.ericphelps.com/scripting/samples/BinaryDownload/
'
'v2 - now includes proxy support for the winhttp request stuff
strUrl = WScript.Arguments.Item(0)
StrFile = WScript.Arguments.Item(1)
'WinHttpRequest proxy settings.
Const HTTPREQUEST_PROXYSETTING_
DEFAULT = 0
Const HTTPREQUEST_PROXYSETTING_PRECONFIG = 0
Const HTTPREQUEST_PROXYSETTING_DIRECT = 1
Const HTTPREQUEST_PROXYSETTING_PROXY = 2
Dim http, varByteArray, strData, strBuffer, lngCounter, fs, ts
Err.Clear
Set http = Nothing
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
If http Is Nothing Then Set http =
CreateObject("WinHttp.WinHttpRequest")
If http Is Nothing Then Set http =
CreateObject("MSXML2.ServerXMLHTTP")
If http Is Nothing Then Set http = CreateObject("Microsoft.XMLHTTP")
' comment out next line if no proxy is being used
' and change the proxy to suit ur needs -duh
http.SetProxy HTTPREQUEST_PROXYSETTING_PROXY, "web-proxy:80"
http.Open "GET", strURL, False
http.Send
varByteArray = http.ResponseBody
Set http = Nothing
Set fs = CreateObject("Scripting.FileSystemObject")
Set ts = fs.CreateTextFile(StrFile, True)
strData = ""
strBuffer = ""
For lngCounter = 0 to UBound(varByteArray)
ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1)))
Next
ts.Close