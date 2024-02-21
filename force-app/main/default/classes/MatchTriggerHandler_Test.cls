@IsTest
private class MatchTriggerHandler_Test {

    @IsTest
    static void testBeforeInsert() {
        Test.startTest();
        List<Match__c> newMatches = new List<Match__c>();
        DataGenerator.generateTeams(32);
        DataGenerator.setupTournament();
        List<Tournament_Team__c> tournamentTeams = [SELECT Id FROM Tournament_Team__c];
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Tournament__c> tournament = [SELECT Id FROM Tournament__c];
        List<Tournament_Team__c> winner = [SELECT Id FROM Tournament_Team__c WHERE Status__c='Winner'];
        System.assertEquals(1, winner.size());
        System.assertEquals(8, groups.size());
        System.assertEquals(32, tournamentTeams.size());
        System.assertEquals(1, tournament.size());
        Test.stopTest();
    }
}
