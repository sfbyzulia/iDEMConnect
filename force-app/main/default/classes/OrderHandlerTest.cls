/**
 * A test class for the OrderHandler class.
 * Ensures validation of Order activation and proper management of Account Active__c field.
 */
@isTest
public class OrderHandlerTest {

    /**
     * Sets up test data for the OrderHandler tests.
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
     * Tests that an Order cannot be activated without associated Order Items.
     */
    @isTest
    static void testOrderActivationWithoutProducts() {
        Order ord = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        ord.Status = 'Activated';
        Test.startTest();
        try {
            update ord;
            Assert.fail('Expected validation error, but none occurred.');
        } catch (Exception e) {
            String errorMessage = 'This order cannot be activated without associated products.';
            Assert.isTrue(e.getMessage().contains(errorMessage), 'Expected validation error: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Tests that an Order can be activated with associated Order Items.
     */
    @isTest
    static void testOrderActivationWithProducts() {
        Order ord = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];
        TestDataFactory.createOrderItem(ord.Id, pbe.Id);
        Test.startTest();
        ord.Status = 'Activated';
        update ord;
        Test.stopTest();
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];
        Assert.areEqual('Activated', updatedOrder.Status, 'The Order status should be updated to Activated.');
    }

    /**
     * Tests that Active__c is checked when an Order is added to an Account.
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
