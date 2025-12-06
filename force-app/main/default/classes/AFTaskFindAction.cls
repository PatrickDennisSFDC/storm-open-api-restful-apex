/**
 * AF Task Find Action
 * Invocable action for finding/searching Task records
 * Designed for Agentforce AI agents
 */
public with sharing class AFTaskFindAction {
    
    /**
     * Request input for find operation
     */
    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Text to search for in Task fields (Subject, Description, Status). The search will find Tasks where any of these fields contain the search term. Example: "Follow up" or "John Smith".'
            required=false
        )
        public String searchTerm;
        
        @InvocableVariable(
            label='Filters JSON'
            description='JSON string of exact-match filters. Can be single object {"fieldApiName":"Status","value":"Not Started"} or array [{"fieldApiName":"Status","value":"In Progress"},{"fieldApiName":"Priority","value":"High"}]. Common filter fields: Status, Priority, ActivityDate. Special filters: "OpenTasksOnly":"true" (default), "ActivityDateFrom":"2024-12-01", "ActivityDateTo":"2024-12-31".'
            required=false
        )
        public String filtersJson;
        
        @InvocableVariable(
            label='Search Limit'
            description='Maximum number of records to return (default: 5, max: 20). If more records match, the response will indicate how many total matches were found.'
            required=false
        )
        public Integer searchLimit;
        
        @InvocableVariable(
            label='Include Completed Tasks'
            description='Set to true to include completed/closed tasks in search results. Default (false): Only returns open tasks (Status != "Completed"). When user asks "my tasks" or "tasks for tomorrow", only show open tasks unless they specifically ask for completed ones.'
            required=false
        )
        public Boolean includeCompletedTasks;
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
            description='The single Task record found (when exactly one match). Use the record.Id field from this record for follow-up operations like updateTask or deleteTask. This is null when multiple or zero records are found.'
        )
        public Task record;
        
        @InvocableVariable(
            label='Records'
            description='List of Task records found with related Account and Contact names populated. Use record.Id from each record for subsequent operations. Present task details to user including Subject, Status, Priority, due date, and who/what it relates to.'
        )
        public List<Task> records;
        
        @InvocableVariable(
            label='Record ID'
            description='The Salesforce ID of the record (18-character format like "00Txx000003DGbYAAW"). Only populated when exactly one record is found. Use this ID for updateTask, deleteTask, or readTask operations.'
        )
        public Id recordId;
        
        @InvocableVariable(
            label='Message'
            description='Human-readable message describing the search results. Use this exact message to inform the user. Examples: "Found exactly one matching Task", "Found 3 open tasks", "No open tasks found matching the criteria".'
        )
        public String message;
        
        @InvocableVariable(
            label='Error Message'
            description='If success is false, this contains a user-friendly error message to relay directly to the user.'
        )
        public String errorMessage;
        
        @InvocableVariable(
            label='Object Type'
            description='The Salesforce object type, always "Task" for Task find operations. Useful for agent context and logging.'
        )
        public String objectType;
        
        @InvocableVariable(
            label='Ambiguous Result'
            description='True if multiple records were found in the search. When true, present all tasks to the user with their details (Subject, Status, Priority, due date, related Account/Contact) and ask if they want to narrow down the search.'
        )
        public Boolean ambiguous;
        
        @InvocableVariable(
            label='Total Matches'
            description='Number of Task records found in the search. Use this to inform the user: "Found X matching tasks" or "No tasks found matching your criteria".'
        )
        public Integer totalMatches;
        
        @InvocableVariable(
            label='More Results Available'
            description='True if the search returned the maximum number of results (searchLimit) but there are more matching records available. When true, suggest the user provide more specific search criteria (date range, status, related account/contact).'
        )
        public Boolean moreResultsAvailable;
    }
    
    /**
     * Find/Search Tasks
     */
    @InvocableMethod(
        label='Find Tasks'
        description='Searches for Task records using search term and/or filters. By default, returns only open tasks (Status != "Completed"). Set includeCompletedTasks=true to include completed tasks. Returns Task records with related Account and Contact names for context. Supports filtering by Status, Priority, ActivityDate (due date), and related objects. Example queries: "my tasks", "tasks due tomorrow", "tasks for Acme Corp", "completed tasks".'
        category='CRM Actions'
    )
    public static List<Response> findTasks(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.objectType = 'Task';
            res.success = false;
            res.records = new List<Task>();
            res.totalMatches = 0;
            res.ambiguous = false;
            res.moreResultsAvailable = false;
            
            try {
                // Build request for AFUniversalCrmRecordAction
                AFUniversalCrmRecordAction.Request actionReq = new AFUniversalCrmRecordAction.Request();
                actionReq.objectApiName = 'Task';
                actionReq.operation = 'find';
                actionReq.searchTerm = req.searchTerm;
                actionReq.searchLimit = req.searchLimit;
                
                // Add open tasks filter by default unless includeCompletedTasks is true
                String filtersJson = req.filtersJson;
                if (req.includeCompletedTasks == null || req.includeCompletedTasks == false) {
                    // Add filter to exclude completed tasks
                    if (String.isBlank(filtersJson)) {
                        filtersJson = '{"_openTasksOnly":"true"}';
                    } else {
                        // Parse and add to existing filters
                        Object parsed = JSON.deserializeUntyped(filtersJson);
                        if (parsed instanceof Map<String, Object>) {
                            Map<String, Object> filterMap = (Map<String, Object>) parsed;
                            filterMap.put('_openTasksOnly', 'true');
                            filtersJson = JSON.serialize(filterMap);
                        } else if (parsed instanceof List<Object>) {
                            List<Object> filterList = (List<Object>) parsed;
                            filterList.add(new Map<String, Object>{'_openTasksOnly' => 'true'});
                            filtersJson = JSON.serialize(filterList);
                        }
                    }
                }
                
                actionReq.filtersJson = filtersJson;
                
                // Call shared business logic
                AFUniversalCrmRecordAction.Response actionRes = AFUniversalCrmRecordAction.processRequest(actionReq);
                
                // Convert response
                if (actionRes.success) {
                    res.success = true;
                    res.message = actionRes.message != null ? actionRes.message : 'Search completed.';
                    res.ambiguous = actionRes.ambiguous != null ? actionRes.ambiguous : false;
                    res.totalMatches = actionRes.totalMatches != null ? actionRes.totalMatches : 0;
                    
                    if (actionRes.record != null) {
                        res.record = (Task) actionRes.record;
                        res.recordId = actionRes.recordId;
                        res.records = new List<Task>{ res.record };
                    } else if (actionRes.records != null && !actionRes.records.isEmpty()) {
                        res.records = new List<Task>();
                        for (SObject so : actionRes.records) {
                            res.records.add((Task) so);
                        }
                        if (res.records.size() == 1) {
                            res.record = res.records[0];
                            res.recordId = res.records[0].Id;
                        }
                    }
                    
                    // Check if more results available (if we hit the limit)
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
                res.errorMessage = 'Error searching Tasks: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'AFTaskFindAction: Exception - ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}




