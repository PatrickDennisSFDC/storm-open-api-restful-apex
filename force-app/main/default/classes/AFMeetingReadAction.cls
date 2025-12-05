/**
 * AF Meeting Read Action
 * Invocable action for reading Meeting__c records by ID
 * Designed for Agentforce AI agents
 */
public with sharing class AFMeetingReadAction {
    
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce record ID of the Meeting__c to read. Format: 18-character ID. Use the record ID from a previous findMeetings or createMeeting operation.'
            required=true
        )
        public Id recordId;
    }
    
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The Meeting record that was retrieved with all field data. Use this to show meeting details to the user including Subject, Meeting Date, Status, Type, Outcome, and other fields.'
        )
        public Meeting__c record;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Meeting record that was read (18-character format). Use this ID for subsequent operations like updating or deleting the Meeting.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Example: "Meeting retrieved successfully".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Meeting__c" for Meeting read operations. Useful for agent context and logging.'
        )
        public String objectType;
        
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
        label='Read Meeting'
        description='Retrieves a Meeting__c record by its Salesforce ID. Returns complete Meeting record with related Account and Contact names for context.'
        category='CRM Actions'
    )
    public static List<Response> readMeeting(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Meeting__c';
            res.success = false;
            
            try {
                if (req.recordId == null) {
                    res.errorMessage = 'Record ID is required.';
                    responses.add(res);
                    continue;
                }
                
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Meeting__c';
                actionReq.operation = 'read';
                actionReq.recordId = req.recordId;
                
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                if (actionRes.success && actionRes.record != null) {
                    res.success = true;
                    res.record = (Meeting__c) actionRes.record;
                    res.recordId = actionRes.recordId;
                    res.message = actionRes.message != null ? actionRes.message : 'Meeting retrieved successfully.';
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Meeting not found.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error retrieving Meeting: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFMeetingReadAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}


