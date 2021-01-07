using Microsoft.OData.Edm.Csdl;
using System.Xml;
using System;

try
{
    CsdlReader.Parse(XmlReader.Create(args[0]));
}
catch(Exception e)
{
    Console.Error.WriteLine(e.Message);
    Environment.Exit(-1);
}
