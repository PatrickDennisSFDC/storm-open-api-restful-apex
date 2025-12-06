/**
 * AF Task Read Action
 * Invocable action for reading Task records by ID
 * Designed for Agentforce AI agents
 */
public with sharing class AFTaskReadAction {
    
    /**
     * Request input for read operation
     */
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce record ID (15 or 18 character) of the Task to read. Required for read operation. Format: 18-character ID like "00Txx000003DGbYAAW". Use the record ID from a previous findTasks or createTask operation.'
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
            description='The Task record that was retrieved. Use the record.Id field from this record for follow-up operations like updateTask or deleteTask.'
        )
        public Task record;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the record (18-character format like "00Txx000003DGbYAAW"). Use this ID for updateTask, deleteTask, or subsequent readTask operations.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the operation result. Use this exact message to inform the user. Example: "Task retrieved successfully".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user. Example: "Task not found with ID 00Txx000003DGbYAAW".'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Task" for Task read operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account (WhatId) if the task is linked to an account. Use this to provide context to the user.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact (WhoId) if the task is linked to a contact. Use this to provide context to the user.'
        )
        public String relatedContactName;
    }
    
    /**
     * Read Task by ID
     */
    @InvocableMethod(
        label='Read Task'
        description='Retrieves a Task record by its Salesforce ID. Returns the complete Task record with all accessible fields plus related Account and Contact names for context. Use this to get current Task data before updating or to display Task details to the user.'
        category='CRM Actions'
    )
    public static List<Response> readTask(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Task';
            res.success = false;
            
            try {
                if (req.recordId == null) {
                    res.success = false;
                    res.errorMessage = 'Record ID is required. Provide the 18-character Salesforce Task ID.';
                    responses.add(res);
                    continue;
                }
                
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Task';
                actionReq.operation = 'read';
                actionReq.recordId = req.recordId;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success && actionRes.record != null) {
                    res.success = true;
                    res.record = (Task) actionRes.record;
                    res.recordId = actionRes.recordId;
                    res.message = actionRes.message != null ? actionRes.message : 'Task retrieved successfully.';
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Task not found.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error retrieving Task: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFTaskReadAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




