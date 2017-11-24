Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1") MyRequest.Open "GET", _ "https://fantasy.premierleague.com/drf/bootstrap-static"
' Send Request. MyRequest.Send
'And we get this response Dim JSON As Object Set JSON = JsonConverter.ParseJson(MyRequest.ResponseText) Dim a As String
a = CStr(JSON(elements)(0)(web_name))
