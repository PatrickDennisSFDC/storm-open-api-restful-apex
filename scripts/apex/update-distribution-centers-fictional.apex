// Query all existing Customer Order Line Items
List<Customer_Order_Line_Item__c> lineItems = [
    SELECT Id, Name, Product_Name__c, Distribution_Center__c
    FROM Customer_Order_Line_Item__c
    LIMIT 200
];

System.debug('Found ' + lineItems.size() + ' line items to update');

// Fictional, nondescript Distribution Centers
List<String> distributionCenters = new List<String>{
    'Northeast Regional Distribution Center - Boston, MA',
    'Mid-Atlantic Distribution Facility - Philadelphia, PA',
    'Southeast Regional Warehouse - Atlanta, GA',
    'Midwest Central Distribution Hub - Chicago, IL',
    'Southwest Regional Facility - Phoenix, AZ',
    'Mountain West Distribution Center - Denver, CO',
    'Pacific Northwest Warehouse - Seattle, WA',
    'California Central Distribution Hub - Sacramento, CA',
    'Southern Plains Distribution Facility - Dallas, TX',
    'Great Lakes Regional Center - Detroit, MI',
    'Gulf Coast Distribution Warehouse - Houston, TX',
    'Rocky Mountain Regional Facility - Salt Lake City, UT',
    'Tri-State Distribution Hub - Cincinnati, OH',
    'New England Distribution Center - Hartford, CT',
    'South Central Regional Warehouse - Nashville, TN'
};

// Update each line item with a fictional distribution center
Integer dcIndex = 0;

for (Customer_Order_Line_Item__c item : lineItems) {
    item.Distribution_Center__c = distributionCenters[Math.mod(dcIndex, distributionCenters.size())];
    dcIndex++;
    
    System.debug('Updating ' + item.Name + ': DC=' + item.Distribution_Center__c);
}

// Update records
try {
    update lineItems;
    System.debug('✅ SUCCESS: Updated ' + lineItems.size() + ' line items with fictional distribution center data');
    
    // Show summary
    Map<String, Integer> dcCounts = new Map<String, Integer>();
    for (Customer_Order_Line_Item__c item : lineItems) {
        Integer count = dcCounts.containsKey(item.Distribution_Center__c) ? dcCounts.get(item.Distribution_Center__c) : 0;
        dcCounts.put(item.Distribution_Center__c, count + 1);
    }
    
    System.debug('📊 Distribution Center Summary:');
    for (String dc : dcCounts.keySet()) {
        System.debug('  - ' + dc + ': ' + dcCounts.get(dc) + ' items');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

