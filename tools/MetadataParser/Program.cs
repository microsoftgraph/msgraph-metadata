// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.OData.Edm.Csdl;
using System.Xml;
using System;
using Microsoft.OData.Edm;
using Microsoft.OpenApi.OData;
using Microsoft.OpenApi.Models;
using System.Collections.Generic;
using Microsoft.OData.Edm.Validation;

IEdmModel edmModel;
try
{
    if (!CsdlReader.TryParse(XmlReader.Create(args[0]), true, out edmModel, out IEnumerable<EdmError> parseErrors))
    {
        throw new EdmParseException(parseErrors);
    }
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
