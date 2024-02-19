public interface RecordFactory {
    List<SObject> createRecord(List<Map<String, Object>> recordData);
}