@RestResource(urlMapping='/tournaments/*')
global with sharing class TournamentAPI {
    @HttpGet
    global static List<Tournament__c> getTournaments() {
        return [SELECT Id, Name FROM Tournament__c WHERE Approved__c=True WITH SECURITY_ENFORCED];
    }
}