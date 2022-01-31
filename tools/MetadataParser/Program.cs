// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.OData.Edm.Csdl;
using System.Xml;
using System;
using Microsoft.OData.Edm;
using Microsoft.OpenApi.OData;
using Microsoft.OpenApi.Models;

IEdmModel edmModel;
try
{
    using var reader = XmlReader.Create(args[0]);
    edmModel = CsdlReader.Parse(reader);
    Console.WriteLine("Parsing the metadata as an edm model was successful!");

    var settings = new OpenApiConvertSettings()
    {
        EnableKeyAsSegment = true,
        EnableOperationId = true,
        PrefixEntityTypeNameBeforeKey = true,
        TagDepth = 2,
        EnablePagination = true,
        EnableDiscriminatorValue = false,
        EnableDerivedTypesReferencesForRequestBody = false,
        EnableDerivedTypesReferencesForResponses = false,
        ShowRootPath = true,
        ShowLinks = true
    };

    OpenApiDocument document = edmModel.ConvertToOpenApi(settings);

    Console.WriteLine("Conversion to OpenAPI was successful!");
}
catch (Exception e)
{
    Console.Error.WriteLine(e.Message);
    Environment.Exit(-1);
}
