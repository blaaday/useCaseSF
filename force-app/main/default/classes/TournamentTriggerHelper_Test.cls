@isTest
private class TournamentTriggerHelper_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for Tournament
        Tournament__c testTournament = new Tournament__c(
            Name='Test Tournament',
            Status__c='Completed',
            Start_Date__c= (Date) Date.today().addDays(-30),
            End_Date__c= (Date) Date.today().addDays(-1),
            Approved__c=True
        );
        insert testTournament;

        // Create test data for Group
        Group__c testGroup = new Group__c(
            Tournament__c=testTournament.Id,
            Name='Group T',
            Approved__c=True
        );
        insert testGroup;

        // Create test data for Team
        Team__c testTeam = new Team__c(
            Name='Morocco',
            Country__c='Morocco'
        );
        insert testTeam;

        // Create test data for Tournament_Team__c
        Tournament_Team__c testTournamentTeam = new Tournament_Team__c(
            Group__c = testGroup.Id,
            Tournament__c = testTournament.Id,
            Team__c = testTeam.Id
        );
        insert testTournamentTeam;
    }

    @isTest
    static void testBeforeInsert() {
        Test.startTest();
        Id tournamentId = [SELECT Id FROM Tournament__c LIMIT 1][0].Id;
        Id groupId = [SELECT Id FROM Group__c LIMIT 1][0].Id;
        Id teamId = [SELECT Id FROM Team__c LIMIT 1][0].Id;
        // Query for Group_Result__c records
        List<Group_Result__c> groupResults = [SELECT Id, Group__c, Tournament__c, Team__c, Approved__c FROM Group_Result__c];
        // Assert that Group_Result__c records were created
        System.assertEquals(1, groupResults.size(), 'We should have only one group result');
        Group_Result__c groupResult = groupResults[0];
        System.assertEquals(groupId, groupResult.Group__c, 'We should have the same Group');
        System.assertEquals(tournamentId, groupResult.Tournament__c, 'We should have the same tournament');
        System.assertEquals(teamId, groupResult.Team__c, 'We should have the same Team');
        System.assertEquals(true, groupResult.Approved__c, 'Group Result should be approved');
        Test.stopTest();
    }
}