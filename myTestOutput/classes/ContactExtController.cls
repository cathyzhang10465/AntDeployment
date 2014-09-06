public with sharing class ContactExtController {
    
     public Id cid {get;set;}
     public Id offerid {get;set;}
     public Contact Con {get;set;}
   //  public List<Offer__c> validoffers {get;set;}
    
     public ContactExtController (ApexPages.StandardController controller) {
      
        this.Con = (Contact)controller.getRecord();
        this.cid = controller.getId();
       
        
      }
      
      public List<Offer__c> getvalidoffers() {
          
          List<Offer__c> validoffers = new List<Offer__c>();
          validoffers = [select description__c, Valid_Through__c, Current_Units_Available__c from offer__c where
           Current_Units_Available__c>0];
          
          return validoffers;
        
      }
      
      public pagereference done() {
        pagereference pg = new pagereference('/'+cid);
        pg.setredirect(true);
        
        return pg;
        
      }
      
      public pagereference accept() {
        Offer__c thisoffer = new Offer__c();
        if(offerid == null){
        offerid = Apexpages.currentPage().getParameters().get('sf_id');
        }
        system.debug('offer id ' + offerid);
        thisoffer = [select Acceptances__c, Original_Units_Available__c, Current_Units_Available__c from offer__c where id = :offerid];
        system.debug('Original_Units_Available__c OLD is ' + thisoffer.Original_Units_Available__c);
        system.debug('Acceptances__c OLD is ' + thisoffer.Acceptances__c);
        system.debug('Current_Units_Available__c OLD is ' + thisoffer.Current_Units_Available__c );
     
        if(thisoffer.Current_Units_Available__c<=0) {
        
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Offer is Oversold'));
           return null;
        }
         system.debug('Original_Units_Available__c NEW is ' + thisoffer.Original_Units_Available__c);
        system.debug('Acceptances__c NEW is ' + thisoffer.Acceptances__c);
        system.debug('Current_Units_Available__c NEW is ' + thisoffer.Current_Units_Available__c );
      
        Offer_result__c orc = new Offer_result__c();
        orc.contact__c = this.cid;
        orc.offer__c = offerid;
        insert orc;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Offer is accepted'));
        return null;
     //   pagereference pg = new pagereference('/apex/ViewOffersMessage?id='+cid);
     //   pg.setredirect(true);
     //   return pg;
      }
      
      
}