@isTest
private class ExpensesPageControllerTest {
    @isTest
    static void test(){
		Contact c1 = new Contact(
            LastName = 'Test1', Email = 'test1@test.by', Office__c = 'Office 1'
        );
        insert c1;
        
        Contact c2 = new Contact(
            LastName = 'Test2', Email = 'test2@test.by', Office__c = 'Office 1'
        );
        insert c2;
        
        Contact admin = new Contact(
            LastName = 'Admin', Email = 'admin@test.by', Office__c = 'Office 1', Admin__c = true
        );
        insert admin;
        
        ExpenseCard__c card1 = new ExpenseCard__c(
        CardKeeper__c = c1.Id, CardDate__c = Date.newInstance(2020, 1, 1), Amount__c = 10, Description__c = 'Test1'
        );
        insert card1;
        
        ExpenseCard__c card2 = new ExpenseCard__c(
        CardKeeper__c = c2.Id, CardDate__c = Date.newInstance(2020, 2, 1), Amount__c = 20, Description__c = 'Test2'
        );
        insert card2;
        
        ExpenseCard__c card3 = new ExpenseCard__c(
        CardKeeper__c = c2.Id, CardDate__c = Date.newInstance(2020, 2, 1), Amount__c = 2000, Description__c = 'Test3'
        );
        insert card3;
        
        ExpensesPageController.saveExpenseCard(c1.Id, 50, Date.newInstance(2020, 1, 10), 'Test');
        ExpensesPageController.deleteExpenseCard(card3.Id);
        ExpensesPageController.addBalance('2020-01-01', c1.Id, 80);
        ExpensesPageController.updateExpenseCard(card1.Id, 'Changed', null);
        
        ExpensesPageController.MonthlyExpense me = 
            ExpensesPageController.getMonthlyExpense(c1.Id, 2020, c1.Office__c);
        ExpensesPageController.MonthlyExpense meAdmin = 
            ExpensesPageController.getMonthlyExpense(admin.Id, 2020, 'Office 1');
        List<ExpensesPageController.Expenses> exp = 
            ExpensesPageController.getExpenseCard(Date.newInstance(2020, 2, 1), c2.Id, c2.Office__c);
        List<ExpensesPageController.Expenses> expAdmin = 
            ExpensesPageController.getExpenseCard(Date.newInstance(2020, 1, 1), admin.Id, 'Office 1');
        
        System.assertEquals(60, me.totalAmount);
        System.assertEquals(80, meAdmin.totalAmount);
        System.assertEquals(0, meAdmin.Balance);
        System.assertEquals(20, exp[0].totalSum);
        System.assertEquals(10, expAdmin[0].totalSum);
        System.assertEquals('Changed', expAdmin[0].expenseCardList[0].Description__c);
    }
}