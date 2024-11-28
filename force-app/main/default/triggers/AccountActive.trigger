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
