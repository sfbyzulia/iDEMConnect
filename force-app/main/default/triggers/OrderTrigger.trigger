trigger OrderTrigger on Order (before update) {
    OrderTriggerHandler.validateOrderActivation(Trigger.new, Trigger.oldMap);
}