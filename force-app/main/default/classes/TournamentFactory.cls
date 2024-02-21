public with sharing class TournamentFactory implements RecordFactory {
    
    public List<Tournament__c> createRecord(List<Map<String, Object>> recordData) {
        List<Tournament__c> tournaments = new List<Tournament__c>();
        for(Map<String, Object> record : recordData) {
            Tournament__c tournament = new Tournament__c(
                Name=(String) record.get('Name'),
                Start_Date__c=(Date) record.get('Start_Date__c'),
                End_Date__c=(Date) record.get('End_Date__c'),
                Status__c=(String) record.get('Status__c'),
                Approved__c=true
            );
            tournaments.add(tournament);
        }
        if(tournaments.size() > 0 && Schema.sObjectType.Tournament__c.isCreateable()) {
            insert tournaments;
        }
        return tournaments;
    }
}