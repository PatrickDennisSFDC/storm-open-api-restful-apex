/**
 * AF Customer Order Update Action
 * Invocable action for updating CustomerOrders__c records
 * Supports updating order header, adding/updating/deleting line items in one transaction
 * Designed for Agentforce AI agents
 */
public with sharing class AFCustomerOrderUpdateAction {
    
    /**
     * Request input for update operation
     */
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order to update. Can also be resolved by providing Name or Order_Number__c in fieldDataJson if recordId is not known.'
            required=false
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Field Data JSON'
            description='JSON string containing Customer Order fields to update. Example: {"Status__c":"Shipped","Shipping_Method__c":"Overnight"}. Only include fields you want to change. Can include Name or Order_Number__c for automatic record resolution if recordId is not provided.'
            required=false
        )
        public String fieldDataJson;
        
        @InvocableVariable(
            label='Account Name'
            description='Account name to resolve to Account__c lookup. Use this to change the order\'s account. If multiple matches, system will return candidates for clarification.'
            required=false
        )
        public String accountName;
        
        @InvocableVariable(
            label='Contact Name or Email'
            description='Contact name or email to resolve to Contact__c lookup. Use this to change the order\'s contact.'
            required=false
        )
        public String contactNameOrEmail;
        
        @InvocableVariable(
            label='Add Line Items JSON'
            description='JSON array of NEW line items to add to the order. Format: [{"Product_Name__c":"Widget C","Quantity__c":3,"Unit_Price__c":75.00}]. Each line item requires: Product_Name__c, Quantity__c, Unit_Price__c. The system will create these line items and link them to the order.'
            required=false
        )
        public String addLineItemsJson;
        
        @InvocableVariable(
            label='Update Line Items JSON'
            description='JSON array of EXISTING line items to update. Format: [{"Id":"a00xxx...","Quantity__c":50},{"Id":"a00yyy...","Unit_Price__c":125.00}]. Each item must include the line item Id plus the fields to change. Get line item IDs from a previous readCustomerOrder or findCustomerOrders call.'
            required=false
        )
        public String updateLineItemsJson;
        
        @InvocableVariable(
            label='Delete Line Item IDs'
            description='JSON array of line item IDs to delete from the order. Format: ["a00xxx...","a00yyy..."]. Get these IDs from a previous readCustomerOrder call. Example use: User says "remove line item 2" - agent looks up line item 2 ID from previous read and passes it here.'
            required=false
        )
        public String deleteLineItemIds;
        
        @InvocableVariable(
            label='Confirm'
            description='Optional: Set to false to preview only without committing changes. Default (true): Updates the record immediately. Only set to false if user explicitly asks to preview first.'
            required=false
        )
        public Boolean confirm;
    }
    
    /**
     * Response output for update operation
     */
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The updated Customer Order record with the new field values. Use this to show the user what was changed.'
        )
        public CustomerOrders__c record;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order that was updated (18-character format).'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Line Items'
            description='Complete list of ALL line items for the order AFTER the update (includes added, updated, and remaining items). Ordered by creation date. Use this to show the user the current state of line items. Each item has a position (1, 2, 3...) for agent reference.'
        )
        public List<Customer_Order_Line_Item__c> lineItems;
        
        @InvocableVariable(
            label='Line Item Count'
            description='Total number of line items on the order after the update. Use this to inform the user: "Order now has 4 line items" or "Removed 2 items, order now has 3 items".'
        )
        public Integer lineItemCount;
        
        @InvocableVariable(
            label='Line Items Added'
            description='Number of line items that were added in this update operation. Use to inform user: "Added 2 line items".'
        )
        public Integer lineItemsAdded;
        
        @InvocableVariable(
            label='Line Items Updated'
            description='Number of line items that were modified in this update operation. Use to inform user: "Updated 1 line item".'
        )
        public Integer lineItemsUpdated;
        
        @InvocableVariable(
            label='Line Items Deleted'
            description='Number of line items that were removed in this update operation. Use to inform user: "Deleted 3 line items".'
        )
        public Integer lineItemsDeleted;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Examples: "Customer Order updated successfully", "Order updated: status changed to Shipped, 2 line items added".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "CustomerOrders__c" for Customer Order update operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Preview Only'
            description='True if this is a preview response (confirm=false). The record has not been updated yet. The agent should present the preview to the user, then call again with confirm=true to commit the changes.'
        )
        public Boolean previewOnly;
        
        @InvocableVariable(
            label='Preview Data'
            description='A JSON string showing what would be changed. Use this to show the user what changes will be made before committing.'
        )
        public String previewData;
        
        @InvocableVariable(
            label='Available Fields JSON'
            description='JSON string containing metadata for all available fields that can be updated on Customer Order records.'
        )
        public String availableFieldsJson;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Order is linked to an Account.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Order is linked to a Contact.'
        )
        public String relatedContactName;
        
        @InvocableVariable(
            label='Ambiguous Relationship'
            description='True if a related record lookup (Account or Contact) found multiple matches (2+). When true, DO NOT tell the user the Order was updated. Present candidates and ask for clarification.'
        )
        public Boolean ambiguousRelationship;
        
        @InvocableVariable(
            label='Ambiguous Relationship Type'
            description='The type of relationship that has multiple matches: "Account" or "Contact".'
        )
        public String ambiguousRelationshipType;
        
        @InvocableVariable(
            label='Relationship Candidates JSON'
            description='JSON array of candidate records when ambiguousRelationship is true. Present these options to the user with distinguishing details.'
        )
        public String relationshipCandidatesJson;
    }
    
    /**
     * Update Customer Order (header and/or line items)
     */
    @InvocableMethod(
        label='Update Customer Order'
        description='Updates an existing Customer Order record immediately. Can update order header fields (Status, Shipping Method, etc.) AND/OR manage line items (add, update, delete) in the same transaction. Pass Order ID or include Name/Order_Number__c in fieldDataJson for automatic resolution. Use addLineItemsJson to add items, updateLineItemsJson to modify quantities/prices, deleteLineItemIds to remove items. Default behavior updates immediately. Supports name-based resolution.'
        category='CRM Actions'
    )
    public static List<Response> updateCustomerOrder(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'CustomerOrders__c';
            res.success = false;
            res.lineItems = new List<Customer_Order_Line_Item__c>();
            res.lineItemCount = 0;
            res.lineItemsAdded = 0;
            res.lineItemsUpdated = 0;
            res.lineItemsDeleted = 0;
            
            try {
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'CustomerOrders__c';
                actionReq.operation = 'update';
                actionReq.recordId = req.recordId;
                actionReq.fieldDataJson = req.fieldDataJson;
                actionReq.accountName = req.accountName;
                actionReq.contactNameOrEmail = req.contactNameOrEmail;
                actionReq.confirm = req.confirm;
                
                // Call shared business logic for order header update
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message;
                    res.previewOnly = actionRes.previewOnly != null ? actionRes.previewOnly : false;
                    res.previewData = actionRes.previewData;
                    res.availableFieldsJson = actionRes.availableFieldsJson;
                    res.ambiguousRelationship = actionRes.ambiguousRelationship != null ? actionRes.ambiguousRelationship : false;
                    res.ambiguousRelationshipType = actionRes.ambiguousRelationshipType;
                    res.relationshipCandidatesJson = actionRes.relationshipCandidatesJson;
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                    
                    if (actionRes.record != null) {
                        res.record = (CustomerOrders__c) actionRes.record;
                        res.recordId = (Id) res.record.Id;
                        
                        // Handle line item operations if not preview mode
                        if (!res.previewOnly) {
                            Integer initialCount = AFUniversalCrmRecordAction.getLineItemCount(res.recordId);
                            
                            // Track line item operations
                            if (!String.isBlank(req.addLineItemsJson)) {
                                List<Object> addList = (List<Object>) JSON.deserializeUntyped(req.addLineItemsJson);
                                res.lineItemsAdded = addList.size();
                            }
                            if (!String.isBlank(req.updateLineItemsJson)) {
                                List<Object> updateList = (List<Object>) JSON.deserializeUntyped(req.updateLineItemsJson);
                                res.lineItemsUpdated = updateList.size();
                            }
                            if (!String.isBlank(req.deleteLineItemIds)) {
                                List<Object> deleteList = (List<Object>) JSON.deserializeUntyped(req.deleteLineItemIds);
                                res.lineItemsDeleted = deleteList.size();
                            }
                            
                            // Handle line items (add, update, delete)
                            res.lineItems = AFUniversalCrmRecordAction.handleLineItemsOnUpdate(
                                res.recordId,
                                req.addLineItemsJson,
                                req.updateLineItemsJson,
                                req.deleteLineItemIds
                            );
                            res.lineItemCount = res.lineItems.size();
                            
                            // Enhance message with line item operations
                            if (res.lineItemsAdded > 0 || res.lineItemsUpdated > 0 || res.lineItemsDeleted > 0) {
                                List<String> lineItemOps = new List<String>();
                                if (res.lineItemsAdded > 0) lineItemOps.add(res.lineItemsAdded + ' item' + (res.lineItemsAdded != 1 ? 's' : '') + ' added');
                                if (res.lineItemsUpdated > 0) lineItemOps.add(res.lineItemsUpdated + ' item' + (res.lineItemsUpdated != 1 ? 's' : '') + ' updated');
                                if (res.lineItemsDeleted > 0) lineItemOps.add(res.lineItemsDeleted + ' item' + (res.lineItemsDeleted != 1 ? 's' : '') + ' deleted');
                                res.message += '. Line items: ' + String.join(lineItemOps, ', ') + '. Total items: ' + res.lineItemCount;
                            } else {
                                res.message += '. Order has ' + res.lineItemCount + ' line item' + (res.lineItemCount != 1 ? 's' : '');
                            }
                        }
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to update Customer Order.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error updating Customer Order: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFCustomerOrderUpdateAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




