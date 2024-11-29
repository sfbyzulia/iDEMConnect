/**
 * A trigger on the Order object.
 * - Validates that Orders cannot be activated without associated Order Items.
 * - Manages the Active__c field on related Accounts.
 */
trigger Order on Order (before update, after insert, after delete) {

    // Before update: Validate Order activation
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderHandler.validateOrderActivation(Trigger.new, Trigger.oldMap);
    }

    // After insert: Handle Account Active__c field when Orders are inserted
    if (Trigger.isAfter && Trigger.isInsert) {
        OrderHandler.handleOrderInsertion(Trigger.new);
    }

    // After delete: Handle Account Active__c field when Orders are deleted
    if (Trigger.isAfter && Trigger.isDelete) {
        OrderHandler.handleOrderDeletion(Trigger.old);
    }
}
