/**
 * Exception thrown when a relationship lookup (Account, Contact, Opportunity) finds multiple matches
 * Contains candidate details for the agent to present to the user for disambiguation
 */
public class AmbiguousRelationshipException extends Exception {
    public String relationshipType; // 'Account', 'Contact', 'Opportunity'
    public String searchCriteria; // What was searched for
    public List<Map<String, Object>> candidates; // Up to 5 candidate records
    
    public AmbiguousRelationshipException(String relType, String criteria, List<Map<String, Object>> candidateList) {
        this.relationshipType = relType;
        this.searchCriteria = criteria;
        this.candidates = candidateList;
        
        // Set exception message
        this.setMessage('Multiple ' + relType + ' records found matching "' + criteria + '". ' +
                       'Found ' + candidateList.size() + ' candidates. Please specify which one using additional details.');
    }
}




