import "@microsoft/typespec-msgraph";

using Http;
@service(#{ title: "Microsoft Graph" })
namespace Microsoft.Graph;

@entity()
model OrgContact {
}