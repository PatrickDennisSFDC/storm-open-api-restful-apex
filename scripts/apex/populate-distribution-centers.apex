// Query all existing Customer Order Line Items
List<Customer_Order_Line_Item__c> lineItems = [
    SELECT Id, Name, Product_Name__c, Distribution_Center__c
    FROM Customer_Order_Line_Item__c
    LIMIT 200
];

System.debug('Found ' + lineItems.size() + ' line items to update');

// Sample Med Tech/Pharma Distribution Centers
List<String> distributionCenters = new List<String>{
    'McKesson Distribution Center - Memphis, TN',
    'Cardinal Health DC - Columbus, OH',
    'AmerisourceBergen DC - Pittston, PA',
    'McKesson Specialty - Dallas, TX',
    'Cardinal Health Specialty - Las Vegas, NV',
    'Morris & Dickson - Shreveport, LA',
    'HD Smith - Springfield, IL',
    'Rochester Drug Cooperative - Rochester, NY',
    'Kinray - Queens, NY',
    'Smith Drug Company - Spartanburg, SC',
    'McKesson West Coast DC - Livermore, CA',
    'Cardinal Health Southeast - Atlanta, GA',
    'AmerisourceBergen Midwest - Chicago, IL',
    'McKesson Northeast - Windsor, CT',
    'FFF Enterprises - Temecula, CA'
};

// Update each line item with a distribution center
Integer dcIndex = 0;

for (Customer_Order_Line_Item__c item : lineItems) {
    item.Distribution_Center__c = distributionCenters[Math.mod(dcIndex, distributionCenters.size())];
    dcIndex++;
    
    System.debug('Updating ' + item.Name + ': DC=' + item.Distribution_Center__c);
}

// Update records
try {
    update lineItems;
    System.debug('✅ SUCCESS: Updated ' + lineItems.size() + ' line items with distribution center data');
    
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

