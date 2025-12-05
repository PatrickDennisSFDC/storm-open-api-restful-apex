/**
 * AF Meeting Delete Action
 * Invocable action for deleting Meeting__c records (with confirmation)
 * Designed for Agentforce AI agents
 */
public with sharing class AFMeetingDeleteAction {
    
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Meeting__c to delete (18-character format). Use the record ID from a previous findMeetings or readMeeting operation. Example: "a0Bxx000000ABCDEF".'
            required=true
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Confirm'
            description='Optional: Set to false for safety check (returns meeting details), then set to true to actually delete. Default (false): Returns confirmation message. When user says "delete meeting", first call with confirm=false to show what will be deleted, then call again with confirm=true to proceed.'
            required=false
        )
        public Boolean confirm;
    }
    
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Meeting record that was deleted (or will be deleted if confirmation required). Use this to reference the meeting in follow-up messages.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Examples: "This will delete Meeting [Subject] (Date: XX). Call again with confirm=true to proceed." or "Meeting deleted successfully".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Meeting__c" for Meeting delete operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Confirmation Required'
            description='True if this is a confirmation request (confirm=false was passed). When true, the meeting has NOT been deleted yet. Show the user the message (which includes meeting details), then call again with confirm=true to actually delete.'
        )
        public Boolean confirmationRequired;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Meeting is linked to an Account. Use this to provide context to the user about what company the meeting is associated with.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Meeting is linked to a Contact. Use this to provide context to the user about who the meeting was with.'
        )
        public String relatedContactName;
    }
    
    @InvocableMethod(
        label='Delete Meeting'
        description='Deletes a Meeting__c record. Requires confirmation: first call with confirm=false, then with confirm=true to actually delete.'
        category='CRM Actions'
    )
    public static List<Response> deleteMeeting(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Meeting__c';
            res.success = false;
            res.confirmationRequired = false;
            
            try {
                if (req.recordId == null) {
                    res.errorMessage = 'Record ID is required.';
                    responses.add(res);
                    continue;
                }
                
                if (req.confirm == null || req.confirm == false) {
                    res.confirmationRequired = true;
                    res.recordId = req.recordId;
                    
                    try {
                        Meeting__c meeting = [SELECT Id, Subject__c, Meeting_Date__c, Meeting_Status__c,
                                             Account__r.Name, Contact__r.Name
                                             FROM Meeting__c 
                                             WHERE Id = :req.recordId 
                                             LIMIT 1];
                        
                        if (meeting.Account__r != null) {
                            res.relatedAccountName = meeting.Account__r.Name;
                        }
                        if (meeting.Contact__r != null) {
                            res.relatedContactName = meeting.Contact__r.Name;
                        }
                        
                        String meetingDesc = meeting.Subject__c != null ? '"' + meeting.Subject__c + '"' : 'this meeting';
                        res.message = 'This will delete Meeting ' + meetingDesc + 
                                     ' (Date: ' + meeting.Meeting_Date__c + '). ' +
                                     'Call again with confirm=true to proceed.';
                        res.success = true;
                    } catch (QueryException qe) {
                        res.errorMessage = 'Meeting not found with ID: ' + req.recordId;
                    }
                    
                    responses.add(res);
                    continue;
                }
                
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Meeting__c';
                actionReq.operation = 'delete';
                actionReq.recordId = req.recordId;
                
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                if (actionRes.success) {
                    res.success = true;
                    res.recordId = actionRes.recordId;
                    res.message = actionRes.message != null ? actionRes.message : 'Meeting deleted successfully.';
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to delete Meeting.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error deleting Meeting: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFMeetingDeleteAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}


