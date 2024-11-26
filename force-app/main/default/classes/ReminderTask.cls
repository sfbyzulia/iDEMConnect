global class ReminderTask implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch IDs of accounts that already have tasks with 'Call'
        Set<Id> accountIdsWithCallTasks = new Set<Id>();
        for (Task task : [SELECT WhatId FROM Task WHERE Subject = 'Call']) {
            accountIdsWithCallTasks.add(task.WhatId);
        }

        // Fetch accounts without orders and without tasks of type 'Call'
        String query = 'SELECT Id, OwnerId FROM Account WHERE Id NOT IN ' +
                       '(SELECT AccountId FROM Order)';
        if (!accountIdsWithCallTasks.isEmpty()) {
            query += ' AND Id NOT IN :accountIdsWithCallTasks';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Task> tasks = new List<Task>();

        for (Account acc : accounts) {
            tasks.add(new Task(
                Subject = 'Call',
                Status = 'Not Started',
                Priority = 'Normal',
                ActivityDate = Date.today().addDays(5), // Reminder for 5 days later
                WhatId = acc.Id, // Link to the account
                OwnerId = acc.OwnerId // Assign to the account owner
            ));
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Reminder tasks have been created successfully.');
    }
}
