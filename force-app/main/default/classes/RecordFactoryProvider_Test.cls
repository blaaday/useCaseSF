@isTest
private class RecordFactoryProvider_Test {
    
    @isTest
    static void testGetFactory() {
        // Test getting TournamentFactory
        RecordFactory tournamentFactory = RecordFactoryProvider.getFactory('Tournament');
        System.assertNotEquals(null, tournamentFactory, 'TournamentFactory should not be null');
        System.assertEquals(true, tournamentFactory instanceof TournamentFactory, 'Expected TournamentFactory instance');

        // Test getting GroupFactory
        RecordFactory groupFactory = RecordFactoryProvider.getFactory('Group');
        System.assertNotEquals(null, groupFactory, 'GroupFactory should not be null');
        System.assertEquals(true, groupFactory instanceof GroupFactory, 'Expected GroupFactory instance');

        // Test getting TournamentTeamFactory
        RecordFactory tournamentTeamFactory = RecordFactoryProvider.getFactory('TournamentTeam');
        System.assertNotEquals(null, tournamentTeamFactory, 'TournamentTeamFactory should not be null');
        System.assertEquals(true, tournamentTeamFactory instanceof TournamentTeamFactory, 'Expected TournamentTeamFactory instance');

        // Test getting MatchFactory
        RecordFactory matchFactory = RecordFactoryProvider.getFactory('Match');
        System.assertNotEquals(null, matchFactory, 'MatchFactory should not be null');
        System.assertEquals(true, matchFactory instanceof MatchFactory, 'Expected MatchFactory instance');

        // Test getting null for unsupported object type
        RecordFactory unsupportedFactory = RecordFactoryProvider.getFactory('Unsupported');
        System.assertEquals(null, unsupportedFactory, 'Unsupported factory should return null');
    }
}