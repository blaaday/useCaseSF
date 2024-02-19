public class RecordFactoryProvider {
    public static RecordFactory getFactory(String objectType) {

        switch on objectType {
            when 'Tournament' {
                return new TournamentFactory();
            }
            when 'Group' {
                return new GroupFactory();
            }
            when 'TournamentTeam' {
                return new TournamentTeamFactory();
            }
            when 'Match' {
                return new MatchFactory();
            } 
            when else {
                return null;
            }
        }
    }
}