@RestResource(urlMapping='/onboarding/tasks/*')
global with sharing class TaskRestResource {
    
    @HttpPost
    global static void createTask() {
        RestRequest req = RestContext.request;
        try {
            String body = req.requestBody.toString();
            Onboarding_Task__c task = (Onboarding_Task__c) JSON.deserialize(body, Onboarding_Task__c.class);
            Onboarding_Task__c created = TaskService.createTask(task);
            setResponse(201, created);
        } catch (Exception e) {
            setResponse(400, new Map<String, String>{ 'error' => e.getMessage() });
        }
    }
    
    @HttpPatch
    global static void updateTask() {
        RestRequest req = RestContext.request;
        String uri = req.requestURI;
        String[] parts = uri.split('/');
        
        try {
            Id taskId = parts[parts.size() - 1];
            String body = req.requestBody.toString();
            Onboarding_Task__c task = (Onboarding_Task__c) JSON.deserialize(body, Onboarding_Task__c.class);
            if (task.Id == null) {
                task.Id = taskId;
            }
            Onboarding_Task__c updated = TaskService.updateTask(task);
            setResponse(200, updated);
        } catch (Exception e) {
            String msg = e.getMessage();
            String lowerMsg = msg.toLowerCase();
            if (lowerMsg.contains('not found') || lowerMsg.contains('list has no rows') || lowerMsg.contains('invalid id')) {
                setResponse(404, new Map<String, String>{ 'error' => 'Task record not found' });
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
