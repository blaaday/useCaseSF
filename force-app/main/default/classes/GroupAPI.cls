@RestResource(urlMapping='/groups/*')
global with sharing class GroupAPI {
    
    @HttpGet
    global static List<Group__c> getGroupsByTournament() {
        RestRequest req = RestContext.request;
        String tournamentId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        return [SELECT Id, Name FROM Group__c WHERE Tournament__c = :tournamentId AND Approved__c=True];
    }
}