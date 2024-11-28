public class AccountActiveHandler {

    // Handle Order Insertion: Automatically check the Active__c field on the related Account
    public static void handleOrderInsertion(List<Order> newOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        // Identify the accounts related to the inserted orders
        for (Order ord : newOrders) {
            if (ord.AccountId != null) {
                accountIdsToUpdate.add(ord.AccountId);
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIdsToUpdate];

            for (Account acc : accountsToUpdate) {
                if (!acc.Active__c) {  // Only update if it's not already checked
                    acc.Active__c = true;  // Check the box automatically
                }
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }

    // Handle Order Deletion: Uncheck Active__c if no remaining orders are linked to the account
    public static void handleOrderDeletion(List<Order> deletedOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        // Collect Account IDs from deleted orders
        for (Order ord : deletedOrders) {
            if (ord.AccountId != null) {
                accountIdsToUpdate.add(ord.AccountId);
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            // Check if there are any remaining orders linked to the account
            List<AggregateResult> orderCounts = [
                SELECT AccountId, COUNT(Id) orderCount
                FROM Order
                WHERE AccountId IN :accountIdsToUpdate
                GROUP BY AccountId
            ];

            Set<Id> accountsWithOrders = new Set<Id>();
            for (AggregateResult ar : orderCounts) {
                if ((Integer)ar.get('orderCount') > 0) {
                    accountsWithOrders.add((Id)ar.get('AccountId'));
                }
            }

            // Uncheck Active__c on accounts that have no remaining orders
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
