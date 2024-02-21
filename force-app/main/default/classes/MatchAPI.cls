@RestResource(urlMapping='/matches/*')
global with sharing class MatchAPI {
    

    @HttpGet(urlMapping='/matches/team/*')
    global static List<Match__c> getMatchesByTeam() {
        RestRequest req = RestContext.request;
        String teamId = req.requestURI.substringBetween('/team/', '/tournament/');
        return [SELECT Id, Name, Tournament__r.Name, Team_1__r.Name, Team_2__r.Name, Team_2__r.Logo__c, Team_1__r.Logo__c, Match_Date__c
        FROM Match__c 
        WHERE (Team_1__c = :teamId OR Team_2__c = :teamId) AND (Approved__c=True) WITH SECURITY_ENFORCED];
    }
}