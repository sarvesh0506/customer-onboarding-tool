// Force redeploy comment v1
@RestResource(urlMapping='/onboarding/customers/*')
global with sharing class CustomerRestResource {
    
    @HttpGet
    global static void getCustomerOrList() {
        RestRequest req = RestContext.request;
        String uri = req.requestURI;
        String[] parts = uri.split('/');
        
        try {
            if (parts[parts.size() - 1].equalsIgnoreCase('customers')) {
                String status = req.params.get('status');
                Map<String, Object> filters = new Map<String, Object>();
                if (String.isNotBlank(status)) {
                    filters.put('status', status);
                }
                List<Customer__c> customers = CustomerService.listCustomers(filters);
                setResponse(200, customers);
            } else {
                Id customerId = parts[parts.size() - 1];
                Customer__c cust = CustomerService.getCustomer(customerId);
                setResponse(200, cust);
            }
        } catch (Exception e) {
            String msg = e.getMessage();
            String lowerMsg = msg.toLowerCase();
            if (lowerMsg.contains('not found') || lowerMsg.contains('list has no rows') || lowerMsg.contains('invalid id')) {
                setResponse(404, new Map<String, String>{ 'error' => 'Customer record not found' });
            } else {
                setResponse(400, new Map<String, String>{ 'error' => msg });
            }
        }
    }
    
    @HttpPost
    global static void createCustomer() {
        RestRequest req = RestContext.request;
        try {
            String body = req.requestBody.toString();
            Customer__c cust = (Customer__c) JSON.deserialize(body, Customer__c.class);
            Customer__c created = CustomerService.createCustomer(cust);
            setResponse(201, created);
        } catch (Exception e) {
            setResponse(400, new Map<String, String>{ 'error' => e.getMessage() });
        }
    }
    
    @HttpPatch
    global static void updateCustomer() {
        RestRequest req = RestContext.request;
        String uri = req.requestURI;
        String[] parts = uri.split('/');
        
        Boolean isStatusUpdate = parts[parts.size() - 1].equalsIgnoreCase('status');
        
        try {
            String body = req.requestBody.toString();
            if (isStatusUpdate) {
                Id customerId = parts[parts.size() - 2];
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(body);
                String newStatus = (String) data.get('status');
                String noteText = (String) data.get('note');
                
                CustomerService.updateOnboardingStatus(customerId, newStatus, noteText);
                
                Customer__c updated = CustomerService.getCustomer(customerId);
                setResponse(200, updated);
            } else {
                Id customerId = parts[parts.size() - 1];
                Customer__c cust = (Customer__c) JSON.deserialize(body, Customer__c.class);
                if (cust.Id == null) {
                    cust.Id = customerId;
                }
                Customer__c updated = CustomerService.updateCustomer(cust);
                setResponse(200, updated);
            }
        } catch (Exception e) {
            String msg = e.getMessage();
            String lowerMsg = msg.toLowerCase();
            if (lowerMsg.contains('not found') || lowerMsg.contains('list has no rows') || lowerMsg.contains('invalid id')) {
                setResponse(404, new Map<String, String>{ 'error' => 'Customer record not found' });
            } else {
                setResponse(400, new Map<String, String>{ 'error' => msg });
            }
        }
    }
    
    private static void setResponse(Integer statusCode, Object body) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(body));
    }
}
