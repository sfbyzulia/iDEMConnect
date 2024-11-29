/**
 * A trigger on the Order object that manages the Active__c field on related Accounts.
 * - Automatically checks Active__c when a new Order is added to an Account.
 * - Automatically unchecks Active__c when all Orders are removed from an Account.
 */
trigger AccountActive on Order (after insert, after delete) {
    // Handle when a new Order is inserted
    if (Trigger.isAfter && Trigger.isInsert) {
        AccountActiveHandler.handleOrderInsertion(Trigger.new);
    }

    // Handle after Order deletion
    if (Trigger.isAfter && Trigger.isDelete) {
        AccountActiveHandler.handleOrderDeletion(Trigger.old);
    }
}
