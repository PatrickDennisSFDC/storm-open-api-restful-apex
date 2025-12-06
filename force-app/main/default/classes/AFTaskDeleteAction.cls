/**
 * AF Task Delete Action
 * Invocable action for deleting Task records (with confirmation pattern)
 * Designed for Agentforce AI agents
 */
public with sharing class AFTaskDeleteAction {
    
    /**
     * Request input for delete operation
     */
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce record ID (15 or 18 character) of the Task to delete. Required for delete operation. Format: 18-character ID like "00Txx000003DGbYAAW". Use the record ID from a previous findTasks, createTask, or readTask operation.'
            required=true
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Confirm'
            description='Set to true to actually perform the delete operation. If false (default), returns a confirmation message with task details. The agent should first call with confirm=false to get confirmation details, ask the user, then call again with confirm=true if the user confirms.'
            required=false
        )
        public Boolean confirm;
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
            description='The Salesforce ID of the deleted record (18-character format like "00Txx000003DGbYAAW"). Useful for confirmation and logging.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the operation result. Use this exact message to inform the user. Examples: "Task deleted successfully", "This will delete Task \'Follow up with John\'. Call again with confirm=true to proceed."'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user. Example: "Task not found with ID 00Txx000003DGbYAAW".'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Task" for Task delete operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Confirmation Required'
            description='True if this is a confirmation request (confirm=false). The agent should present the message to the user and call again with confirm=true if the user confirms the deletion.'
        )
        public Boolean confirmationRequired;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account (WhatId) if the task is linked to an account. Use this in the confirmation message.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact (WhoId) if the task is linked to a contact. Use this in the confirmation message.'
        )
        public String relatedContactName;
    }
    
    /**
     * Delete Task by ID (with confirmation pattern)
     */
    @InvocableMethod(
        label='Delete Task'
        description='Deletes a Task record by its Salesforce ID. Requires confirmation: first call with confirm=false to get task details, then call again with confirm=true to actually delete. This two-step process prevents accidental deletions.'
        category='CRM Actions'
    )
    public static List<Response> deleteTask(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Task';
            res.success = false;
            res.confirmationRequired = false;
            
            try {
                if (req.recordId == null) {
                    res.success = false;
                    res.errorMessage = 'Record ID is required. Provide the 18-character Salesforce Task ID.';
                    responses.add(res);
                    continue;
                }
                
                // Check if confirmation is required
                if (req.confirm == null || req.confirm == false) {
                    // Return confirmation message with task info
                    res.confirmationRequired = true;
                    res.recordId = req.recordId;
                    
                    // Get task info for confirmation message
                    try {
                        Task task = [SELECT Id, Subject, Status, Priority, ActivityDate, 
                                     What.Name, Who.Name
                                     FROM Task 
                                     WHERE Id = :req.recordId 
                                     LIMIT 1];
                        
                        String taskDesc = 'Task';
                        if (task.Subject != null) {
                            taskDesc = 'Task "' + task.Subject + '"';
                        }
                        if (task.What != null) {
                            res.relatedAccountName = task.What.Name;
                        }
                        if (task.Who != null) {
                            res.relatedContactName = task.Who.Name;
                        }
                        
                        String context = '';
                        if (res.relatedContactName != null) {
                            context = ' for ' + res.relatedContactName;
                        } else if (res.relatedAccountName != null) {
                            context = ' for ' + res.relatedAccountName;
                        }
                        
                        res.message = 'This will delete ' + taskDesc + context + 
                                     ' (Status: ' + (task.Status != null ? task.Status : 'Unknown') + '). ' +
                                     'Call again with confirm=true to proceed with deletion.';
                        res.success = true;
                    } catch (QueryException qe) {
                        res.success = false;
                        res.errorMessage = 'Task not found with ID: ' + req.recordId;
                    }
                    
                    responses.add(res);
                    continue;
                }
                
                // Perform actual delete
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Task';
                actionReq.operation = 'delete';
                actionReq.recordId = req.recordId;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.recordId = actionRes.recordId;
                    res.message = actionRes.message != null ? actionRes.message : 'Task deleted successfully.';
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to delete Task.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error deleting Task: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFTaskDeleteAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




