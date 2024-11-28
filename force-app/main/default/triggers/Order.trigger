trigger Order on Order (before update) {
    OrderHandler.validateOrderActivation(Trigger.new, Trigger.oldMap);
}