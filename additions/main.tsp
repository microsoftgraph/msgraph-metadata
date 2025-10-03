import "@microsoft/typespec-msgraph";

using MsGraph;

@publicNamespace("microsoft.graph")
@container("GraphService")
namespace microsoft.graph {

	@entity()
	model OrgContact extends SharedModels.entity {
		displayName: string | null
	}
	@graphRoute("contacts/{id}")
	interface OrgContactsById extends Resource<OrgContact> {
        @select GetResource is GraphOps.GetResource;
		@select PatchResource is GraphOps.PatchWithResponse;
		@select DeleteResource is GraphOps.Delete;
	}
	@graphRoute("contacts")
	interface OrgContacts extends Collection<OrgContact> {
        @orderBy("displayName") @filter("*") @search @count @select @skip @top GetCollection is GraphOps.GetPagedCollection;
	}
}
