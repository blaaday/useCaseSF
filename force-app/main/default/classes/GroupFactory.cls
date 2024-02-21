public with sharing class GroupFactory implements RecordFactory {
    public List<Group__c> createRecord(List<Map<String, Object>> recordData) {
        List<Group__c> groups = new List<Group__c>();
        for(Map<String, Object> record : recordData) {
            Group__c groupRecord = new Group__c(
                Name=(String) record.get('Name'),
                Tournament__c=(Id) record.get('Tournament__c'),
                Approved__c=true
            );
            groups.add(groupRecord);
        }
        if(groups.size() > 0 && Schema.sObjectType.Group__c.isCreateable()) {
            insert groups;
        }
        return groups;
    }
}