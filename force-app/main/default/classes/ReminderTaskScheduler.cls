/**
 * A scheduler class to execute the ReminderTask batch class.
 */
global class ReminderTaskScheduler implements Schedulable {

    /**
     * Executes the ReminderTask batch job.
     *
     * @param sc The schedulable context.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ReminderTask());
    }
}
