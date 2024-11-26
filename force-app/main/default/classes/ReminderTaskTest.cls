@isTest
public class ReminderTaskTest {

    @testSetup
    static void setupTestData() {
        // Create accounts
        Account accWithoutOrder = new Account(Name = 'Account Without Order');
        Account accWithOrder = new Account(Name = 'Account With Order');
        Account accWithTask = new Account(Name = 'Account With Call Task');
        insert new List<Account>{ accWithoutOrder, accWithOrder, accWithTask };

        // Create one contract
        Contract con = new Contract(
            AccountId = accWithOrder.Id, // Link it to accWithOrder by default
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert con;
        con.Status = 'Activated';
        update con;

        // Create an order for the second account with the activated contract
        Order order = new Order(
            AccountId = accWithOrder.Id,
            ContractId = con.Id, // Attach the same contract to the order
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert order;

        // Create a 'Call' task for the third account
        Task callTask = new Task(
            Subject = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(5), // Reminder for 5 days later
            WhatId = accWithTask.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert callTask;
    }

    @isTest
    static void testReminderTaskBatch() {
        // Calculate the expected date dynamically
        Date expectedDate = Date.today().addDays(5);

        // Verify test setup
        List<Account> allAccounts = [SELECT Id FROM Account];
        Assert.areEqual(3, allAccounts.size(), 'There should be 3 accounts in the test setup.');

        // Execute the batch
        Test.startTest();
        Database.executeBatch(new ReminderTask(), 1); // Process one batch at a time
        Test.stopTest();

        // Verify tasks created
        List<Task> tasks = [SELECT Subject, Status, Priority, ActivityDate, WhatId FROM Task WHERE Subject = 'Call'];
        Assert.areEqual(2, tasks.size(), 'There should be 2 Call tasks created.');

        // Validate tasks are linked to correct accounts
        for (Task task : tasks) {
            Assert.isNotNull(task.WhatId, 'Task should be linked to an Account.');
            Assert.areEqual('Not Started', task.Status, 'Task status should be "Not Started".');
            Assert.areEqual('Normal', task.Priority, 'Task priority should be "Normal".');
            Assert.areEqual(expectedDate, task.ActivityDate, 'Task reminder should be 5 days from today.');
        }
    }
}
