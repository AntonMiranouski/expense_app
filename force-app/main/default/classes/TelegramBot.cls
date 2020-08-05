@RestResource(urlMapping='/ttest')
global class TelegramBot {

    @HttpPost
    global static String postContact(){
        String req = RestContext.request.requestBody.toString();

        if (req.startsWith('{"login')) {
            Credentials cds = (Credentials) JSON.deserializeStrict(req, Credentials.class);
            List<Contact> contacts = [
                SELECT Id, Email, Password__c, Office__c, Admin__c
                FROM Contact
                WHERE email = :cds.login 
            ];

            if (contacts.isEmpty()) {
                return 'No user with this email was found';
            }
        
            for (Contact c : contacts) {
                if (c.Password__c.equals(cds.pass)) {
                    return 'Id' + c.Id;
                } else {
                    return 'Invalid password';
                }
            }
            return 'No user with this email was found';
        } 

        else if (req.startsWith('{"id')) {
            ContactId c = (ContactId) JSON.deserializeStrict(req, ContactId.class);
            ExpensesPageController.MonthlyExpense expense = 
                ExpensesPageController.getMonthlyExpense(c.id, Date.today().year(), null);
            return 'Balance' + expense.Balance;
        } 
        
        else if (req.startsWith('{"day')) {
            NewCard nc = (NewCard) JSON.deserializeStrict(req, NewCard.class);
            String dt = DateTime.newInstance(nc.day.year(), nc.day.month(), nc.day.day()).format('yyyy-MM-dd');
            try {
                ExpensesPageController.saveExpenseCard(nc.id, nc.amount, nc.day, nc.description, null);
                return 'A new card for ' + dt + ' has been successfully created';
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        
        else {
            return 'Bad request';
        }
    }

    public class Credentials {
        public String login;
        public String pass;
    }

    public class ContactId {
        public String id;
    }

    public class NewCard {
        public Date day;
        public Integer amount;
        public String description;
        public String id;
    }
}