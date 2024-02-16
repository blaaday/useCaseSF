trigger TournamentTeamTrigger on Tournament_Team__c (before insert) {
    new TournamentTriggerHelper().run();
}