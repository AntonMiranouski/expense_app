@isTest
private class ExpenseCardTriggerTest {
    @isTest
    static void test(){
        Contact c = new Contact(
            LastName = 'Test', Email = 'test@test.by', Office__c = 'Office 1'
        );
        insert c;
        
        ExpenseCard__c card1 = new ExpenseCard__c(
        CardKeeper__c = c.Id, CardDate__c = Date.newInstance(2020, 1, 1), Amount__c = 10, Description__c = 'Test'
        );
        insert card1;
        
        ExpenseCard__c card2 = new ExpenseCard__c(
        CardKeeper__c = c.Id, CardDate__c = Date.newInstance(2020, 1, 1), Amount__c = 20, Description__c = 'Test'
        );
        insert card2;

        Test.startTest();
        List<MonthlyExpense__c> expenses = [SELECT Id FROM MonthlyExpense__c];
        Test.stopTest();

        System.assertEquals(1, expenses.size());
    }
}