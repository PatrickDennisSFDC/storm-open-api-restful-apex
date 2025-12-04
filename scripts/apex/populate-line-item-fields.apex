// Query all existing Customer Order Line Items
List<Customer_Order_Line_Item__c> lineItems = [
    SELECT Id, Name, Product_Name__c, Status__c, Shipping_Address__c
    FROM Customer_Order_Line_Item__c
    LIMIT 200
];

System.debug('Found ' + lineItems.size() + ' line items to update');

// Sample statuses with weights (more common statuses appear more frequently)
List<String> statuses = new List<String>{
    'Pending', 'Pending', 'Pending',  // 30%
    'In Progress', 'In Progress',      // 20%
    'Shipped', 'Shipped', 'Shipped',   // 30%
    'Delivered', 'Delivered',          // 20%
    'Backordered'                      // 10%
};

// Sample shipping addresses for Med Tech/Pharma facilities
List<String> addresses = new List<String>{
    'Mayo Clinic Pharmacy\n200 First Street SW\nRochester, MN 55905',
    'Cleveland Clinic Hospital\n9500 Euclid Avenue\nCleveland, OH 44195',
    'Johns Hopkins Hospital\n1800 Orleans Street\nBaltimore, MD 21287',
    'Massachusetts General Hospital\n55 Fruit Street\nBoston, MA 02114',
    'UCSF Medical Center\n505 Parnassus Avenue\nSan Francisco, CA 94143',
    'NYU Langone Health\n550 First Avenue\nNew York, NY 10016',
    'Stanford Health Care\n300 Pasteur Drive\nStanford, CA 94305',
    'UCLA Medical Center\n757 Westwood Plaza\nLos Angeles, CA 90095',
    'Northwestern Memorial Hospital\n251 E Huron Street\nChicago, IL 60611',
    'Duke University Hospital\n2301 Erwin Road\nDurham, NC 27710',
    'University of Washington Medical Center\n1959 NE Pacific Street\nSeattle, WA 98195',
    'Emory University Hospital\n1364 Clifton Road NE\nAtlanta, GA 30322',
    'Barnes-Jewish Hospital\n1 Barnes Jewish Hospital Plaza\nSt. Louis, MO 63110',
    'UPMC Presbyterian\n200 Lothrop Street\nPittsburgh, PA 15213',
    'Cedars-Sinai Medical Center\n8700 Beverly Boulevard\nLos Angeles, CA 90048'
};

// Update each line item with random sample data
Integer statusIndex = 0;
Integer addressIndex = 0;

for (Customer_Order_Line_Item__c item : lineItems) {
    // Assign status (cycle through with some randomness)
    item.Status__c = statuses[Math.mod(statusIndex, statuses.size())];
    statusIndex++;
    
    // Assign shipping address (cycle through addresses)
    item.Shipping_Address__c = addresses[Math.mod(addressIndex, addresses.size())];
    addressIndex++;
    
    System.debug('Updating ' + item.Name + ': Status=' + item.Status__c + ', Address=' + item.Shipping_Address__c.split('\n')[0]);
}

// Update records
try {
    update lineItems;
    System.debug('✅ SUCCESS: Updated ' + lineItems.size() + ' line items with sample data');
    
    // Show summary of statuses
    Map<String, Integer> statusCounts = new Map<String, Integer>();
    for (Customer_Order_Line_Item__c item : lineItems) {
        Integer count = statusCounts.containsKey(item.Status__c) ? statusCounts.get(item.Status__c) : 0;
        statusCounts.put(item.Status__c, count + 1);
    }
    
    System.debug('📊 Status Distribution:');
    for (String status : statusCounts.keySet()) {
        System.debug('  - ' + status + ': ' + statusCounts.get(status) + ' items');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

