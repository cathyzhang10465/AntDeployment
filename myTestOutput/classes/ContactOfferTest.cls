/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ContactOfferTest {

    static testMethod void myUnitTest() {
    	List<Account> accts = new List<Account>();
        List<Contact> cons = new List<Contact>();
        List<Offer__c> offers = new List<Offer__c>();
        List<Offer_Result__c> offerresults = new List<Offer_Result__c>();
    	for(Integer i=0; i<10; i++) {
    	    Account testAct = new Account(Name='Test Account ' + i);
    	    accts.add(testAct);
    	    Contact con = new contact(account=testAct, firstname='Cathy '+i,LastName='Zhang '+i);
    	    cons.add(con);
    	    Offer__c offer = new Offer__c(description__c='offer '+i, Original_Units_Available__c=100, Valid_Through__c=date.today()+15);
    	    offers.add(offer);
    	    Offer_Result__c offerresult = new Offer_Result__c(contact__c = con.id, offer__c=offer.id);
    	    offerresults.add(offerresult);
    	}
    	
    	if(accts.size()>0)
    	   insert accts;
        if(cons.size()>0)   
    	   insert cons;
    	if(offers.size()>0)   
    	   insert offers;
    	if(offerresults.size()>0)      //test insert
    	   insert offerresults;
    	
    	//system.aassertEquals(offerresults.size(), 10);
    	//test update
    	List<Offer_Result__c> offerresultsupdate = new List<Offer_Result__c>();
    	for(Integer i=0; i<10; i++) {
    	     offerresults[i].contact__c = cons[9-i].id;
    	     offerresultsupdate.add(offerresults[i]);
    	}
    	if(offerresultsupdate.size()>0) {
    	   update offerresultsupdate;
            List<Offer_Result__c> queryresults = new List<Offer_Result__c>();
            queryresults = [select id from offer_result__c];
    	   system.assertEquals(queryresults.size(), 10);
    	   delete offerresultsupdate;     // test delete;
    	 
    	}
    	   
        	   
    }
    
      static testMethod void TestController() {
      	  Account testAct = new Account(Name='Test Account');
      	  insert testAct;
      	  Contact con = new contact(account=testAct, firstname='Cathy',LastName='Zhang');
      	  insert con;
      	  Offer__c offer = new Offer__c(description__c='offer1', Original_Units_Available__c=100, Valid_Through__c=date.today()+15);
      	  insert offer;
      	  Offer_Result__c orc = new Offer_Result__c(offer__c = offer.id, contact__c=con.id);
      	  insert orc;
      	  
      	  
      	  ApexPages.StandardController std = new ApexPages.StandardController(con);
      	  ContactExtController contactext = new ContactExtController(std);
      	  PageReference pageRef = Page.ViewOffers;
      	  ApexPages.currentPage().getParameters().put('id',con.id);
      	  
      	  contactext.offerid = offer.id;
      	  contactext.accept();
      	  contactext.done();
      	  
      	  
      }
    
    
}