trigger ExpenseCardTrigger on ExpenseCard__c (before insert) {

    for(ExpenseCard__c ec : Trigger.New) {
        Id keeperId = ec.CardKeeper__c;
        Integer year = ec.CardDate__c.year();
        Integer month = ec.CardDate__c.month();
        Date monthDate = Date.newInstance(year, month, 1);

        List<MonthlyExpense__c> monthlyExpense = [
            SELECT Id FROM MonthlyExpense__c WHERE MonthDate__c =: monthDate AND Keeper__c =: keeperId
        ];

        if (monthlyExpense.isEmpty()) {
            MonthlyExpense__c me = new MonthlyExpense__c(
                Keeper__c = keeperId,
                MonthDate__c = monthDate
            );
            Id meId = Database.insert(me).getId();
            ec.MonthlyExpense__c = meId;
        } else {
            ec.MonthlyExpense__c = monthlyExpense[0].Id;
        }

    }
}