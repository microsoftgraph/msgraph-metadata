# TypeSpec annotations additions

This TypeSpec project allows you to define additional annotations to inject in the CSDL files. It's an alternative to the XLST in `/transform`.
The copy scripts (in `/scripts/copy-annotations-to-csdl.ps1`) ONLY considers annotations, and DOES NOT perform any deduplication other than the ones enforced by XML keys.

## Requirements

- Node 22.x or above
- TypeScript `npm i -g typescript`
- TypeSpec compiler `npm i -g @typespec/compiler`
- dependencies installed `npm ci`
- vscode (or equivalent) `sudo winget install Microsoft.VisualStudioCode`

## Getting started

1. Make changes to the TypeSpec (.tsp) file
1. Run the compilation `tsp compile . --watch`
1. Run the copy scripts `.\scripts\copy-annotations-to-csdl.ps1 -sourceCsdlDirectoryPath $pwd\additions\tsp-output -targetCsdlPath $pwd\clean_v10_metadata\cleanMetadataWithDescriptionsAndAnnotationsAndErrorsv1.0.xml`
1. Diff the changes to ensure this is what you expect

> Note: Do not commit any changes to the target CSDL as those are generated weekly.
