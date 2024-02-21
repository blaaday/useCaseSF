public with sharing class MatchController {
    
    private static final List<String> Tournament_Results = new List<String>{
        '2nd Place',
        '3rd Place',
        'Winner'
    };

    @AuraEnabled(cacheable=true)
    public static List<Match__c> getMatchesByTeam(String teamId) {
        return [SELECT Id, Name, Tournament__c, Tournament__r.Name, Team_1__r.Name, Team_2__r.Name, Team_2__r.Logo__c, Team_1__r.Logo__c, Match_Date__c, 
        Team_1_Score__c, Team_2_Score__c, Round__c
                FROM Match__c 
                WHERE (Team_1__c = :teamId OR Team_2__c = :teamId) AND (Approved__c=True) WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<Tournament_Team__c> getTeamAchievements(String teamId) {
        return [SELECT Id, Name, Status__c, Tournament__r.Name, Tournament__c
                FROM Tournament_Team__c 
                WHERE (Team__c =:teamId) AND (Status__c IN :Tournament_Results)  AND (Approved__c=True) WITH SECURITY_ENFORCED];
    }

}