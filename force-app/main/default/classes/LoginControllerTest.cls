@isTest
private class LoginControllerTest {
    
    @isTest
    static void test(){
		Contact user = new Contact(
            LastName = 'user', Email = 'user@user.by', Password__c = '123'
        );
        insert user;
        
        Contact admin = new Contact(
            LastName = 'admin', Email = 'admin@admin.by', Password__c = '123', Admin__c = true
        );
        insert admin;
        
        String userLogin = LoginController.login('user@user.by', '123');
        String badPassword = LoginController.login('user@user.by', '111');
        String badEmail = LoginController.login('u@u.by', '111');
        String adminLogin = LoginController.login('admin@admin.by', '123');
        
        List<Object> desUserLogin = (List<Object>) JSON.deserializeUntyped(userLogin);
        Map<String, Object> m1 = (Map<String, Object>) desUserLogin[0];
        Object o1 = (Object) m1.get('Admin__c');
		System.assertEquals(false, o1);
		
        List<Object> desAdminLogin = (List<Object>) JSON.deserializeUntyped(adminLogin);
        Map<String, Object> m2 = (Map<String, Object>) desAdminLogin[0];
        Object o2 = (Object) m2.get('Admin__c');
		System.assertEquals(true, o2);
        
        System.assertEquals('No user with this email was found', badEmail);
        System.assertEquals('Invalid password', badPassword);
    }
}