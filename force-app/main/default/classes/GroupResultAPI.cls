@RestResource(urlMapping='/groupResults/*')
global with sharing class GroupResultAPI {
    
    @HttpGet
    global static List<Group_Result__c> getGroupResults() {
        RestRequest req = RestContext.request;
        String tournamentId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        return [SELECT Id, Name FROM Group_Result__c WHERE Tournament__c = :tournamentId];
    }
}