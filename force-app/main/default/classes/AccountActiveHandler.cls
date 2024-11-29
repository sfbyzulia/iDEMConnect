/**
 * A handler class for the AccountActive trigger, managing the Active__c field on Accounts.
 */
public class AccountActiveHandler {

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

            List<Account> accountsToUpdate = new List<Account>();
            for (Id accId : accountIdsToUpdate) {
                if (!accountsWithOrders.contains(accId)) {
                    Account acc = new Account(Id = accId, Active__c = false);
                    accountsToUpdate.add(acc);
                }
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}
