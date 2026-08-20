$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

Start-Process "http://localhost:8000/"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $path = $context.Request.Url.AbsolutePath.TrimStart('/')

    if ([string]::IsNullOrEmpty($path)) {
        $path = "index.html"
    }

    $file = Join-Path $root $path

    if (Test-Path $file -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($file)

        $extension = [System.IO.Path]::GetExtension($file)

        $types = @{
            ".html" = "text/html"
            ".js"   = "application/javascript"
            ".wasm" = "application/wasm"
            ".swf"  = "application/x-shockwave-flash"
            ".css"  = "text/css"
            ".json" = "application/json"
        }

        if ($types.ContainsKey($extension)) {
            $context.Response.ContentType = $types[$extension]
        }

        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    else {
        $context.Response.StatusCode = 404
    }

    $context.Response.Close()
}
