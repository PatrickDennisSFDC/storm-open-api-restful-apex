/**
 * AF Meeting Create Action
 * Invocable action for creating Meeting__c records (single or bulk)
 * Designed for Agentforce AI agents
 */
public with sharing class AFMeetingCreateAction {
    
    /**
     * Request input for create operation
     */
    public class Request {
        @InvocableVariable(
            label='Field Data JSON'
            description='JSON string containing Meeting field data. Required fields: Meeting_Date__c, Subject__c. INTELLIGENT FIELD MAPPING: Use your semantic understanding to map natural language to structured fields. When user describes a meeting conversationally (e.g., "had lunch with Dr. Smith, discussed Product X, went well, need to follow up"), extract and infer the appropriate values: Parse meeting type from context (lunch→In-Person Visit, zoom→Virtual Meeting, etc.), infer outcome from sentiment (optimistic/good→Productive, excellent→Very Productive), detect follow-up needs from language (mentions of "next steps" or "follow up"→Follow_Up_Required__c:true), extract product names, sample/material info, and other structured data from description. Query availableFieldsJson to see valid picklist options, then use your best judgment to map. If unclear, leave field blank. Example: {"Subject__c":"Lunch with Dr. Smith","Meeting_Date__c":"2024-12-10","Meeting_Type__c":"In-Person Visit","Meeting_Outcome__c":"Productive","Follow_Up_Required__c":true,"Description__c":"Discussed Product X proposal"}. Use accountName or contactNameOrEmail to resolve lookups by name.'
            required=true
        )
        public String fieldDataJson;
        
        @InvocableVariable(
            label='Account Name'
            description='Account name to resolve to Account__c lookup. If provided, system searches for an Account and links the Meeting to it. Example: "Acme Corp".'
            required=false
        )
        public String accountName;
        
        @InvocableVariable(
            label='Contact Name or Email'
            description='Contact name or email to resolve to Contact__c lookup. If provided, system searches for a Contact and links the Meeting to them. Example: "John Smith" or "john@example.com".'
            required=false
        )
        public String contactNameOrEmail;
        
        @InvocableVariable(
            label='Confirm'
            description='Optional: Set to false to preview only without creating. Default (true): Creates the record immediately. When user says "create meeting", omit this field or set to true to create immediately. Only set to false if user explicitly asks to preview first.'
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
            description='The single Meeting record created (when exactly one record created). Use the record.Id field from this record for follow-up operations. This is null when multiple records are created.'
        )
        public Meeting__c record;
        
        @InvocableVariable(
            label='Records'
            description='List of Meeting records created. Use record.Id from each record for subsequent operations like updating or referencing the meetings.'
        )
        public List<Meeting__c> records;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the Meeting record (18-character format). Only populated when exactly one record is created. Use this ID for update, delete, or read Meeting operations.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the result. Use this exact message to inform the user. Examples: "Meeting created successfully", "2 Meetings created successfully", "Meeting preview generated (not saved yet)".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Meeting__c" for Meeting create operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Preview Only'
            description='True if this is a preview response (confirm=false). The record has not been created yet. The agent should present the preview to the user, collect additional field data if enrichment is suggested, then call again with confirm=true to commit.'
        )
        public Boolean previewOnly;
        
        @InvocableVariable(
            label='Enrichment Suggested'
            description='True if the provided data is minimal and additional fields are suggested. When true, check suggestedFields for commonly-used fields that could be populated to enrich the Meeting record.'
        )
        public Boolean enrichmentSuggested;
        
        @InvocableVariable(
            label='Suggested Fields'
            description='List of commonly-used field API names that could be populated to enrich this Meeting. Examples: Meeting_Type__c, Meeting_Outcome__c, Product_Discussed__c, Attendees_Count__c. The agent should ask the user about these fields and add them to fieldDataJson before calling again with confirm=true.'
        )
        public List<String> suggestedFields;
        
        @InvocableVariable(
            label='Preview Data'
            description='A JSON string representation of what would be created. Use this to show the user a preview before committing.'
        )
        public String previewData;
        
        @InvocableVariable(
            label='Available Fields JSON'
            description='JSON string containing metadata for all available fields that can be set on Meeting records. Includes API name, label, type, required status, picklist values, help text, and more. Use this to understand what fields are available and their constraints when asking the user for more information.'
        )
        public String availableFieldsJson;
        
        @InvocableVariable(
            label='Related Account Name'
            description='Name of the related Account if the Meeting was linked to an Account. Use this to provide context to the user about what company the meeting is associated with.'
        )
        public String relatedAccountName;
        
        @InvocableVariable(
            label='Related Contact Name'
            description='Name of the related Contact if the Meeting was linked to a Contact. Use this to provide context to the user about who the meeting was with.'
        )
        public String relatedContactName;
        
        @InvocableVariable(
            label='Ambiguous Relationship'
            description='True if a related record lookup (Account or Contact) found multiple matches (2+). When true, DO NOT tell the user the Meeting was created. Instead, you MUST present the candidates from relationshipCandidatesJson to the user and ask which one they meant. Say something like: "I found multiple matches for [Account/Contact name]. Which one did you mean?" Then list the candidates with distinguishing details.'
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
        label='Create Meeting'
        description='Creates a new Meeting record immediately. Required fields: Meeting_Date__c, Subject__c. AGENT INTELLIGENCE: When the user provides meeting details in natural language, you should intelligently infer and map to the appropriate picklist values using your semantic understanding. For Meeting_Type__c, analyze the context (lunch, office visit, zoom call, dinner, etc.) and select the most appropriate value from the available options by querying availableFieldsJson. For Meeting_Outcome__c, assess the user sentiment and descriptions (optimistic, productive, good, excellent, poor, unsuccessful, etc.) and select the best matching value. For Meeting_Status__c, determine if the meeting already happened (Completed), is scheduled for the future (Scheduled), or was not held (Cancelled). For Follow_Up_Required__c, set to true if the user mentions follow-up, next steps, additional actions needed, or future tasks. Use your semantic understanding to map natural language to structured picklist values. If the user input does not clearly map to any available option, leave the field blank rather than forcing a choice. Always query availableFieldsJson in the response to see all valid picklist options before making mapping decisions. Example: {"Subject__c":"Lunch with Dr. Smith","Meeting_Date__c":"2024-12-10","Meeting_Type__c":"In-Person Visit","Meeting_Outcome__c":"Productive","Follow_Up_Required__c":true}. Supports accountName and contactNameOrEmail for automatic lookup resolution. Supports bulk creation with JSON array.'
        category='CRM Actions'
    )
    public static List<Response> createMeeting(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Meeting__c';
            res.success = false;
            res.records = new List<Meeting__c>();
            
            try {
                if (String.isBlank(req.fieldDataJson)) {
                    res.errorMessage = 'Field Data JSON is required. Provide Meeting data as JSON string.';
                    responses.add(res);
                    continue;
                }
                
                Object parsed = JSON.deserializeUntyped(req.fieldDataJson);
                Boolean isBulk = parsed instanceof List<Object>;
                
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Meeting__c';
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
                
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message;
                    res.previewOnly = actionRes.previewOnly != null ? actionRes.previewOnly : false;
                    res.enrichmentSuggested = actionRes.enrichmentSuggested != null ? actionRes.enrichmentSuggested : false;
                    res.suggestedFields = actionRes.suggestedFields;
                    res.previewData = actionRes.previewData;
                    res.availableFieldsJson = actionRes.availableFieldsJson;
                    res.relatedAccountName = actionRes.relatedAccountName;
                    res.relatedContactName = actionRes.relatedContactName;
                    res.ambiguousRelationship = actionRes.ambiguousRelationship != null ? actionRes.ambiguousRelationship : false;
                    res.ambiguousRelationshipType = actionRes.ambiguousRelationshipType;
                    res.relationshipCandidatesJson = actionRes.relationshipCandidatesJson;
                    
                    if (actionRes.record != null) {
                        res.record = (Meeting__c) actionRes.record;
                        res.recordId = res.record.Id;
                        res.records = new List<Meeting__c>{ res.record };
                        System.debug(LoggingLevel.INFO, 'AFMeetingCreateAction: Set recordId from record object: ' + res.recordId);
                    } else if (actionRes.records != null && !actionRes.records.isEmpty()) {
                        res.records = new List<Meeting__c>();
                        for (SObject so : actionRes.records) {
                            res.records.add((Meeting__c) so);
                        }
                        if (!res.records.isEmpty()) {
                            res.record = res.records[0];
                            res.recordId = res.records[0].Id;
                            System.debug(LoggingLevel.INFO, 'AFMeetingCreateAction: Set recordId from records array: ' + res.recordId);
                        }
                    } else if (actionRes.recordId != null) {
                        res.recordId = actionRes.recordId;
                        System.debug(LoggingLevel.INFO, 'AFMeetingCreateAction: Set recordId from actionRes.recordId: ' + res.recordId);
                    } else {
                        System.debug(LoggingLevel.WARN, 'AFMeetingCreateAction: No recordId found in response!');
                    }
                } else {
                    res.success = false;
                    res.errorMessage = actionRes.message != null ? actionRes.message : 'Failed to create Meeting.';
                }
                
            } catch (Exception e) {
                res.success = false;
                res.errorMessage = 'Error creating Meeting: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFMeetingCreateAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}

