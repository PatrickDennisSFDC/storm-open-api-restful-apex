/**
 * AF Customer Order Create Action
 * Invocable action for creating CustomerOrders__c records (single or bulk)
 * Supports optional line items creation in the same transaction
 * Designed for Agentforce AI agents
 */
public with sharing class AFCustomerOrderCreateAction {
    
    /**
     * Request input for create operation
     */
    public class Request {
        @InvocableVariable(
            label='Field Data JSON'
            description='JSON string containing Customer Order field data. For single record: {"Name":"Q4 2024 Order","Status__c":"Draft","Order_Date__c":"2024-12-04"}. For bulk: [{"Name":"Order 1"},{"Name":"Order 2"}]. Required field: Name. Optional fields: Status__c, Order_Date__c, Priority__c, Order_Number__c, PO_Number__c, Shipping_Method__c, Order_Notes__c, etc. The agent should pass all field data as a JSON string.'
            required=true
        )
        public String fieldDataJson;
        
        @InvocableVariable(
            label='Account Name'
            description='Account name to resolve to Account__c lookup. If provided, system searches for an Account and links the Order to it. Example: "Acme Corp". If multiple matches, system will return candidates for clarification.'
            required=false
        )
        public String accountName;
        
        @InvocableVariable(
            label='Contact Name or Email'
            description='Contact name or email to resolve to Contact__c lookup. If provided, system searches for a Contact and links the Order to them. Example: "John Smith" or "john@example.com".'
            required=false
        )
        public String contactNameOrEmail;
        
        @InvocableVariable(
            label='Line Items JSON'
            description='JSON array of line items to create with the order. Optional. Format: [{"Product_Name__c":"Widget A","Quantity__c":10,"Unit_Price__c":50.00},{"Product_Name__c":"Widget B","Quantity__c":5,"Unit_Price__c":100.00}]. Each line item requires: Product_Name__c, Quantity__c, Unit_Price__c. Optional: SKU__c, Fulfillment_Notes__c. Line items are created in the same transaction as the order.'
            required=false
        )
        public String lineItemsJson;
        
        @InvocableVariable(
            label='Confirm'
            description='Optional: Set to false to preview only without creating. Default (true): Creates the record immediately. When user says "create order", omit this field or set to true to create immediately. Only set to false if user explicitly asks to preview first.'
            required=false
        )
        public Boolean confirm;
    }
    
    /**
     * Response output for create operation
     */
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The Customer Order record that was created (for single create operation). Use the record.Id field from this record for follow-up operations. This is null for bulk operations.'
        )
        public CustomerOrders__c record;
        
        @InvocableVariable(
            label='Records'
            description='List of Customer Order records created (for bulk create operation). Use record.Id from each record for subsequent operations. For single create, this will contain one record.'
        )
        public List<CustomerOrders__c> records;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the created Customer Order (18-character format). Use this ID for update, delete, or read operations. This is the primary identifier for follow-up operations in the conversation.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Line Items'
            description='List of line items that were created with the order. Each line item includes Id, Product_Name__c, SKU__c, Quantity__c, Unit_Price__c, Total__c. Use these IDs to reference or update specific line items later in the conversation.'
        )
        public List<Customer_Order_Line_Item__c> lineItems;
        
        @InvocableVariable(
            label='Line Item Count'
            description='Number of line items created with the order. Use this to inform the user: "Order created with 3 line items" or "Order created (no line items yet)".'
        )
        public Integer lineItemCount;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the operation result. Use this exact message to inform the user. Examples: "Customer Order created successfully with 3 line items", "Order created with ID a2sxx... (no line items)".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "CustomerOrders__c" for Customer Order create operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Preview Only'
            description='True if this is a preview response (confirm=false). The record has not been created yet. The agent should present the preview to the user, collect additional field data if enrichment is suggested, then call again with confirm=true to commit.'
        )
        public Boolean previewOnly;
        
        @InvocableVariable(
            label='Enrichment Suggested'
            description='True if the provided data is minimal and additional fields are suggested. When true, check suggestedFields for commonly-used fields that could be populated to enrich the record.'
        )
        public Boolean enrichmentSuggested;
        
        @InvocableVariable(
            label='Suggested Fields'
            description='List of commonly-used field API names that could be populated to enrich this Order. Examples: Status__c, Order_Date__c, Priority__c, Shipping_Method__c. The agent should ask the user about these fields and add them to fieldDataJson before calling again with confirm=true.'
        )
        public List<String> suggestedFields;
        
        @InvocableVariable(
            label='Preview Data'
            description='A JSON string representation of what would be created. Use this to show the user a preview before committing.'
        )
        public String previewData;
        
        @InvocableVariable(
            label='Available Fields JSON'
            description='JSON string containing metadata for all available fields that can be set on Customer Order records. Includes API name, label, type, required status, picklist values, help text, and more.'
        )
        public String availableFieldsJson;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Order was linked to an Account. Use this to provide context to the user.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Order was linked to a Contact. Use this to provide context to the user.'
        )
        public String relatedContactName;
        
        @InvocableVariable(
            label='Ambiguous Relationship'
            description='True if a related record lookup (Account or Contact) found multiple matches (2+). When true, DO NOT tell the user the Order was created. Instead, you MUST present the candidates from relationshipCandidatesJson to the user and ask which one they meant.'
        )
        public Boolean ambiguousRelationship;
        
        @InvocableVariable(
            label='Ambiguous Relationship Type'
            description='The type of relationship that has multiple matches: "Account" or "Contact". Use this to know what kind of candidates are provided.'
        )
        public String ambiguousRelationshipType;
        
        @InvocableVariable(
            label='Relationship Candidates JSON'
            description='JSON array of candidate records when ambiguousRelationship is true. Present these options to the user in a clear, numbered list with distinguishing details, then ask them to clarify which one they meant.'
        )
        public String relationshipCandidatesJson;
    }
    
    /**
     * Create Customer Order(s) - supports both single and bulk creation
     * Detects automatically if fieldDataJson is a single object or array
     */
    @InvocableMethod(
        label='Create Customer Order'
        description='Creates a new Customer Order record immediately. Required field: Name. Supports optional line items creation in the same call (use lineItemsJson parameter). Pass JSON object: {"Name":"Q4 Order","Status__c":"Draft","Order_Date__c":"2024-12-04"}. Default behavior creates the record right away. Supports bulk creation with JSON array. Use accountName or contactNameOrEmail to automatically link to Account/Contact.'
        category='CRM Actions'
    )
    public static List<Response> createCustomerOrder(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'CustomerOrders__c';
            res.success = false;
            res.records = new List<CustomerOrders__c>();
            res.lineItems = new List<Customer_Order_Line_Item__c>();
            res.lineItemCount = 0;
            
            try {
                if (String.isBlank(req.fieldDataJson)) {
                    res.errorMessage = 'Field Data JSON is required. Provide Order data as JSON string, e.g., {"Name":"Q4 Order"}.';
                    responses.add(res);
                    continue;
                }
                
                // Parse JSON to detect if single or bulk
                Object parsed = JSON.deserializeUntyped(req.fieldDataJson);
                Boolean isBulk = parsed instanceof List<Object>;
                
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'CustomerOrders__c';
                actionReq.accountName = req.accountName;
                actionReq.contactNameOrEmail = req.contactNameOrEmail;
                actionReq.confirm = req.confirm;
                
                if (isBulk) {
                    actionReq.operation = 'bulkCreate';
                    actionReq.bulkRecordsJson = req.fieldDataJson;
                } else {
                    actionReq.operation = 'create';
                    actionReq.fieldDataJson = req.fieldDataJson;
                }
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message;
                    res.previewOnly = actionRes.previewOnly != null ? actionRes.previewOnly : false;
                    res.enrichmentSuggested = actionRes.enrichmentSuggested != null ? actionRes.enrichmentSuggested : false;
                    res.suggestedFields = actionRes.suggestedFields;
                    res.previewData = actionRes.previewData;
                    res.availableFieldsJson = actionRes.availableFieldsJson;
                    res.ambiguousRelationship = actionRes.ambiguousRelationship != null ? actionRes.ambiguousRelationship : false;
                    res.ambiguousRelationshipType = actionRes.ambiguousRelationshipType;
                    res.relationshipCandidatesJson = actionRes.relationshipCandidatesJson;
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                    
                    if (actionRes.record != null) {
                        res.record = (CustomerOrders__c) actionRes.record;
                        res.recordId = res.record.Id;
                        res.records = new List<CustomerOrders__c>{ res.record };
                        
                        // Handle line items if provided and order was actually created (not preview)
                        if (!res.previewOnly && !String.isBlank(req.lineItemsJson)) {
                            res.lineItems = AFUniversalCrmRecordAction.handleLineItemsOnCreate(res.recordId, req.lineItemsJson);
                            res.lineItemCount = res.lineItems.size();
                            res.message += ' with ' + res.lineItemCount + ' line item' + (res.lineItemCount != 1 ? 's' : '');
                        }
                    } else if (actionRes.records != null && !actionRes.records.isEmpty()) {
                        res.records = new List<CustomerOrders__c>();
                        for (SObject so : actionRes.records) {
                            res.records.add((CustomerOrders__c) so);
                        }
                        if (!res.records.isEmpty()) {
                            res.record = res.records[0];
                            res.recordId = res.records[0].Id;
                        }
                        // Note: Bulk create with line items not supported in this version
                    } else if (actionRes.recordId != null) {
                        res.recordId = actionRes.recordId;
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to create Customer Order.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error creating Customer Order: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFCustomerOrderCreateAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




