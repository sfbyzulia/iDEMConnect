@isTest
public class OrderTriggerHandlerTest {

    @testSetup
    public static void createTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    
        // Create a Contract
        Contract con = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert con;
        con.Status = 'Activated';
        update con;
    
        // Create a Product
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
    
        // Create Pricebook Entry for Standard Pricebook
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;
    
        // Create an Order
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            ContractId = con.Id,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;
    }    

    @isTest
    static void testOrderActivationWithoutProducts() {
        // Fetch the Order created in @testSetup
        Order ord = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
    
        // Attempt to activate the Order without adding Order Items
        ord.Status = 'Activated';
    
        Test.startTest();
        try {
            update ord;
            Assert.fail('Expected a FIELD_CUSTOM_VALIDATION_EXCEPTION but none occurred.');
        } catch (Exception e) {
            // Verify that the exception contains the expected validation error
            String errorMessage = 'This order cannot be activated without associated products. Please add products before changing the status to Activated.';
            Assert.isTrue(e.getMessage().contains(errorMessage), 
                          'Expected a validation error, but got: ' + e.getMessage());
        }
        Test.stopTest();
    }    

    @isTest
    static void testOrderActivationWithProducts() {
        // Fetch the Order and PricebookEntry created in @testSetup
        Order ord = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];
    
        // Create an OrderItem
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oi;
    
        // Attempt to activate the Order
        Test.startTest();
        ord.Status = 'Activated';
        update ord;
        Test.stopTest();
    
        // Verify that the Order status is updated
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];
        Assert.areEqual('Activated', updatedOrder.Status, 'The Order status should be updated to Activated.');
    }    
}