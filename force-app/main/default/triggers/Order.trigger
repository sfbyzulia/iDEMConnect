/**
 * A trigger on the Order object that enforces validation for activation of Orders.
 */
trigger Order on Order (before update) {
    OrderHandler.validateOrderActivation(Trigger.new, Trigger.oldMap);
}
