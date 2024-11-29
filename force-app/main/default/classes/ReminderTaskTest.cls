@isTest
public class ReminderTaskTest {

    @testSetup
    static void setupTestData() {
        // Create accounts for different scenarios
        Account accWithoutOrder = new Account(Name = 'Account Without Order');
        Account accWithOrder = new Account(Name = 'Account With Order');
        Account accWithTask = new Account(Name = 'Account With Call Task');
        insert new List<Account>{ accWithoutOrder, accWithOrder, accWithTask };

        Contract con = new Contract(AccountId = accWithOrder.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert con;
        con.Status = 'Activated';
        update con;

        Order order = new Order(AccountId = accWithOrder.Id, ContractId = con.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert order;

        Task callTask = new Task(
            Subject = 'Call',
            Status = 'Nouvelle',
            Priority = 'Normale',
            ActivityDate = Date.today(), // Task due today
            WhatId = accWithTask.Id,
            OwnerId = UserInfo.getUserId(),
            IsReminderSet = true,
            ReminderDateTime = DateTime.now().addDays(5).addHours(9)
        );
        insert callTask;
    }

    @isTest
    static void testReminderTaskBatch() {
        Date expectedActivityDate = Date.today(); // Task is due today
        DateTime expectedReminderDateTime = DateTime.now().addDays(5).addHours(9);

        Test.startTest();
        Database.executeBatch(new ReminderTask(), 1); // Execute batch
        Test.stopTest();

        // Verify that tasks are created correctly
        List<Task> tasks = [SELECT Subject, Status, Priority, ActivityDate, ReminderDateTime, RecurrenceInterval, RecurrenceRegeneratedType, WhatId
                            FROM Task WHERE Subject = 'Call'];
        Assert.areEqual(1, tasks.size(), 'There should be 1 Call task created.');

        // Validate task details
        for (Task task : tasks) { // Loop in case of multiple tasks
            Assert.areEqual('Call', task.Subject, 'The task subject should be "Call".');
            Assert.areEqual('Nouvelle', task.Status, 'The task status should be "Nouvelle".');
            Assert.areEqual('Normale', task.Priority, 'The task priority should be "Normale".');
            Assert.areEqual(expectedActivityDate, task.ActivityDate, 'The task activity date should be today.');
            Assert.isTrue(task.IsReminderSet, 'The task should have a reminder set.');
            Assert.areEqual(expectedReminderDateTime, task.ReminderDateTime, 'The reminder should be set for 5 days later at 9 AM.');
            Assert.areEqual(5, task.RecurrenceInterval, 'The recurrence interval should be 5 days.');
            Assert.areEqual('Après la date d\'échéance', task.RecurrenceRegeneratedType, 'The recurrence type should be "After due date".');
        }
    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExpression = '0 0 9 ? * 2#1'; // First Monday of every month at 9:00 AM
        String jobId = System.schedule('Test Reminder Task Scheduler', cronExpression, new ReminderTaskScheduler());
        Test.stopTest();

        // Validate the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(cronExpression, ct.CronExpression, 'The cron expression should match.');
    }
}
