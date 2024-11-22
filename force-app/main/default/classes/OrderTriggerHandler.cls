public class OrderTriggerHandler {

    public static void validateOrderActivation(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        for (Order ord : newOrders) {
            if (ord.Status == 'Active' && oldOrderMap.get(ord.Id).Status == 'Draft') {
                Boolean hasProducts = [SELECT COUNT() FROM OrderItem WHERE OrderId = :ord.Id] > 0;

                if (!hasProducts) {
                    ord.addError('This order cannot be activated without associated products. Please add products before changing the status to Active.');
                }
            }
        }
    }
}