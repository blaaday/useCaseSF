public with sharing class MatchFactory implements RecordFactory {
    
    public List<Match__c> createRecord(List<Map<String, Object>> recordData) {
        List<Match__c> matches = new List<Match__c>();
        for(Map<String, Object> record : recordData) {
            Match__c match = new Match__c(
                Tournament__c=(Id) record.get('Tournament__c'),
                Match_Date__c=(Datetime) record.get('Match_Date__c'),
                Group__c=(Id) record.get('Group__c'),
                Round__c=(String) record.get('Round__c'),
                Team_1__c=(Id) record.get('Team_1__c'),
                Team_2__c=(Id) record.get('Team_2__c'),
                Team_1_Score__c=(Integer) record.get('Team_1_Score__c'),
                Team_2_Score__c=(Integer) record.get('Team_2_Score__c'),
                Approved__c=true
            );
            matches.add(match);
        }
        if(matches.size() > 0) {
            insert matches;
        }
        return matches;
    }
}