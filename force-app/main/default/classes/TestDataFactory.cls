@isTest
public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    public static Contract createContract(Id accountId) {
        Contract con = new Contract(AccountId = accountId, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert con;
        con.Status = 'Activated';
        update con;
        return con;
    }

    public static Product2 createProduct() {
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
        return prod;
    }

    public static PricebookEntry createPricebookEntry(Product2 prod) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    public static Order createOrder(Id accountId, Id contractId, Id pricebookId) {
        Order ord = new Order(
            AccountId = accountId,
            Status = 'Draft',
            ContractId = contractId,
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId
        );
        insert ord;
        return ord;
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oi;
        return oi;
    }
}
