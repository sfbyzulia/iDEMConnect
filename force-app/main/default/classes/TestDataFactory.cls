/**
 * A utility class to generate test data for Accounts, Contracts, Products, Orders, and Order Items.
 * This class helps create consistent and reusable test data for unit tests.
 */
public class TestDataFactory {

    /**
     * Creates and inserts an Account.
     *
     * @return The newly created Account.
     */
    public static Account createAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    /**
     * Creates and inserts a Contract linked to a specific Account.
     *
     * @param accountId The ID of the Account associated with the Contract.
     * @return The newly created Contract.
     */
    public static Contract createContract(Id accountId) {
        Contract con = new Contract(AccountId = accountId, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert con;
        con.Status = 'Activated';
        update con;
        return con;
    }

    /**
     * Creates and inserts a Product2.
     *
     * @return The newly created Product2.
     */
    public static Product2 createProduct() {
        Product2 prod = new Product2(Name = 'Test Product', Family = 'Test Family', IsActive = true);
        insert prod;
        return prod;
    }

    /**
     * Creates and inserts a PricebookEntry for the specified Product2.
     *
     * @param prod The Product2 to associate with the PricebookEntry.
     * @return The newly created PricebookEntry.
     */
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

    /**
     * Creates and inserts an Order linked to an Account and optionally a Contract.
     *
     * @param accountId   The ID of the Account associated with the Order.
     * @param contractId  The ID of the Contract associated with the Order (optional).
     * @param pricebookId The ID of the Pricebook associated with the Order.
     * @return The newly created Order.
     */
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

    /**
     * Creates and inserts an OrderItem linked to a specific Order and PricebookEntry.
     *
     * @param orderId           The ID of the Order associated with the OrderItem.
     * @param pricebookEntryId  The ID of the PricebookEntry associated with the OrderItem.
     * @return The newly created OrderItem.
     */
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
