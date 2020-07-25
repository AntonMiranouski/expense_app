@isTest
private class AdminPageControllerTest {
    @isTest
    static void test(){
		Contact c = new Contact(
            LastName = 'Test', Email = 'test@test.by', Office__c = 'Office 1'
        );
        insert c;
        
        ExpenseCard__c card1 = new ExpenseCard__c(
        CardKeeper__c = c.Id, CardDate__c = Date.newInstance(2019, 1, 1), Amount__c = 10, Description__c = 'Test'
        );
        insert card1;
        
        ExpenseCard__c card2 = new ExpenseCard__c(
        CardKeeper__c = c.Id, CardDate__c = Date.newInstance(2020, 1, 1), Amount__c = 20, Description__c = 'Test'
        );
        insert card2;
        
        Test.startTest();
        AdminPageController.MonthlyExpense me = AdminPageController.getMonthlyExpense(2020);
        Test.stopTest();
        
        System.assertEquals(20, me.summ);
    }
}