/**
 * AF Customer Order Read Action
 * Invocable action for reading a single CustomerOrders__c record
 * Always includes line items with lineNumber for agent reference
 * Designed for Agentforce AI agents
 */
public with sharing class AFCustomerOrderReadAction {
    
    /**
     * Request input for read operation
     */
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order to read (18-character format). Example: "a2sxx000000ABCDEF".'
            required=true
        )
        public Id recordId;
    }
    
    /**
     * Response output for read operation
     */
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The Customer Order record with all field data. Use this to show order details to the user including Name, Status, Dates, Account, Contact, etc.'
        )
        public CustomerOrders__c record;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order that was read (18-character format).'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Line Items'
            description='List of all line items for this order, ordered by creation date. Each item includes: Id, Product_Name__c, SKU__c, Quantity__c, Unit_Price__c, Total__c, Fulfillment_Notes__c. The agent should present these to the user with line numbers (1, 2, 3...) for easy reference in follow-up operations like "update line item 2".'
        )
        public List<Customer_Order_Line_Item__c> lineItems;
        
        @InvocableVariable(
            label='Line Item Count'
            description='Total number of line items on this order. Use this to inform the user: "This order has 5 items" or "This order has no line items yet".'
        )
        public Integer lineItemCount;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Example: "Customer Order retrieved successfully with 5 line items".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "CustomerOrders__c" for Customer Order read operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Order is linked to an Account. Use this to provide context to the user: "Order for Acme Corp".'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Order is linked to a Contact. Use this to provide context to the user: "Order for John Smith".'
        )
        public String relatedContactName;
    }
    
    /**
     * Read Customer Order with line items
     */
    @InvocableMethod(
        label='Read Customer Order'
        description='Retrieves a single Customer Order record by ID including all line items. Use this when user asks "show me Order 12345" or "what\'s on Order XYZ". Returns the complete order with all field data plus a list of line items ordered by creation date. Line items can be referenced by position (1, 2, 3...) in follow-up operations.'
        category='CRM Actions'
    )
    public static List<Response> readCustomerOrder(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'CustomerOrders__c';
            res.success = false;
            res.lineItems = new List<Customer_Order_Line_Item__c>();
            res.lineItemCount = 0;
            
            try {
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'CustomerOrders__c';
                actionReq.operation = 'read';
                actionReq.recordId = req.recordId;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message;
                    
                    if (actionRes.record != null) {
                        res.record = (CustomerOrders__c) actionRes.record;
                        res.recordId = (Id) res.record.Id;
                        
                        // Get related object names
                        if (res.record.Account__c != null) {
                            res.relatedAccountName = res.record.Account__r != null ? res.record.Account__r.Name : null;
                        }
                        if (res.record.Contact__c != null) {
                            res.relatedContactName = res.record.Contact__r != null ? res.record.Contact__r.Name : null;
                        }
                        
                        // Query line items
                        res.lineItems = AFUniversalCrmRecordAction.handleLineItemsOnRead(res.recordId);
                        res.lineItemCount = res.lineItems.size();
                        
                        // Update message to include line item count
                        res.message += ' with ' + res.lineItemCount + ' line item' + (res.lineItemCount != 1 ? 's' : '');
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to read Customer Order.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error reading Customer Order: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFCustomerOrderReadAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}


