/**
 * A test class for the AccountActiveHandler class, ensuring proper functionality of Account Active__c field updates.
 */
@isTest
public class AccountActiveHandlerTest {

    /**
     * Sets up test data for the AccountActiveHandler tests.
     */
    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccount();
        Contract con = TestDataFactory.createContract(acc.Id);
        Product2 prod = TestDataFactory.createProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
    }

    /**
     * Tests that the Active__c field is checked when an Order is added to an Account.
     */
    @isTest
    static void testOrderInsertion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        TestDataFactory.createOrder(acc.Id, null, Test.getStandardPricebookId());
        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(true, acc.Active__c, 'Active__c should be checked when an Order is added.');
    }

    /**
     * Tests that Active__c remains checked when not all Orders are deleted.
     */
    @isTest
    static void testOrderPartialDeletion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId = :acc.Id];
        delete orders[0];
        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(true, acc.Active__c, 'Active__c should remain checked when there are still Orders linked.');
    }

    /**
     * Tests that Active__c is unchecked when all Orders are deleted.
     */
    @isTest
    static void testOrderDeletion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId = :acc.Id];
        delete orders;
        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(false, acc.Active__c, 'Active__c should be unchecked when all Orders are deleted.');
    }
}
