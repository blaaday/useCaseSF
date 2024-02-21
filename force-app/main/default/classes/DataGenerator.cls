public with sharing class DataGenerator {

    public static void setupTournament() {
        // Initialize all needed factory classes
        RecordFactory tournamentFactory = RecordFactoryProvider.getFactory('Tournament');
        RecordFactory groupFactory = RecordFactoryProvider.getFactory('Group');
        RecordFactory tournamentTeamsFactory = RecordFactoryProvider.getFactory('TournamentTeam');
        RecordFactory matchFactory = RecordFactoryProvider.getFactory('Match');

        // Start setting up the tournament by creating the tournament.
        List<Map<String, Object>> tournaments = generateTournaments(1);
        List<Tournament__c> generatedTournaments = tournamentFactory.createRecord(tournaments);
        Nebula.Logger.info('Generated ' + generatedTournaments.size() + ' Tournament(s).');

        // Next we need to create groups of this tournament.
        List<Map<String, Object>> groups = generateGroups(generatedTournaments);
        List<Group__c> generatedGroups = groupFactory.createRecord(groups);
        Nebula.Logger.info('Generated ' + generatedGroups.size() + ' Group(s).');

         // Before adding teams we need to process the list of groups to group each list of groups on their respective tournament.
        Map<Id, List<Group__c>> groupsByTournament = getGroupsByTournaments(generatedGroups);
       
        // Next we need to Team to these groups, so we need to add Tournament Teams.
        List<Map<String, Object>> tournamentTeams = generateTournamentTeams(groupsByTournament);
        List<Tournament_Team__c> generatedTournamentTeams = tournamentTeamsFactory.createRecord(tournamentTeams);
        Nebula.Logger.info('Generated ' + generatedTournamentTeams.size() + ' Tournament Team(s).');

        // Again before generating any match we need a list of teams by Group.
        Map<Id, List<Id>> teamsByGroup = getTeamsByGroup(generatedTournamentTeams);

        List<Map<String, Object>> generatedGroupStageMatches = generateGroupStageMatches(teamsByGroup, generatedGroups);
        matchFactory.createRecord(generatedGroupStageMatches);
        Nebula.Logger.info('Generated ' + generatedGroupStageMatches.size() + ' Match(s).');

        List<Map<String, Object>> generatedGroupOf16Matches = generateKnockOutMatches(generatedTournaments, 'Round of 16');
        Nebula.Logger.info('Generated ' + generatedGroupOf16Matches.size() + ' Round of 16 Matches.');
        matchFactory.createRecord(generatedGroupOf16Matches);

        List<Map<String, Object>> generatedQuarterFinalsMatches = generateKnockOutMatches(generatedTournaments, 'Quarter Finals');
        Nebula.Logger.info('Generated ' + generatedQuarterFinalsMatches.size() + ' Quarter Finals Matches.');
        matchFactory.createRecord(generatedQuarterFinalsMatches);


        List<Map<String, Object>> generatedSemiFinalsMatches = generateKnockOutMatches(generatedTournaments, 'Semi Finals');
        matchFactory.createRecord(generatedSemiFinalsMatches);
        Nebula.Logger.info('Generated ' + generatedSemiFinalsMatches.size() + ' Semi Finals Matches.');

        List<Map<String, Object>> generated3rdPlaceMatch = generateKnockOutMatches(generatedTournaments, '3rd Place');
        matchFactory.createRecord(generated3rdPlaceMatch);
        Nebula.Logger.info('Generated ' + generated3rdPlaceMatch.size() + ' 3rd Place Match.');

        List<Map<String, Object>> generatedFinalMatch = generateKnockOutMatches(generatedTournaments, 'Final');
        matchFactory.createRecord(generatedFinalMatch);
        Nebula.Logger.info('Generated ' + generatedFinalMatch.size() + ' Final Matche.');

    }
    
    public static List<Map<String, Object>> generateTournaments(Integer numberOfRecords) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for(Integer i = 0; i<numberOfRecords; i++) {
            Date endDate = Date.today().addDays(-Math.mod(Math.abs(Crypto.getRandomInteger()), 30)); // End date is a random date up to 30 days in the past
            Date startDate = endDate.addMonths(-1); // Start date is one month before the end date
            Map<String, Object> record = new Map<String, Object>{
                'Name' => 'Random Generated Tournament ' + Math.mod(Math.abs(Crypto.getRandomInteger()), 1000) + 1, // Random number between 1 and 1000
                'Start_Date__c' => startDate,
                'End_Date__c' => endDate,
                'Status__c' => 'Completed'
            };
            records.add(record);
        }
        return records;
    }

    public static List<Map<String, Object>> generateGroups(List<Tournament__c> tournaments) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (Tournament__c tournament : tournaments) {
            for (Integer i = 0; i < 8; i++) {
                Map<String, Object> record = new Map<String, Object>{
                    'Name' => 'Group ' + String.valueOf((String)('A' + i)),
                    'Tournament__c' => tournament.Id
                };
                records.add(record);
            }
        }
        return records;
    }

    public static List<Map<String, Object>> generateTournamentTeams(Map<Id, List<Group__c>> groupsPerTournament) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        List<Team__c> teams = [SELECT Id FROM Team__c WITH SECURITY_ENFORCED];
        shuffleList(teams);

        for(List<Group__c> groups: groupsPerTournament.values()){
            Integer teamIndex = 0;
            for(Group__c grp: groups) {
                for (Integer i = 0; i < 4; i++) {
                    Map<String, Object> record = new Map<String, Object>{
                        'Tournament__c' => grp.Tournament__c,
                        'Group__c' => grp.Id,
                        'Team__c' => teams[teamIndex].Id,
                        'Status__c'=> 'Playing'
                    };
                    records.add(record);
                    teamIndex++;
                }
            }
        }
        return records;
    }

    public static List<Map<String, Object>> generateGroupStageMatches(Map<Id, List<Id>> teamsByGroup, List<Group__c> groups) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        // This is a placeholder, just to insert matches and bypass the time validations on triggers
        Datetime matchDates = (Datetime) generateRandomPastDate(10, 19);
        for(Group__c grp : groups) {
            List<Id> teams = teamsByGroup.get(grp.Id); 
            for (Integer i = 0; i < teams.size() - 1; i++) {
                for (Integer j = i + 1; j < teams.size(); j++) {
                    Map<String, Object> record = new Map<String, Object>{
                        'Tournament__c'=> grp.Tournament__c,
                        'Match_Date__c'=> matchDates,
                        'Group__c'=> grp.Id,
                        'Round__c'=> 'Group Stage',
                        'Team_1__c'=> teams[i],
                        'Team_2__c'=> teams[j],
                        'Team_1_Score__c'=> generateRandomScore(),
                        'Team_2_Score__c'=> generateRandomScore()
                    };
                    records.add(record);
                }
            }
        }
        return records;
    }

    public static List<Map<String, Object>> generateKnockOutMatches(List<Tournament__c> tournaments, String round) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        String tournamentStatus = round != '3rd Place' ? 'Playing' : 'Qualified 3rd';
        List<Tournament_Team__c> teams = [SELECT Id, Tournament__c, Team__c from Tournament_Team__c WHERE Tournament__c IN :tournaments AND Status__c=:tournamentStatus WITH SECURITY_ENFORCED];
        for(Integer i = 0; i < teams.size()/2; i++) {
            Integer scoreTeam1 = generateRandomScore();
            Integer scoreTeam2 = generateRandomScore();
            Map<String, Object> record = new Map<String, Object>{
                'Tournament__c'=> teams[i].Tournament__c,
                'Match_Date__c'=> (Datetime) generateRandomPastDate(teams.size(), 15),
                'Round__c'=> round,
                'Team_1__c'=> teams[i].Team__c,
                'Team_2__c'=> teams[teams.size() - i - 1].Team__c,
                'Team_1_Score__c'=> scoreTeam1,
                'Team_2_Score__c'=> scoreTeam2 == scoreTeam1 ? scoreTeam1 + 1 : scoreTeam2
            };
            records.add(record);
        }
        return records;
    }

    public static void generateTeams(Integer numberOfTeams) {
        List<Team__c> teams = new List<Team__c>();
        Schema.DescribeFieldResult fieldResult = Team__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Integer i = 0; i < numberOfTeams; i++) {
            Team__c team = new Team__c(
                Name=picklistValues[i].getValue(),
                Country__c=picklistValues[i].getValue()
            );
            teams.add(team);
        }
        if(teams.size() > 0 && Schema.sObjectType.Team__c.isCreateable()) {
            insert teams;
        }
    }

    private static Map<Id, List<Id>> getTeamsByGroup(List<Tournament_Team__c> teams) {
        Map<Id, List<Id>> teamsByGroup = new Map<Id, List<Id>>();
        for(Tournament_Team__c team: teams) {
            if(!teamsByGroup.containsKey(team.Group__c)) {
                teamsByGroup.put(team.Group__c, new List<Id>());
            } 
            teamsByGroup.get(team.Group__c).add(team.Team__c);
        }
        return teamsByGroup;
    }

    private static Map<Id, List<Group__c>> getGroupsByTournaments(List<Group__c> generatedGroups) {
        Map<Id, List<Group__c>> groupsByTournament = new Map<Id, List<Group__c>>();
        // Before adding teams we need to process the list of groups to group each list of groups on their respective tournament.
        for(Group__c grp: generatedGroups) {
            if(!groupsByTournament.containsKey(grp.Tournament__c)) {
                groupsByTournament.put(grp.Tournament__c, new List<Group__c>());
            } 
            groupsByTournament.get(grp.Tournament__c).add(grp);
        }
        return groupsByTournament;
    }
    

    private static void shuffleList(List<Team__c> teams) {
        Integer size = teams.size();
        for (Integer i = size - 1; i > 0; i--) {
            Integer j = Math.mod(Math.abs(Crypto.getRandomInteger()), (i + 1));
            Team__c temp = teams[i];
            teams[i] = teams[j];
            teams[j] = temp;
        }
    }

    private static Datetime generateRandomPastDate(Integer t1, Integer t2) {
        // Generate a random number of days between start and end
        Integer randomDays = Math.mod(Math.abs(Crypto.getRandomInteger()), t2) + t1;
        // Generate a random number of hours between 0 and 23
        Integer randomHours = Math.mod(Math.abs(Crypto.getRandomInteger()), 24);
        // Subtract the random number of days and hours from now to get a datetime in the past
        return DateTime.now().addDays(-randomDays).addHours(-randomHours);
    }

    private static Integer generateRandomScore() {
        // Generate a random score between 0 and 10
        return Math.mod(Math.abs(Crypto.getRandomInteger()), 5);
    }
}