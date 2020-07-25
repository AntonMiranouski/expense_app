public with sharing class LoginController {
    
    @AuraEnabled
    public static String login(String email, String password) {
        List<Contact> contacts = [
            SELECT Id, Email, Password__c, Office__c, Admin__c
            FROM Contact
            WHERE email = :email 
        ];

        if (contacts.isEmpty()) {
            return 'No user with this email was found';
        }
        
        for (Contact c : contacts) {
            if (c.Password__c.equals(password)) {
                return generateToken(c.Id);
            } else {
                return 'Invalid password';
            }
        }
        return 'No user with this email was found';
    }

    private static String generateToken(Id userId) {
        return JSON.serialize([
            SELECT Id, Email, Office__c, Admin__c
            FROM Contact
            WHERE Id = :userId
        ]);
    }
}