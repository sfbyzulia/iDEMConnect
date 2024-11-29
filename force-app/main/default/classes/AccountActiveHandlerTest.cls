@isTest
public class AccountActiveHandlerTest {

    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccount();
        Contract con = TestDataFactory.createContract(acc.Id);
        Product2 prod = TestDataFactory.createProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);

        // Create two orders for the same account
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
    }

    @isTest
    static void testOrderInsertion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order newOrder = TestDataFactory.createOrder(acc.Id, null, Test.getStandardPricebookId());

        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(true, acc.Active__c, 'The Active__c checkbox should be checked when an Order is added.');
    }

    @isTest
    static void testOrderPartialDeletion() {
        // Fetch the account and one of its orders
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId = :acc.Id];
        Assert.areEqual(2, orders.size(), 'The account should initially have two orders.');

        // Delete one order
        delete orders[0];

        // Fetch the updated account
        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(true, acc.Active__c, 'The Active__c checkbox should remain checked when there are still remaining orders linked to the account.');
    }

    @isTest
    static void testOrderDeletion() {
        // Fetch the account and all orders
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId = :acc.Id];
        Assert.areEqual(2, orders.size(), 'The account should initially have two orders.');

        // Delete all orders
        delete orders;

        // Fetch the updated account
        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(false, acc.Active__c, 'The Active__c checkbox should be unchecked when all Orders are deleted.');
    }
}
