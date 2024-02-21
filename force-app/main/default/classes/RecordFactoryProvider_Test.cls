@isTest
private class RecordFactoryProvider_Test {
    
    @isTest
    static void testGetFactory() {
        // Test getting TournamentFactory
        RecordFactory tournamentFactory = RecordFactoryProvider.getFactory('Tournament');
        System.assertNotEquals(null, tournamentFactory);
        System.assert(tournamentFactory instanceof TournamentFactory);
        
        // Test getting GroupFactory
        RecordFactory groupFactory = RecordFactoryProvider.getFactory('Group');
        System.assertNotEquals(null, groupFactory);
        System.assert(groupFactory instanceof GroupFactory);
        
        // Test getting TournamentTeamFactory
        RecordFactory tournamentTeamFactory = RecordFactoryProvider.getFactory('TournamentTeam');
        System.assertNotEquals(null, tournamentTeamFactory);
        System.assert(tournamentTeamFactory instanceof TournamentTeamFactory);
        
        // Test getting MatchFactory
        RecordFactory matchFactory = RecordFactoryProvider.getFactory('Match');
        System.assertNotEquals(null, matchFactory);
        System.assert(matchFactory instanceof MatchFactory);
        
        // Test getting null for unsupported object type
        RecordFactory unsupportedFactory = RecordFactoryProvider.getFactory('Unsupported');
        System.assertEquals(null, unsupportedFactory);
    }
}
