@isTest
private class ContactUpdateTest {

    static testMethod void myUnitTest() {
        List<Account> accts = new List<Account>();
        List<Contact> cons = new List<Contact>();
        List<Opportunity>  opptys = new List<Opportunity>();
        List<OpportunityContactRole> opptycontactroles = new List<OpportunityContactRole>();
        
      for(Integer i=0; i<20; i++) {
          Account testAct = new Account(Name='Test Account ' + i);
          accts.add(testAct);
      }
      insert accts;
      
      for(Integer i=0; i<20; i++) {
          Contact con = new contact(account=accts[i], firstname='Cathy '+i,LastName='Zhang '+i);
          cons.add(con);
      }
      insert cons;
      
      for(Integer i=0; i<20; i++) {
          Opportunity opp = new Opportunity(Account=accts[i],name='Test Oppty' +i, StageName='Prospect',CloseDate=DATE.TODAY().addDays(10) );
          opptys.add(opp);
      }
      insert opptys;
      
      for(Integer i=0; i<20; i++) {
          OpportunityContactRole ocr = new  OpportunityContactRole(Opportunityid=opptys[i].id, contactid=cons[i].id);
          opptycontactroles.add(ocr);
      }  
       insert opptycontactroles;  
      
      
     
      for(Integer i=0; i<20; i++) {
        cons[i].accountid = accts[19-i].id;
      }
      
      Test.startTest();

      update cons;
      
      Test.StopTest();
    //  system.assertEquals(cons.size(), 0);
     
     
             
    }
    
      static testMethod void TestController() {
          Account testAct = new Account(Name='Test Account');
          insert testAct;
          Contact con = new contact(account=testAct, firstname='Cathy',LastName='Zhang');
          insert con;
          
          
          ApexPages.StandardController std = new ApexPages.StandardController(con);
          ContactToLeadController contactext = new ContactToLeadController(std);
          PageReference pageRef = Page.ConvertContactToLead;
          ApexPages.currentPage().getParameters().put('id',con.id);
          contactext.contactId=con.id;
          contactext.revertToLead();
          
          
          
      }
    
    
}