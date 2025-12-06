/**
 * AF Customer Order Find Action
 * Invocable action for finding/searching CustomerOrders__c records
 * Returns line item counts for multiple results, full line items for single result
 * Designed for Agentforce AI agents
 */
public with sharing class AFCustomerOrderFindAction {
    
    /**
     * Request input for find operation
     */
    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Text to search for in Customer Order fields (Name, Order_Number__c, PO_Number__c, Status__c). The search will find orders where any of these fields contain the search term. Example: "Q4" or "12345" or "Acme".'
            required=false
        )
        public String searchTerm;
        
        @InvocableVariable(
            label='Filters JSON'
            description='JSON string of exact-match filters. Can be single object {"fieldApiName":"Status__c","value":"Draft"} or array [{"fieldApiName":"Status__c","value":"Draft"},{"fieldApiName":"Priority__c","value":"High"}]. Common filter fields: Status__c, Priority__c, Order_Type__c, Shipping_Method__c, Temperature_Controlled__c.'
            required=false
        )
        public String filtersJson;
        
        @InvocableVariable(
            label='Account Name'
            description='Filter orders by Account name. Use this when user asks "Find orders for Acme Corp". System will resolve the Account and filter to orders linked to that Account__c.'
            required=false
        )
        public String accountName;
        
        @InvocableVariable(
            label='Contact Name or Email'
            description='Filter orders by Contact name or email. Use this when user asks "Find orders for John Smith". System will resolve the Contact and filter to orders linked to that Contact__c.'
            required=false
        )
        public String contactNameOrEmail;
        
        @InvocableVariable(
            label='Search Limit'
            description='Maximum number of records to return (default: 5, max: 20). If more records match, the response will indicate how many total matches were found.'
            required=false
        )
        public Integer searchLimit;
    }
    
    /**
     * Response output for find operation
     */
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The single Customer Order record found (when exactly one match). Use the record.Id field from this record for follow-up operations. This is null when multiple or zero records are found.'
        )
        public CustomerOrders__c record;
        
        @InvocableVariable(
            label='Records'
            description='List of Customer Order records found. Use record.Id from each record for subsequent operations. If multiple matches, present all options to the user with distinguishing details like Status, Order_Date, Account, Total.'
        )
        public List<CustomerOrders__c> records;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the record (18-character format). Only populated when exactly one record is found. Use this ID for update, delete, or read operations.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Line Items'
            description='List of line items for the order. ONLY populated when exactly ONE order is found (single result). For multiple orders, use lineItemCounts instead. Each line item includes position for reference: "Line 1: Widget A (qty 10)".'
        )
        public List<Customer_Order_Line_Item__c> lineItems;
        
        @InvocableVariable(
            label='Line Item Count'
            description='Number of line items on the single order found. Only populated when exactly one record is found. Use to inform user: "Found Order 12345 with 5 line items".'
        )
        public Integer lineItemCount;
        
        @InvocableVariable(
            label='Line Item Counts JSON'
            description='JSON object mapping order IDs to line item counts when multiple orders are found. Format: {"a2sxxx":5,"a2syyy":3}. Use this to tell user: "Found 2 orders: Order A has 5 items, Order B has 3 items".'
        )
        public String lineItemCountsJson;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the search results. Use this exact message to inform the user. Examples: "Found exactly one matching Customer Order with 5 line items", "Found 3 Customer Order records (use lineItemCountsJson for item counts)", "No Customer Orders found matching the criteria".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "CustomerOrders__c" for Customer Order find operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Ambiguous'
            description='True if multiple records were found in the search. When true, present all records to the user and ask for clarification using additional identifying fields like Status, Order_Number, Order_Date, Account, or Total to narrow down the selection.'
        )
        public Boolean ambiguous;
        
        @InvocableVariable(
            label='Total Matches'
            description='Number of Customer Order records found in the search. Use this to inform the user: "Found X matching orders" or "No orders found matching your criteria".'
        )
        public Integer totalMatches;
        
        @InvocableVariable(
            label='More Results Available'
            description='True if the search returned the maximum number of results (searchLimit) but there are more matching records available. When true, suggest the user provide more specific search criteria.'
        )
        public Boolean moreResultsAvailable;
    }
    
    /**
     * Find/Search Customer Orders
     */
    @InvocableMethod(
        label='Find Customer Orders'
        description='Searches for Customer Order records using a search term and/or filters. Returns matching orders. For SINGLE result: includes full line items. For MULTIPLE results: includes line item counts only (check lineItemCountsJson). Supports filtering by Account or Contact using accountName/contactNameOrEmail parameters. Use when user asks "find orders for Acme" or "show me Draft orders" or "what orders do I have from last month".'
        category='CRM Actions'
    )
    public static List<Response> findCustomerOrders(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'CustomerOrders__c';
            res.success = false;
            res.records = new List<CustomerOrders__c>();
            res.lineItems = new List<Customer_Order_Line_Item__c>();
            res.lineItemCount = 0;
            res.totalMatches = 0;
            res.ambiguous = false;
            res.moreResultsAvailable = false;
            
            try {
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'CustomerOrders__c';
                actionReq.operation = 'find';
                actionReq.searchTerm = req.searchTerm;
                actionReq.filtersJson = req.filtersJson;
                actionReq.accountName = req.accountName;
                actionReq.contactNameOrEmail = req.contactNameOrEmail;
                actionReq.searchLimit = req.searchLimit;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message;
                    res.ambiguous = actionRes.ambiguous != null ? actionRes.ambiguous : false;
                    res.totalMatches = actionRes.totalMatches != null ? actionRes.totalMatches : 0;
                    
                    if (actionRes.record != null) {
                        // Single result - include full line items
                        res.record = (CustomerOrders__c) actionRes.record;
                        res.recordId = actionRes.recordId;
                        res.records = new List<CustomerOrders__c>{ res.record };
                        
                        // Query line items for single result
                        res.lineItems = AFUniversalCrmRecordAction.handleLineItemsOnRead(res.recordId);
                        res.lineItemCount = res.lineItems.size();
                        
                        // Update message
                        res.message = 'Found exactly one matching Customer Order with ' + 
                                     res.lineItemCount + ' line item' + (res.lineItemCount != 1 ? 's' : '');
                        
                    } else if (actionRes.records != null && !actionRes.records.isEmpty()) {
                        // Multiple results - include line item counts only
                        res.records = new List<CustomerOrders__c>();
                        List<Id> orderIds = new List<Id>();
                        
                        for (SObject so : actionRes.records) {
                            CustomerOrders__c order = (CustomerOrders__c) so;
                            res.records.add(order);
                            orderIds.add(order.Id);
                        }
                        
                        if (res.records.size() == 1) {
                            res.record = res.records[0];
                            res.recordId = res.records[0].Id;
                            
                            // Single result - include full line items
                            res.lineItems = AFUniversalCrmRecordAction.handleLineItemsOnRead(res.recordId);
                            res.lineItemCount = res.lineItems.size();
                            res.message = 'Found exactly one matching Customer Order with ' + 
                                         res.lineItemCount + ' line item' + (res.lineItemCount != 1 ? 's' : '');
                        } else {
                            // Multiple results - get line item counts
                            Map<Id, Integer> lineItemCounts = AFUniversalCrmRecordAction.getLineItemCounts(orderIds);
                            res.lineItemCountsJson = JSON.serialize(lineItemCounts);
                            res.message = 'Found ' + res.records.size() + ' matching Customer Orders. ' +
                                         'Use lineItemCountsJson to see line item counts per order.';
                        }
                    }
                    
                    // Check if more results available
                    if (req.searchLimit != null && res.totalMatches >= req.searchLimit) {
                        res.moreResultsAvailable = true;
                    } else if (req.searchLimit == null && res.totalMatches >= 5) {
                        res.moreResultsAvailable = true;
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Search failed.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error searching Customer Orders: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFCustomerOrderFindAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




