global class ReminderTaskScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Execute the ReminderTask batch
        Database.executeBatch(new ReminderTask());
    }
}
