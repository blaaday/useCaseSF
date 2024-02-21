public with sharing class TournamentTriggerHelper extends TriggerHandler {
    
    public TournamentTriggerHelper() {
        this.setMaxLoopCount(1);
    }

    public override void beforeInsert() {
        List<Tournament_Team__c> tournamentTeams = (List<Tournament_Team__c>) Trigger.new;
        List<Group_Result__c> groupResults = new List<Group_Result__c>();
        for (Tournament_Team__c team : tournamentTeams) {
            Group_Result__c groupResult = new Group_Result__c(
                Group__c=team.Group__c,
                Tournament__c=team.Tournament__c,
                Team__c=team.Team__c,
                Approved__c=true
            );
            groupResults.add(groupResult);
        }

        if(groupResults.size() > 0) {
            insert groupResults;
        }
    }
}