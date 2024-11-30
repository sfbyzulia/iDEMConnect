/**
 * A scheduler class to execute the ReminderTask batch class.
 */
public class ReminderTaskScheduler implements Schedulable {

    /**
     * Executes the ReminderTask batch job.
     *
     * @param sc The schedulable context.
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ReminderTask());
    }
}
