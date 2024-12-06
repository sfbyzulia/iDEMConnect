/**
 * A batch class to create reminder tasks for Accounts.
 * - Fetches Accounts without Orders and without 'Call' tasks.
 * - Creates a reminder task for these Accounts.
 */
public class ReminderTask implements Database.Batchable<SObject> {

    /**
     * Defines the batchable start method to retrieve a QueryLocator.
     *
     * @param bc The batchable context.
     * @return A QueryLocator containing Accounts without Orders and 'Call' tasks.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Step 1: Fetch IDs of accounts with "Call" tasks
        Set<Id> accountIdsWithCallTasks = new Set<Id>();
        for (Task task : [SELECT WhatId FROM Task WHERE Subject = 'Call' AND WhatId != null]) {
            accountIdsWithCallTasks.add(task.WhatId);
        }

        // Step 2: Query accounts without orders and not in the "Call" task list
        String query = 
            'SELECT Id, OwnerId ' +
            'FROM Account ' +
            'WHERE Id NOT IN (SELECT AccountId FROM Order)';
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
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        // Fetch the correct value for 'RecurrenceRegeneratedType' using Schema
        String recurrenceRegeneratedValue = getPicklistValue('Après la date d\'échéance');

        // Create tasks for each account in the batch
        List<Task> tasks = new List<Task>();
        for (Account acc : accounts) {
            tasks.add(new Task(
                Subject = 'Call',
                Status = 'Nouvelle',
                Priority = 'Normale',
                ActivityDate = Date.today(),
                WhatId = acc.Id,
                OwnerId = acc.OwnerId,
                IsReminderSet = true,
                ReminderDateTime = DateTime.now().addDays(5).addHours(9),
                RecurrenceInterval = 5,
                RecurrenceRegeneratedType = recurrenceRegeneratedValue
            ));
        }

        // Insert tasks if there are any
        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }

    /**
     * Fetches the exact picklist value for RecurrenceRegeneratedType based on the label.
     *
     * @param label The label of the picklist value (e.g., 'Après la date d\'échéance').
     * @return The actual picklist value matching the label.
     */
    public String getPicklistValue(String label) {
        Schema.DescribeSObjectResult taskDescription = Task.SObjectType.getDescribe();
        Schema.DescribeFieldResult fieldDescription = taskDescription.fields.getMap().get('RecurrenceRegeneratedType').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescription.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getLabel() == label) {
                return entry.getValue();
            }
        }
            // Throw an exception if the value is not found (logically should never happen).
            throw new IllegalArgumentException('Picklist value not found: ' + label);
    }

    /**
     * Finalizes the batch job.
     *
     * @param bc The batchable context.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Reminder tasks have been created successfully.');
    }
}
