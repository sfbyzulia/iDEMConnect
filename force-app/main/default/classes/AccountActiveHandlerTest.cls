@isTest
public class AccountActiveHandlerTest {

    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccount();
        Contract con = TestDataFactory.createContract(acc.Id);
        Product2 prod = TestDataFactory.createProduct();
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(prod);
        TestDataFactory.createOrder(acc.Id, con.Id, pbe.Pricebook2Id);
    }

    @isTest
    static void testOrderInsertion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order newOrder = TestDataFactory.createOrder(acc.Id, null, Test.getStandardPricebookId());

        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, acc.Active__c, 'The Active__c checkbox should be checked when an Order is added.');
    }

    @isTest
    static void testOrderDeletion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order ord = [SELECT Id FROM Order WHERE AccountId = :acc.Id LIMIT 1];
        delete ord;

        acc = [SELECT Id, Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, acc.Active__c, 'The Active__c checkbox should be unchecked when all Orders are deleted.');
    }
}
