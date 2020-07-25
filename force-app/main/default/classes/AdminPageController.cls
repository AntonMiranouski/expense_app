public with sharing class AdminPageController {

    public class MonthlyExpense {
        
        @AuraEnabled
        public List<OfficeWrapper> officeList;
        @AuraEnabled
        public Decimal summ;
        @AuraEnabled
        public List<DataWrapper> dataList;
    }

    public class OfficeWrapper {
        
        @AuraEnabled
        public String officeName;
        @AuraEnabled
        public Decimal totalAmount;
        @AuraEnabled
        public Decimal monthlyAverage;
        @AuraEnabled
        public Decimal balanceNow;
        @AuraEnabled
        public Decimal totalSumm;
    }

    public class DataWrapper {
        
        @AuraEnabled
        public String month;
        @AuraEnabled
        public List<Decimal> monthAmount;
    }

    @AuraEnabled
    public static MonthlyExpense getMonthlyExpense(Integer selectedDate) {

        List<String> contactOfficeList = new List<String>();
        Schema.DescribeFieldResult fr = Contact.Office__c.getDescribe();
        List<Schema.PicklistEntry> pe = fr.getPicklistValues();
        for (Schema.PicklistEntry value : pe) {
            contactOfficeList.add(value.getValue());
        }

        List<Contact> monthlylist = [
            SELECT Id, Office__c, (
                SELECT id, Balance__c, MonthDate__c, SpentAmount__c, Reminder__c
                FROM MonthlyExpenses__r
                WHERE CALENDAR_YEAR(MonthDate__c) = :selectedDate
            )
            FROM Contact
            WHERE Admin__c = false AND Office__c IN :contactOfficeList
            ORDER BY Office__c ASC
        ];

        List<Contact> monthlylistPreviousYear = [
            SELECT Id, Office__c, (
                SELECT id, Balance__c, MonthDate__c, SpentAmount__c, Reminder__c
                FROM MonthlyExpenses__r
                 WHERE CALENDAR_YEAR(MonthDate__c) = : selectedDate - 1
            )
            FROM Contact
            WHERE Admin__c = false AND Office__c IN :contactOfficeList
            ORDER BY Office__c ASC
        ];

        MonthlyExpense monthlyExpense = new MonthlyExpense();

        List<OfficeWrapper> officeList = new List<OfficeWrapper>();
        Decimal totalSumm = 0;

        for (String office : contactOfficeList) {
            OfficeWrapper ow = new OfficeWrapper();
            ow.officeName = office;
            ow.totalAmount = 0;
            ow.balanceNow = 0;

            for (Integer i = 0; i <= 12; i++) {
                for (Contact c : monthlylist) {
                    for (MonthlyExpense__c details : c.MonthlyExpenses__r) {
                        if (Date.newInstance(selectedDate, i, 01) == details.MonthDate__c
                                && office == c.Office__c) {
                            ow.balanceNow += details.Reminder__c;
                            ow.totalAmount += details.SpentAmount__c;
                        }
                    }
                }
            }

            for (Integer i = 0; i <= 12; i++) {
                for (Contact c : monthlylistPreviousYear) {
                    for (MonthlyExpense__c details : c.MonthlyExpenses__r) {
                        if (Date.newInstance(selectedDate - 1, i, 01) == details.MonthDate__c
                                && office == c.Office__c) {
                            ow.balanceNow += details.Reminder__c;
                        }
                    }
                }
            }

            ow.monthlyAverage = ow.totalAmount / 2;
            totalSumm += ow.totalAmount;
            officeList.add(ow);
        }

        List<DataWrapper> dataList = new List<DataWrapper>();
        
        for (Integer i = 1; i <= 12; i++) {
            DataWrapper wrapper = new DataWrapper();
            DateTime dt = DateTime.newInstance(selectedDate, i, 01);
            wrapper.month = string.valueof(dt.format('MMMM'));

            wrapper.monthAmount = new List<Decimal>();
            Integer x = 0;

            for (String office : contactOfficeList) {    

                Decimal amount = 0;

                for (Contact c : monthlylist) {
                    for (MonthlyExpense__c details : c.MonthlyExpenses__r) {
                        if (Date.newInstance(selectedDate, i, 01) == details.MonthDate__c && office == c.Office__c) {
                            amount += details.SpentAmount__c;
                        }
                    }
                }
                
                wrapper.monthAmount.add(amount);

                x++;
                
                if (contactOfficeList.size() == x) {
                    Decimal sum = 0;
                    for (Integer j = 0; j < x; j++) {
                        sum += wrapper.monthAmount.get(j);
                    }
                    wrapper.monthAmount.add(sum);
                }
            }

            dataList.add(wrapper);
        }

        monthlyExpense.officeList = officeList;
        monthlyExpense.summ = totalSumm;
        monthlyExpense.dataList = dataList;

        return monthlyExpense;
    }
}