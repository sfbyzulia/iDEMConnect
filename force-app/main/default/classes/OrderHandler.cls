/**
 * A handler class for the Order.
 * - Validates Order activation.
 * - Manages the Active__c field on related Accounts.
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

    /**
     * Handles the insertion of new Orders.
     * Automatically checks the Active__c field on related Accounts.
     *
     * @param newOrders The list of newly inserted Orders.
     */
    public static void handleOrderInsertion(List<Order> newOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        for (Order ord : newOrders) {
            if (ord.AccountId != null) {
                accountIdsToUpdate.add(ord.AccountId);
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIdsToUpdate];

            for (Account acc : accountsToUpdate) {
                if (!acc.Active__c) {
                    acc.Active__c = true;
                }
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }

    /**
     * Handles the deletion of Orders.
     * Automatically unchecks the Active__c field on Accounts with no remaining Orders.
     *
     * @param deletedOrders The list of deleted Orders.
     */
    public static void handleOrderDeletion(List<Order> deletedOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        for (Order ord : deletedOrders) {
            if (ord.AccountId != null) {
                accountIdsToUpdate.add(ord.AccountId);
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            List<AggregateResult> orderCounts = [
                SELECT AccountId, COUNT(Id) orderCount
                FROM Order
                WHERE AccountId IN :accountIdsToUpdate
                GROUP BY AccountId
            ];

            Set<Id> accountsWithOrders = new Set<Id>();
            for (AggregateResult ar : orderCounts) {
                if ((Integer) ar.get('orderCount') > 0) {
                    accountsWithOrders.add((Id) ar.get('AccountId'));
                }
            }

            for (Id accId : accountIdsToUpdate) {
                if (!accountsWithOrders.contains(accId)) {
                    Account acc = new Account(Id = accId);
                    acc.Active__c = false;
                    update acc;
                }
            }
        }
    }
}
