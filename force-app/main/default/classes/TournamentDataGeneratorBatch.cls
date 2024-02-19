public class TournamentDataGeneratorBatch implements Database.Batchable<Object> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        // No query is needed as we're generating random data without querying records
        System.debug('Starting TournamentDataGenerator Batch to generate a tournament with all teams, groups and matches.');
        return null;
    }
    
    public void execute(Database.BatchableContext context, List<Object> scope) {
        // Generate random tournament data using DataGenerator class
        DataGenerator.setupTournament();
    }
    
    public void finish(Database.BatchableContext context) {
        System.debug('Finished generating Tournament.');
    }
}