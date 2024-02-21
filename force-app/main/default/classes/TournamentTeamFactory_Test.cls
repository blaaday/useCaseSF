@isTest
private class TournamentTeamFactory_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for Tournament, Team, and Group
        Tournament__c testTournament = new Tournament__c(
            Name='Test Tournament',
            Status__c='Completed',
            Start_Date__c=Date.today().addDays(-30),
            End_Date__c=Date.today().addDays(-1),
            Approved__c=true
        );
        insert testTournament;

        Team__c testTeam = new Team__c(
            Name='Morocco',
            Country__c='Morocco'
        );
        insert testTeam;

        Group__c testGroup = new Group__c(
            Tournament__c=testTournament.Id,
            Name='Test Group',
            Approved__c=true
        );
        insert testGroup;
    }

    @isTest
    static void testCreateRecord() {
        // Prepare test data
        List<Map<String, Object>> testData = new List<Map<String, Object>>();
        Map<String, Object> record1 = new Map<String, Object>{
            'Tournament__c' => [SELECT Id FROM Tournament__c LIMIT 1].Id,
            'Team__c' => [SELECT Id FROM Team__c LIMIT 1].Id,
            'Group__c' => [SELECT Id FROM Group__c LIMIT 1].Id,
            'Status__c' => 'Playing'
        };
        testData.add(record1);

        // Call the createRecord method
        TournamentTeamFactory factory = new TournamentTeamFactory();
        Test.startTest();
        List<Tournament_Team__c> createdRecords = factory.createRecord(testData);
        Test.stopTest();

        // Verify the records were created
        System.assertEquals(1, createdRecords.size());
        Tournament_Team__c createdRecord = createdRecords[0];
        System.assertNotEquals(null, createdRecord.Id);
        System.assertEquals(record1.get('Tournament__c'), createdRecord.Tournament__c);
        System.assertEquals(record1.get('Team__c'), createdRecord.Team__c);
        System.assertEquals(record1.get('Group__c'), createdRecord.Group__c);
        System.assertEquals(record1.get('Status__c'), createdRecord.Status__c);
        System.assertEquals(true, createdRecord.Approved__c);
    }
}
