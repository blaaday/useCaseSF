@isTest
private class TournamentAPI_Test {

    @isTest
    static void testGetTournaments() {
        // Create test data
        Tournament__c testTournament1 = new Tournament__c(
            Name='Test Tournament 1',
            Status__c='Completed',
            Start_Date__c=Date.today().addDays(-30),
            End_Date__c=Date.today().addDays(-1),
            Approved__c=true
        );
        insert testTournament1;

        Tournament__c testTournament2 = new Tournament__c(
            Name='Test Tournament 2',
            Status__c='Completed',
            Start_Date__c=Date.today().addDays(-30),
            End_Date__c=Date.today().addDays(-1),
            Approved__c=false // Not approved, should not be returned
        );
        insert testTournament2;

        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/tournaments';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Tournament__c> tournaments = TournamentAPI.getTournaments();
        Test.stopTest();

        System.assertEquals(1, tournaments.size(), 'Only one tournament should be returned');
        System.assertEquals(testTournament1.Id, tournaments[0].Id, 'Tournament Ids are different.');
    }
}
