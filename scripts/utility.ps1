function Format-Xml {
    <#
    .SYNOPSIS
    Format the incoming object as the text of an XML document.
    #>
    param(
        ## Text of an XML document.
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Text
    )
    
    begin {
        $data = New-Object System.Collections.ArrayList
    }
    process {
        [void] $data.Add($Text -join "`n")
    }
    end {

        $doc = New-Object System.Xml.XmlDocument
        $doc.LoadXml($data -join "`n")
        
        $memStream = New-Object System.IO.MemoryStream
        $writer = New-Object System.Xml.XmlTextWriter($memStream, [System.Text.Encoding]::UTF8)
        $writer.Formatting = [System.Xml.Formatting]::Indented
        $doc.WriteContentTo($writer)
        $writer.Flush()
        $memStream.Flush()

        $memStream.Position = 0
        $sReader = New-Object System.IO.StreamReader($memStream)

        return $sReader.ReadToEnd()
    }
}