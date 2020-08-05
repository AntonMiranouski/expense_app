public class ExpensesPageController {

    public class MonthlyExpense{
        
        @AuraEnabled
        public Decimal Balance;
        @AuraEnabled
        public Decimal totalAmount;
        @AuraEnabled
        public Decimal totalIncome;
        @AuraEnabled
        public List<MonthlyExpenseComparator> monthlyExpenseList;
    }
    
    public class MonthlyExpenseComparator implements Comparable{
        
        @AuraEnabled
        public MonthlyExpenseWrapper oppy;    

        public MonthlyExpenseComparator(MonthlyExpenseWrapper oppy) {
            this.oppy = oppy;
        }    
        
        public Integer compareTo(Object compareTo) {
            MonthlyExpenseComparator compareToOppy = (MonthlyExpenseComparator) compareTo;        
            Integer returnValue = 0;
            if (oppy.MonthDate > compareToOppy.oppy.MonthDate) {
                returnValue = 1;
            } else if (oppy.MonthDate < compareToOppy.oppy.MonthDate) {
                returnValue = -1;
            }        
            return returnValue;
        }
    }

    public class MonthlyExpenseWrapper {

        @AuraEnabled
        public Decimal Balance;
        @AuraEnabled
        public Date MonthDate;
        @AuraEnabled
        public Decimal SpentAmount;
        @AuraEnabled
        public Decimal Reminder;
    }
    
    /* Get overall data */
    @AuraEnabled
    public static MonthlyExpense getMonthlyExpense(String conId, Integer selectedDate, String office){
        List<MonthlyExpenseWrapper> monthlylist = new List<MonthlyExpenseWrapper>();
        Contact con = [SELECT Admin__c FROM Contact WHERE Id =: conId];
        
        /* If contact Id undefined get data for all office (Admin) */
        if (!con.Admin__c || office == null) {
            List<MonthlyExpense__c> expenseList = [
                SELECT Balance__c, MonthDate__c, SpentAmount__c, Reminder__c 
                FROM MonthlyExpense__c WHERE Keeper__c =:conId 
                AND CALENDAR_YEAR(MonthDate__c) =: selectedDate
            ];

            for (MonthlyExpense__c exp : expenseList) {
                MonthlyExpenseWrapper m = new MonthlyExpenseWrapper();
                m.Balance = exp.Balance__c;
                m.MonthDate = exp.MonthDate__c;
                m.SpentAmount = exp.SpentAmount__c;
                m.Reminder = exp.Reminder__c;
                monthlylist.add(m);
            }

        } else {
            List<AggregateResult> aggregate = [
                SELECT SUM(Balance__c) balance, MonthDate__c, SUM(SpentAmount__c) amount, SUM(Reminder__c) reminder 
                FROM MonthlyExpense__c WHERE Keeper__r.Office__c =: office 
                AND CALENDAR_YEAR(MonthDate__c) =: selectedDate
                GROUP BY MonthDate__c
            ];

            for (AggregateResult agg : aggregate) {
                MonthlyExpenseWrapper m = new MonthlyExpenseWrapper();
                m.Balance = (Decimal) agg.get('balance');
                m.MonthDate = Date.valueOf(agg.get('MonthDate__c'));
                m.SpentAmount = (Decimal) agg.get('amount');
                m.Reminder = (Decimal) agg.get('reminder');
                monthlylist.add(m);
            }
        }

        List<MonthlyExpenseComparator> oppyList = new List<MonthlyExpenseComparator>();         
        
        MonthlyExpense monthlyExpense = new MonthlyExpense();
        
        monthlyExpense.totalAmount = 0;
        monthlyExpense.totalIncome = 0;
        monthlyExpense.Balance = 0;
        
        List<MonthlyExpenseWrapper> mes = new List<MonthlyExpenseWrapper>();
        for (MonthlyExpenseWrapper mx: monthlylist){
            monthlyExpense.totalAmount += mx.SpentAmount; 
            monthlyExpense.totalIncome += mx.Balance;
            monthlyExpense.Balance += mx.Reminder;
            MonthlyExpenseWrapper me = new MonthlyExpenseWrapper();
            me.MonthDate = mx.MonthDate;
            mes.add(me);
            oppyList.add(new MonthlyExpenseComparator(mx));
        }        
        
        /* Create empty monthly expenses if necessary */
        for (Integer i = 1; i<=12; i++){ 
            Date dt = Date.newInstance(selectedDate, i, 01);                
            MonthlyExpenseWrapper monthly = new MonthlyExpenseWrapper(); 
            monthly.MonthDate = dt;

            if (mes.size() == 0) {
                oppyList.add(new MonthlyExpenseComparator(monthly));
            }

            Integer x = 0;
            for (MonthlyExpenseWrapper m : mes) {
                if (m.MonthDate != monthly.MonthDate) {
                    x++;
                }
                if (x == mes.size()) {
                    x = 0;
                    oppyList.add(new MonthlyExpenseComparator(monthly));
                }
            }
        }

        oppyList.sort();
        monthlyExpense.monthlyExpenseList = oppyList;
        return monthlyExpense;
    }
    
    public class Expenses{
        @AuraEnabled
        public date cardDateUnique;
        @AuraEnabled
        public Decimal totalSum;
        @AuraEnabled
        public List<ExpenseCard__c> expenseCardList;
    }
    
    /* Get data per month*/
    @AuraEnabled
    public static List<Expenses> getExpenseCard(Date selectedDate, String conId, String office){
        
        List<Expenses> expenses = new List<Expenses>();
        Set<Date> dates = new Set<Date>();
        List<ExpenseCard__c> expenseCards = new List<ExpenseCard__c>();
        Contact con = [SELECT Admin__c FROM Contact WHERE Id =: conId];

        /* If contact is Admin get data for all office */
        if (!con.Admin__c) {
            for(AggregateResult ar : [
                SELECT CardDate__c FROM ExpenseCard__c 
                WHERE CardKeeper__c =: conId AND MonthlyExpense__r.MonthDate__c =: selectedDate 
                GROUP BY CardDate__c ORDER BY CardDate__c ASC
            ]){
                dates.add((Date) ar.get('CardDate__c'));
            }

            expenseCards = [
                SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c 
                WHERE CardKeeper__c =:conId AND CardDate__c IN :dates 
                ORDER BY CardDate__c ASC
            ];
        } else {
            for(AggregateResult ar : [
                SELECT CardDate__c FROM ExpenseCard__c 
                WHERE CardKeeper__r.Office__c =: office AND MonthlyExpense__r.MonthDate__c =: selectedDate 
                GROUP BY CardDate__c ORDER BY CardDate__c ASC
            ]){
                dates.add((Date) ar.get('CardDate__c'));
            }
            expenseCards = [
                SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c 
                WHERE CardKeeper__r.Office__c =: office AND CardDate__c IN :dates 
                ORDER BY CardDate__c ASC
            ];
        }
        
        if (dates == null || dates.isEmpty()){
            return null;
        }
        
        if(expenseCards != null){
            for (Date dd : dates){
                List<ExpenseCard__c> ex = new List<ExpenseCard__c>();
                Decimal summ = 0;
                Expenses exp = new Expenses();
                for(ExpenseCard__c xx : expenseCards){        
                    if(dd == xx.CardDate__c){
                        ex.add(xx);
                        summ = summ + xx.Amount__c;
                    }        
                }
                exp.cardDateUnique = dd;
                exp.totalSum = summ;
                exp.expenseCardList = ex;
                expenses.add(exp);
            }
        } else {
            return null;
        }
        return expenses;        
    }
    
    @AuraEnabled
    public static void saveExpenseCard(String conId, Integer amount, Date cardDate, String description, String office){
        try {
            Contact con = [SELECT Admin__c, Office__c FROM Contact WHERE Id =: conId];
            if (con.Admin__c && con.Office__c != office && office != null) {
                String lastNameGen = ('AdditionalContact' + office).deleteWhitespace();
                Contact additCon = [SELECT Id FROM Contact WHERE LastName =: lastNameGen];
                conId = additCon.Id;
            }

            ExpenseCard__c card = new ExpenseCard__c(
                CardKeeper__c = conId, Amount__c = amount, CardDate__c = cardDate, Description__c = description
            );
            insert card;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteExpenseCard(String expenseCardId){
        try {
            ExpenseCard__c ec = [SELECT Id FROM ExpenseCard__c WHERE Id =: expenseCardId];
            delete ec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void addBalance(String selectedDate, String conId, Integer amount, String office){
        try {
            Contact con = [SELECT Admin__c, Office__c FROM Contact WHERE Id =: conId];
            if (con.Admin__c && con.Office__c != office) {
                String lastNameGen = ('AdditionalContact' + office).deleteWhitespace();
                Contact additCon = [SELECT Id FROM Contact WHERE LastName =: lastNameGen];
                conId = additCon.Id;
            }

            Date month = Date.valueOf(selectedDate);
            List<MonthlyExpense__c> expenses = [
                SELECT Balance__c FROM MonthlyExpense__c WHERE MonthDate__c =: month AND Keeper__c =: conId
            ];
            if (expenses.size() != 0){
                expenses[0].Balance__c += amount;
                update expenses;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateExpenseCard(String cardId, String description, String amount) {
        try {
            ExpenseCard__c card = [SELECT Id, Description__c, Amount__c FROM ExpenseCard__c WHERE Id =: cardId];
            if (description != null) {
                card.Description__c = description;
            }
            if (amount != null) {
                card.Amount__c = Integer.valueOf(amount);
            }
            update card;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}