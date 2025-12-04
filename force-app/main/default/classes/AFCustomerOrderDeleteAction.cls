/**
 * AF Customer Order Delete Action
 * Invocable action for deleting CustomerOrders__c records
 * Automatically cascade deletes line items (master-detail relationship)
 * Designed for Agentforce AI agents
 */
public with sharing class AFCustomerOrderDeleteAction {
    
    /**
     * Request input for delete operation
     */
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order to delete (18-character format). Warning: This will also delete all associated line items due to the master-detail relationship.'
            required=true
        )
        public Id recordId;
    }
    
    /**
     * Response output for delete operation
     */
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Customer Order that was deleted.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Line Items Deleted'
            description='Number of line items that were also deleted (cascade delete from master-detail). Use to inform user: "Order deleted along with 5 line items".'
        )
        public Integer lineItemsDeleted;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Example: "Customer Order deleted successfully along with 5 line items".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "CustomerOrders__c" for Customer Order delete operations. Useful for agent context and logging.'
        )
        public String objectType;
    }
    
    /**
     * Delete Customer Order (and cascade delete line items)
     */
    @InvocableMethod(
        label='Delete Customer Order'
        description='Deletes a Customer Order record by ID. WARNING: This will automatically delete all associated line items due to the master-detail relationship. Use when user explicitly requests deletion. Always inform the user that line items will also be deleted.'
        category='CRM Actions'
    )
    public static List<Response> deleteCustomerOrder(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'CustomerOrders__c';
            res.success = false;
            res.lineItemsDeleted = 0;
            
            try {
                // Get line item count before deleting
                res.lineItemsDeleted = AFUniversalCrmRecordAction.getLineItemCount(req.recordId);
                
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'CustomerOrders__c';
                actionReq.operation = 'delete';
                actionReq.recordId = req.recordId;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.recordId = req.recordId;
                    res.message = 'Customer Order deleted successfully';
                    if (res.lineItemsDeleted > 0) {
                        res.message += ' along with ' + res.lineItemsDeleted + ' line item' + (res.lineItemsDeleted != 1 ? 's' : '');
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to delete Customer Order.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error deleting Customer Order: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFCustomerOrderDeleteAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}


