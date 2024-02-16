trigger MatchTrigger on Match__c (before insert) {
	new MatchTriggerHandler().run();
}