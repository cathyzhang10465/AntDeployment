@isTest
private class FirstContactTest {

    static testMethod void myUnitTest() {
        List<Account> accts = new List<Account>();
      

      for(Integer i=0; i<10; i++) {
          Account testAct = new Account(Name='Test Account ' + i);
          accts.add(testAct);
      }
      insert accts;
      
      
      Test.startTest();
      Integer j = 0;
      List<Contact> cons = new List<Contact>();
      for(Account aa : accts ) {
        //cons.clear();
        for(Integer i=0; i<10; i++) {
          j++;
          Contact con = new contact(accountId=aa.Id, firstname='Cathy '+j,LastName='Zhang '+j);
          cons.add(con);
        }        
      }
     insert cons;

     Test.stopTest();

      
     List<Contact> testCons = [select name, firstcontact__c  from contact where firstContact__c = true];
     
      
     System.assertEquals(100, cons.size());
     System.assertEquals(10, accts.size());
     System.assertEquals(10, testCons.size());
     
     delete testCons;
             
    }
    
     
    
}