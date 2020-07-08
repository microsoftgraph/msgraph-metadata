# Graph metadata transform for Microsoft Graph tooling

This transform is used to make changes to the Microsoft Graph CSDL before it is consumed by tools. The transformed metadata is used by tools such as OData2OpenApi and Typewriter. This transform is used for the following non-exclusive reasons: 

* Metadata can't describe the API. This is particularly relevant to APIs that existed before Microsoft Graph, and weren't designed as OData APIs.
* Temporary mitigation for incorrect metadata. There should be tracking work items for this scenario and API owners must be notified.
* Mitigation for missing features or bugs in the tooling. There should be tracking work items for this scenario.

Please use fully qualified and precise template match statements so as not to perform unintended transforms. The CSDL is huge so there is a lot of potential for unintended transformations.

## Instructions for updating and validating transform

1. Clone this repo.
2. Open Visual Studio without a project.
3. Open all of the *preprocess* files under transforms\csdl.
4. Make the transform change in *preprocess_csdl.xsl*.
5. Add corresponding test input to *preprocess_csdl_test_input.xml*.
6. Give the *preprocess_csdl_test_input.xml* file focus.
7. From the top menu in Visual Studio, select XML > Start XSLT Without Debugging or Alt + F5. This will result in a file named *preprocess_csdl_test_input.xml* which will be created in your %AppData%. See [command line instructions](#command-line-instructions-for-running-the-transform) if you prefer command line.
8. Inspect the transformed file output named *preprocess_csdl_test_input.xml* for the expected changes.
9.  Perform a simple text diff of the output *preprocess_csdl_test_input.xml* with the *preprocess_csdl_test_output.xml* file and check for unexpected changes.
10. Add the expected output to *preprocess_csdl_test_output.xml*.
11. Check in changes and open your pull request.

## Command line instructions for running the transform
1. Start PowerShell
2. `cd` into `transforms\csdl` folder
3. Run `transform.ps1 <xsl_file> <input_file> <output_file>`. If files are not specified, the script will apply transformations from  *preprocess_csdl.xsl* on  *preprocess_csdl_test_input.xml* and override *preprocess_csdl_test_output.xml* file.

## Instructions for running transform against Microsoft Graph metadata

1. Clone this repo.
2. Open Visual Studio without a project.
3. Open a metadata file from your local repo: `beta_metadata.xml` or `v1.0_metadata.xml`.
4. Add `<?xml-stylesheet type='text/xsl' href='.\transforms\csdl\preprocess_csdl.xsl'?>` under the first XML declaration in the metadata file.
5. From the top menu in Visual Studio, select XML > Start XSLT Without Debugging or Alt + F5. This will result in a transformed metadata file which will be created in your %AppData%. It will be opened in Visual Studio.
6. Inspect the transformed file output file for the expected changes.