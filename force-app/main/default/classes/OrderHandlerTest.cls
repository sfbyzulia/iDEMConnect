@isTest
public class OrderHandlerTest {

    @testSetup
    public static void setupTestData() {
        Account acc = TestDataFactory.createAccount();
        Contract con = TestDataFactory.createContract(acc.Id);
        Product2 prod = TestDataFactory.createProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
    }

    @isTest
    static void testOrderActivationWithoutProducts() {
        Order ord = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        ord.Status = 'Activated';

        Test.startTest();
        try {
            update ord;
            Assert.fail('Expected a FIELD_CUSTOM_VALIDATION_EXCEPTION but none occurred.');
        } catch (Exception e) {
            String errorMessage = 'This order cannot be activated without associated products. Please add products before changing the status to Activated.';
            Assert.isTrue(e.getMessage().contains(errorMessage), 'Expected a validation error, but got: ' + e.getMessage());
        }
        Test.stopTest();
    }

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
}
