public with sharing class TournamentTeamFactory implements RecordFactory {
    public List<Tournament_Team__c> createRecord(List<Map<String, Object>> recordData) {
        List<Tournament_Team__c> tournamentTeams = new List<Tournament_Team__c>();
        for(Map<String, Object> record : recordData) {
            Tournament_Team__c tournamentTeam = new Tournament_Team__c(
                Tournament__c=(Id) record.get('Tournament__c'),
                Team__c=(Id) record.get('Team__c'),
                Group__c=(Id) record.get('Group__c'),
                Status__c=(String) record.get('Status__c'),
                Approved__c=true
            );
            tournamentTeams.add(tournamentTeam);
        }
        if(tournamentTeams.size() > 0 && Schema.sObjectType.Tournament_Team__c.isCreateable()) {
            insert tournamentTeams;
        }
        return tournamentTeams;
    }
}