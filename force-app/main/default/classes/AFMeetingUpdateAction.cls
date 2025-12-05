/**
 * AF Meeting Update Action
 * Invocable action for updating Meeting__c records
 * Designed for Agentforce AI agents
 */
public with sharing class AFMeetingUpdateAction {
    
    public class Request {
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce record ID of the Meeting__c to update. Optional if Subject__c is provided in fieldDataJson for automatic resolution. Example: {"Subject__c":"Q4 Review","Meeting_Status__c":"Completed"}. For bulk: [{"Subject__c":"Meeting 1","Meeting_Outcome__c":"Productive"},{"Subject__c":"Meeting 2","Meeting_Outcome__c":"Very Productive"}].'
            required=false
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Field Data JSON'
            description='JSON string containing Meeting fields to update. Only include fields you want to change. Example: {"Meeting_Status__c":"Completed","Meeting_Outcome__c":"Productive"}. Can include Subject__c for automatic record resolution if recordId is not provided. For bulk updates: [{"Subject__c":"Meeting 1","Meeting_Outcome__c":"Productive"},{"Subject__c":"Meeting 2","Meeting_Status__c":"Completed"}].'
            required=false
        )
        public String fieldDataJson;
        
        @InvocableVariable(
            label='Account Name'
            description='Account name to resolve to Account__c lookup. Use this to change the meeting\'s account. If multiple matches, system will return candidates for clarification. Example: "Acme Corp".'
            required=false
        )
        public String accountName;
        
        @InvocableVariable(
            label='Contact Name or Email'
            description='Contact name or email to resolve to Contact__c lookup. Use this to change the meeting\'s contact. Example: "John Smith" or "john@example.com".'
            required=false
        )
        public String contactNameOrEmail;
        
        @InvocableVariable(
            label='Confirm'
            description='Optional: Set to false to preview only without committing changes. Default (true): Updates the record immediately. When user says "update meeting", omit this field or set to true to update immediately. Only set to false if user explicitly asks to preview first.'
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
            label='Record'
            description='The updated Meeting record with the new field values. Use this to show the user what was changed or to reference the Meeting in follow-up operations.'
        )
        public Meeting__c record;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Meeting record that was updated (18-character format). Use this ID for subsequent operations like reading or deleting the Meeting.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Examples: "Meeting updated successfully", "Meeting preview generated (changes not saved yet)".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Meeting__c" for Meeting update operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Preview Only'
            description='True if this is a preview response (confirm=false). The record has not been updated yet. The agent should present the preview showing current vs. new values to the user, then call again with confirm=true to commit the changes.'
        )
        public Boolean previewOnly;
        
        @InvocableVariable(
            label='Preview Data'
            description='A JSON string showing what would be changed. Format: {"FieldName":{"current":"old value","new":"new value"},...}. Use this to show the user what changes will be made before committing.'
        )
        public String previewData;
        
        @InvocableVariable(
            label='Available Fields JSON'
            description='JSON string containing metadata for all available fields that can be updated on Meeting records. Includes API name, label, type, required status, picklist values, help text, and more. Use this to understand what fields can be updated when asking the user what they want to change.'
        )
        public String availableFieldsJson;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Meeting is linked to an Account. Use this to provide context to the user about what company the meeting is associated with.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Meeting is linked to a Contact. Use this to provide context to the user about who the meeting is with.'
        )
        public String relatedContactName;
        
        @InvocableVariable(
            label='Ambiguous Relationship'
            description='True if a related record lookup (Account or Contact) found multiple matches (2+). When true, DO NOT tell the user the Meeting was updated. Instead, you MUST present the candidates from relationshipCandidatesJson to the user and ask which one they meant. Say something like: "I found multiple matches for [Account/Contact name]. Which one did you mean?" Then list the candidates with distinguishing details.'
        )
        public Boolean ambiguousRelationship;
        
        @InvocableVariable(
            label='Ambiguous Relationship Type'
            description='The type of relationship that has multiple matches: "Account" or "Contact". Use this to know what kind of candidates are provided. For example, if this is "Account", the candidates are Account records. If this is "Contact", the candidates are Contact records.'
        )
        public String ambiguousRelationshipType;
        
        @InvocableVariable(
            label='Relationship Candidates JSON'
            description='JSON array of candidate records when ambiguousRelationship is true. Each candidate includes disambiguating details. For Accounts: Name, BillingCity, BillingState, Phone, Industry. For Contacts: Name, Email, Phone, Account.Name, Title. Present these options to the user in a clear, numbered list with the distinguishing details, then ask them to clarify which one they meant. Example: "I found 3 accounts named Acme: 1) Acme Corp (San Francisco, CA, Technology), 2) Acme Inc (New York, NY, Manufacturing), 3) Acme LLC (Austin, TX, Retail). Which one did you mean?"'
        )
        public String relationshipCandidatesJson;
    }
    
    @InvocableMethod(
        label='Update Meeting'
        description='Updates an existing Meeting__c record immediately. Pass Meeting ID OR include Subject__c in fieldDataJson for automatic resolution. Supports bulk updates by Subject.'
        category='CRM Actions'
    )
    public static List<Response> updateMeeting(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Meeting__c';
            res.success = false;
            
            try {
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Meeting__c';
                actionReq.operation = 'update';
                actionReq.recordId = req.recordId;
                actionReq.fieldDataJson = req.fieldDataJson;
                actionReq.accountName = req.accountName;
                actionReq.contactNameOrEmail = req.contactNameOrEmail;
                actionReq.confirm = req.confirm;
                
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message != null ? actionRes.message : 'Meeting updated successfully.';
                    res.previewOnly = actionRes.previewOnly != null ? actionRes.previewOnly : false;
                    res.previewData = actionRes.previewData;
                    res.availableFieldsJson = actionRes.availableFieldsJson;
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                    res.ambiguousRelationship = actionRes.ambiguousRelationship != null ? actionRes.ambiguousRelationship : false;
                    res.ambiguousRelationshipType = actionRes.ambiguousRelationshipType;
                    res.relationshipCandidatesJson = actionRes.relationshipCandidatesJson;
                    
                    if (actionRes.record != null) {
                        res.record = (Meeting__c) actionRes.record;
                        res.recordId = actionRes.recordId;
                    } else if (actionRes.recordId != null) {
                        res.recordId = actionRes.recordId;
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to update Meeting.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error updating Meeting: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFMeetingUpdateAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}

