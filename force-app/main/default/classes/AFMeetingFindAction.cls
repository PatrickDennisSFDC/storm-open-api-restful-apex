/**
 * AF Meeting Find Action
 * Invocable action for finding/searching Meeting__c records
 * Designed for Agentforce AI agents
 */
public with sharing class AFMeetingFindAction {
    
    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Text to search for in Meeting fields (Subject__c, Description__c, Meeting_Status__c). The search will find meetings where any of these fields contain the search term. Example: "Product Review" or "John Smith". Leave blank to search using only filters.'
            required=false
        )
        public String searchTerm;
        
        @InvocableVariable(
            label='Filters JSON'
            description='JSON string of exact-match filters. Can be single object {"fieldApiName":"Meeting_Status__c","value":"Scheduled"} or array [{"fieldApiName":"Meeting_Status__c","value":"Scheduled"},{"fieldApiName":"Meeting_Type__c","value":"In-Person Visit"}]. Common filter fields: Meeting_Status__c, Meeting_Type__c, Meeting_Date__c, Contact__c, Account__c.'
            required=false
        )
        public String filtersJson;
        
        @InvocableVariable(
            label='Search Limit'
            description='Maximum number of records to return (default: 5, max: 20). If more records match, the response will indicate how many total matches were found. Use this to limit results for initial searches, then prompt user to narrow down if needed.'
            required=false
        )
        public Integer searchLimit;
    }
    
    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if operation completed successfully, false if an error occurred. Check this before using other output variables.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Record'
            description='The single Meeting record found (when exactly one match). Use the record.Id field from this record for follow-up operations like updating or deleting. This is null when multiple or zero records are found.'
        )
        public Meeting__c record;
        
        @InvocableVariable(
            label='Records'
            description='List of Meeting records found. Use record.Id from each record for subsequent operations. If multiple matches, present all options to the user with distinguishing details like Subject, Meeting Date, Status, Account, and Contact.'
        )
        public List<Meeting__c> records;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the record (18-character format). Only populated when exactly one record is found. Use this ID for update, delete, or read operations.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the search results. Use this exact message to inform the user. Examples: "Found exactly one matching Meeting", "Found 3 Meeting records", "No Meetings found matching the criteria".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Meeting__c" for Meeting find operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Ambiguous Result'
            description='True if multiple records were found in the search. When true, present all records to the user and ask for clarification using additional identifying fields like Subject, Meeting Date, Status, Account, or Contact to narrow down the selection.'
        )
        public Boolean ambiguous;
        
        @InvocableVariable(
            label='Total Matches'
            description='Number of Meeting records found in the search. Use this to inform the user: "Found X matching meetings" or "No meetings found matching your criteria".'
        )
        public Integer totalMatches;
        
        @InvocableVariable(
            label='More Results Available'
            description='True if the search returned the maximum number of results (searchLimit) but there are more matching records available. When true, suggest the user provide more specific search criteria or filters to narrow down the results.'
        )
        public Boolean moreResultsAvailable;
    }
    
    @InvocableMethod(
        label='Find Meetings'
        description='Searches for Meeting__c records using search term and/or filters. Returns Meeting records with related Account and Contact names. Supports filtering by Meeting_Status__c, Meeting_Date__c, Meeting_Type__c, and related objects.'
        category='CRM Actions'
    )
    public static List<Response> findMeetings(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Meeting__c';
            res.success = false;
            res.records = new List<Meeting__c>();
            res.totalMatches = 0;
            res.ambiguous = false;
            res.moreResultsAvailable = false;
            
            try {
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Meeting__c';
                actionReq.operation = 'find';
                actionReq.searchTerm = req.searchTerm;
                actionReq.filtersJson = req.filtersJson;
                actionReq.searchLimit = req.searchLimit;
                
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message != null ? actionRes.message : 'Search completed.';
                    res.ambiguous = actionRes.ambiguous != null ? actionRes.ambiguous : false;
                    res.totalMatches = actionRes.totalMatches != null ? actionRes.totalMatches : 0;
                    
                    if (actionRes.record != null) {
                        res.record = (Meeting__c) actionRes.record;
                        res.recordId = actionRes.recordId;
                        res.records = new List<Meeting__c>{ res.record };
                    } else if (actionRes.records != null && !actionRes.records.isEmpty()) {
                        res.records = new List<Meeting__c>();
                        for (SObject so : actionRes.records) {
                            res.records.add((Meeting__c) so);
                        }
                        if (res.records.size() == 1) {
                            res.record = res.records[0];
                            res.recordId = res.records[0].Id;
                        }
                    }
                    
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
                res.errorMessage = 'Error searching Meetings: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFMeetingFindAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}


