/**
 * A batch class to create reminder tasks for Accounts.
 * - Fetches Accounts without Orders and without 'Call' tasks.
 * - Creates a reminder task for these Accounts.
 */
global class ReminderTask implements Database.Batchable<SObject> {

    /**
     * Defines the batchable start method to retrieve a QueryLocator.
     *
     * @param bc The batchable context.
     * @return A QueryLocator containing Accounts without Orders and 'Call' tasks.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> accountIdsWithCallTasks = new Set<Id>();
        for (Task task : [SELECT WhatId FROM Task WHERE Subject = 'Call']) {
            accountIdsWithCallTasks.add(task.WhatId);
        }

        String query = 'SELECT Id, OwnerId FROM Account WHERE Id NOT IN ' +
                       '(SELECT AccountId FROM Order)';
        if (!accountIdsWithCallTasks.isEmpty()) {
            query += ' AND Id NOT IN :accountIdsWithCallTasks';
        }

        return Database.getQueryLocator(query);
    }

    /**
     * Processes each batch of Accounts and creates reminder tasks for them.
     *
     * @param bc       The batchable context.
     * @param accounts The list of Accounts to process.
     */
    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Task> tasks = new List<Task>();

        for (Account acc : accounts) {
            tasks.add(new Task(
                Subject = 'Call',
                Status = 'Nouvelle',
                Priority = 'Normale',
                ActivityDate = Date.today(), // Task is due today
                WhatId = acc.Id, // Link task to the account
                OwnerId = acc.OwnerId, // Assign task to account owner
                RecurrenceInterval = 5, // Task will regenerate every 5 days
                RecurrenceRegeneratedType = 'Après la date d\'échéance' // Regenerate the task after the due date
            ));
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }

    /**
     * Finalizes the batch job.
     *
     * @param bc The batchable context.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Reminder tasks have been created successfully.');
    }
}
