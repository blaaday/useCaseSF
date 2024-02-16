public with sharing class MatchTriggerHandler extends TriggerHandler {
    
    public MatchTriggerHandler() {
        this.setMaxLoopCount(1);
    } 

    public override void beforeInsert() {
        List<Match__c> newMatches = (List<Match__c>) Trigger.new;
        Set<Id> tournaments = new Set<Id>();
        Set<Id> teams = new Set<Id>();
        Set<Id> groups = new Set<Id>();
        for (Match__c match : newMatches) {
            tournaments.add(match.Tournament__c);
            teams.add(match.Team_1__c);teams.add(match.Team_2__c);
            groups.add(match.Group__c);
        }

        List<Match__c> oldMatches = [SELECT Id, Tournament__c, Group__c, Team_1__c, Team_2__c, Match_Date__c
                                        FROM Match__c
                                        WHERE Tournament__c IN :tournaments 
                                        AND Group__c IN :groups
                                        AND Round__c =:'Group Stage'];

        List<Tournament_Team__c> tournamentTeams = [SELECT Id, Status__c, Team__c from Tournament_Team__c
                                        WHERE Tournament__c IN :tournaments];

        List<Group_Result__c> groupResultList =  [SELECT Id, Team__c, Tournament__c, Group__c, Goals_For__c, Goals_Against__c, Wins__c, Losses__c, Draws__c 
                                        FROM Group_Result__c
                                        WHERE Tournament__c IN :tournaments 
                                        AND Group__c IN :groups
                                        ORDER BY Points__c DESC];

        Boolean teamCanPlay = checkIfTeamsCanPlay(tournamentTeams, newMatches);
        Boolean datesMatched = checkIfMatchDates(newMatches, oldMatches, groupResultList, tournamentTeams);
        if(teamCanPlay) {
            if(datesMatched) {
                updateGroupResult(groupResultList, oldMatches, newMatches);
            }
            updateTournamentTeams(newMatches, groupResultList, tournamentTeams, false);
        }
    }

    private void updateTournamentTeams(
        List<Match__c> matches, 
        List<Group_Result__c> groupResultList, 
        List<Tournament_Team__c> tournamentTeams, 
        Boolean groupStageCheck) {

        Map<Id, Tournament_Team__c> tournamentTeamMap = teamTournamentsMap(tournamentTeams);
        List<Tournament_Team__c> teamTournaments = new List<Tournament_Team__c>();
        if(!groupStageCheck) {
            for(Match__c match : matches) {
                if(match.Round__c != 'Group Stage') {
                    Id winner = match.Team_1_Score__c > match.Team_2_Score__c ? match.Team_1__c : match.Team_2__c;
                    Id looser = match.Team_1_Score__c < match.Team_2_Score__c ? match.Team_1__c : match.Team_2__c;
                    String status = match.Round__c == 'Final' ? 'Winner' : 'Playing';
                    Tournament_Team__c roundWinner = tournamentTeamMap.get(winner);
                    roundWinner.Status__c = status;
                    teamTournaments.add(roundWinner);
                    Tournament_Team__c roundLooser = tournamentTeamMap.get(looser);
                    roundLooser.Status__c='Eliminated';
                    teamTournaments.add(roundLooser);
                }
            }
        } else {
            for (Integer i = 0; i < groupResultList.size(); i++) {
                Tournament_Team__c teamResult = tournamentTeamMap.get(groupResultList[i].Team__c);
                if(i < 2) {
                    teamResult.Status__c='Playing';
                } else {
                    teamResult.Status__c='Eliminated';
                }
                teamTournaments.add(teamResult);
            }
        }
        update teamTournaments;
    }

    private Boolean checkIfMatchDates(List<Match__c> newMatches, List<Match__c> oldMatches, List<Group_Result__c> groupResultList, List<Tournament_Team__c> tournamentTeams) {
        List<Match__c> allMatches = new List<Match__c>();
        allMatches.addAll(newMatches);
        allMatches.addAll(oldMatches);
        Map<String, List<Datetime>> matchCountByGroup = new Map<String, List<Datetime>>();
        Boolean result = true;
        // Count the number of matches per group and get the latest match date per group
        for (Match__c match : allMatches) {
            String groupId = match.Group__c;
            Datetime matchDate = match.Match_Date__c;
            // Count matches per group
            if (!matchCountByGroup.containsKey(groupId)) {
                matchCountByGroup.put(groupId, new List<Datetime>{});
            }
            matchCountByGroup.get(groupId).add(matchDate);
        }

        for(Match__c match : newMatches) {
            String groupId = match.Group__c;
            List<Datetime> matchDates = matchCountByGroup.get(groupId);
            matchDates.sort();
            switch on matchDates.size() {
                when 6 {
                    if(matchDates[matchDates.size()-1] != matchDates[matchDates.size()-2]) {
                        match.addError('The 2 last matches in a group should be at the same time');
                        result = false;
                        break;
                    }
                    updateTournamentTeams(allMatches, groupResultList, tournamentTeams, true);
                }
                when else {
                    if(matchDates.size()>6 && match.Round__c == 'Group Stage') {
                        match.addError('Cannot add more matches for these teams.');
                    }
                }
            }

        }
        return result;
    }
    private Boolean checkIfTeamsCanPlay(List<Tournament_Team__c> tournamentTeams, List<Match__c> newMatches) {
        Boolean status = true;
        Map<Id, String> statusByTeam = new Map<Id, String>();
        for(Tournament_Team__c tournamentTeam : tournamentTeams) {
            statusByTeam.put(tournamentTeam.Team__c, tournamentTeam.Status__c);
        }
        
        for(Match__c match : newMatches) {
            if(statusByTeam.get(match.Team_1__c) != 'Playing' || statusByTeam.get(match.Team_2__c) != 'Playing') {
                match.addError('Cannot add a non playing (Eliminated) team to a new match on this tournament');
                status = false;
                break;
            }
        }
        return status;
    }

    private void updateGroupResult(List<Group_Result__c> groupResultList, List<Match__c> oldMatches, List<Match__c> newMatches) {
        Map<Id, Group_Result__c> groupResults = groupResultByTeam(groupResultList);
        
        Map<String, List<Match__c>> matchesByTeam = groupMatchesByTeam(oldMatches);

        for (Match__c match : newMatches) {
            if(match.Round__c == 'Group Stage') {
                string id = match.Tournament__c + '_' + match.Group__c + '_';
                Integer team_1_matches = (matchesByTeam.containsKey(id + match.Team_1__c)) ? matchesByTeam.get(id + match.Team_1__c).size() : 0;
                Integer team_2_matches = (matchesByTeam.containsKey(id + match.Team_2__c)) ? matchesByTeam.get(id + match.Team_2__c).size() : 0;
                // Check if we're allowed to add more matches between these 2 teams. 
                if(team_1_matches <= 2 && team_2_matches <= 2) {
                    // Now we are allowed so we can go on and update their respective Group Result.
                    // But before that we need to do some check on match result.
                    Group_Result__c groupResultTeam1 = groupResults.get(match.Team_1__c);
                    Group_Result__c groupResultTeam2 = groupResults.get(match.Team_2__c);
                    groupResultTeam1.Goals_For__c = groupResultTeam1.Goals_For__c + match.Team_1_Score__c;
                    groupResultTeam1.Goals_Against__c = groupResultTeam1.Goals_Against__c + match.Team_2_Score__c;
                    groupResultTeam2.Goals_For__c = groupResultTeam2.Goals_For__c + match.Team_2_Score__c;
                    groupResultTeam2.Goals_Against__c = groupResultTeam2.Goals_Against__c + match.Team_1_Score__c;
                    if(match.Team_1_Score__c > match.Team_2_Score__c) {
                        // Team 1 is the winner
                        groupResultTeam1.Wins__c = groupResultTeam1.Wins__c + 1;
                        groupResultTeam2.Losses__c = groupResultTeam2.Losses__c + 1;
                    } else if(match.Team_2_Score__c > match.Team_1_Score__c) {
                        // Team 2 is the winner
                        groupResultTeam2.Wins__c = groupResultTeam2.Wins__c + 1;
                        groupResultTeam1.Losses__c = groupResultTeam1.Losses__c + 1;
                    } else {
                        // a Draw !
                        groupResultTeam2.Draws__c = groupResultTeam2.Draws__c + 1;
                        groupResultTeam1.Draws__c = groupResultTeam1.Draws__c + 1;
                    }
                    groupResults.put(match.Team_1__c, groupResultTeam1);
                    groupResults.put(match.Team_2__c, groupResultTeam2);
                } else {
                    match.addError('Cannot add more matches for these teams.');
                }
            }
        }
        update groupResults.values();
    }

    private Map<String, List<Match__c>> groupMatchesByTeam(List<Match__c> oldMatches) {
        Map<String, List<Match__c>> matchesByTeam = new Map<String, List<Match__c>>();
        
        for (Match__c match : oldMatches) {
            String id = match.Tournament__c + '_' + match.Group__c + '_';
    
            // Check and add Team 1
            if (!matchesByTeam.containsKey(id + match.Team_1__c)) {
                matchesByTeam.put(id + match.Team_1__c, new List<Match__c>());
            }
            matchesByTeam.get(id + match.Team_1__c).add(match);
    
            // Check and add Team 2
            if (!matchesByTeam.containsKey(id + match.Team_2__c)) {
                matchesByTeam.put(id + match.Team_2__c, new List<Match__c>());
            }
            matchesByTeam.get(id + match.Team_2__c).add(match);
        }
        
        return matchesByTeam;
    }
    

    private Map<Id, Group_Result__c> groupResultByTeam(List<Group_Result__c> groupResults) {
        Map<Id, Group_Result__c> groupResultByTeam = new Map<Id, Group_Result__c>();
        for(Group_Result__c groupResult : groupResults) {
            groupResultByTeam.put(groupResult.Team__c, groupResult);
        }
        return groupResultByTeam;
    }

    private Map<Id, Tournament_Team__c> teamTournamentsMap(List<Tournament_Team__c> tournamentTeams) {
        Map<Id, Tournament_Team__c> tournamentTeamMap = new Map<Id, Tournament_Team__c>();

        for (Tournament_Team__c tournamentTeam : tournamentTeams) {
            tournamentTeamMap.put(tournamentTeam.Team__c, tournamentTeam);
        }
        return tournamentTeamMap;
    }
}