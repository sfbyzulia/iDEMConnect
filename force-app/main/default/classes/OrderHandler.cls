/**
 * A handler class for the Order trigger.
 * Validates that an Order can only be activated if it has associated Order Items.
 */
public class OrderHandler {

    /**
     * Validates the activation of Orders.
     * Ensures an Order cannot be activated unless it has at least one associated Order Item.
     *
     * @param newOrders   The list of Orders being updated.
     * @param oldOrderMap A map of old Order records, keyed by Order ID.
     */
    public static void validateOrderActivation(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        for (Order ord : newOrders) {
            if (ord.Status == 'Activated' && oldOrderMap.get(ord.Id).Status == 'Draft') {
                Boolean hasProducts = [SELECT COUNT() FROM OrderItem WHERE OrderId = :ord.Id] > 0;

                if (!hasProducts) {
                    ord.addError('This order cannot be activated without associated products. Please add products before changing the status to Activated.');
                }
            }
        }
    }
}
