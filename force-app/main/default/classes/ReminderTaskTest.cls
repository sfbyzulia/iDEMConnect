@isTest
public class ReminderTaskTest {

    @testSetup
    static void setupTestData() {
        // Create a test user
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Create accounts for different scenarios
        Account accWithoutOrderAndTask = new Account(Name = 'Account Without Order and Task', OwnerId = testUser.Id);
        Account accWithOrder = new Account(Name = 'Account With Order', OwnerId = testUser.Id);
        Account accWithCallTask = new Account(Name = 'Account With Call Task', OwnerId = testUser.Id);
        insert new List<Account>{accWithoutOrderAndTask, accWithOrder, accWithCallTask};

        // Create an order for accWithOrder
        Order order = new Order(AccountId = accWithOrder.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert order;

        // Create a Call task for accWithCallTask
        Task callTask = new Task(
            Subject = 'Call',
            Status = 'Nouvelle',
            Priority = 'Normale',
            ActivityDate = Date.today(),
            WhatId = accWithCallTask.Id,
            OwnerId = testUser.Id,
            IsReminderSet = true,
            ReminderDateTime = DateTime.now().addDays(5).addHours(9)
        );
        insert callTask;
    }

    // Tests the execution of the ReminderTask batch.
    @isTest
    static void testReminderTaskBatch() {
        // Expected values
        Date expectedActivityDate = Date.today();
        DateTime expectedReminderDateTime = DateTime.now().addDays(5).addHours(9);

        Test.startTest();
        Database.executeBatch(new ReminderTask(), 1); // Execute batch
        Test.stopTest();

        // Verify that only 1 task is created for accWithoutOrderAndTask
        List<Task> tasks = [SELECT Subject, Status, Priority, ActivityDate, ReminderDateTime, WhatId, IsReminderSet
                            FROM Task WHERE Subject = 'Call' AND WhatId IN (SELECT Id FROM Account WHERE Name = 'Account Without Order and Task')];
        Assert.areEqual(1, tasks.size(), 'There should be 1 Call task created.');

        // Validate task details
        Task task = tasks[0];
        Assert.areEqual('Call', task.Subject, 'The task subject should be "Call".');
        Assert.areEqual('Nouvelle', task.Status, 'The task status should be "Nouvelle".');
        Assert.areEqual('Normale', task.Priority, 'The task priority should be "Normale".');
        Assert.areEqual(expectedActivityDate, task.ActivityDate, 'The task activity date should be today.');
        Assert.isTrue(task.IsReminderSet, 'The task should have a reminder set.');
        Assert.areEqual(expectedReminderDateTime.date(), task.ReminderDateTime.date(), 'The reminder date should be 5 days from today.');
    }

    // Tests the scheduling of the ReminderTask batch using ReminderTaskScheduler.
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExpression = '0 0 9 ? * 2#1';
        String jobId = System.schedule('Test Reminder Task Scheduler', cronExpression, new ReminderTaskScheduler());
        Test.stopTest();

        // Validate the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(cronExpression, ct.CronExpression, 'The cron expression should match.');
        Assert.areEqual(0, ct.TimesTriggered, 'The job should not have been triggered yet.');
    }
}
