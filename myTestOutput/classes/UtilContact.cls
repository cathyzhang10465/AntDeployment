public class UtilContact {

    public static Id currUser;

    static {
              currUser = Userinfo.getUserId(); 
    }
    public static void contactToLead(List<Contact> lstC){

        List<Lead> lstLead = new List<Lead>();
        for (Contact c : lstC){
            Lead l = new Lead();
            oneConToLead(c, l);
            lstLead.add(l);
        }
        insert lstLead;
    } 

    public static void oneConToLead(Contact c, Lead l){
 
        l.Company = c.Account.Name;
        l.Description = c.Description;
        l.DoNotCall = c.DoNotCall;
        l.Email     = c.Email;
        l.HasOptedOutOfEmail = c.HasOptedOutOfEmail;
        l.Fax = c.Fax;
        l.HasOptedOutOfFax = c.HasOptedOutOfFax;
        l.FirstName = c.FirstName;
        l.LastName = c.LastName;
        l.LeadSource = c.LeadSource;
        l.MobilePhone = c.MobilePhone;
        l.Phone = c.Phone;
        l.Title = c.Title;
        l.City = c.MailingCity;
        l.State = c.MailingState;
        l.Country = c.MailingCountry;
        l.PostalCode = c.MailingPostalCode;
        l.street = c.MailingStreet;

    }
    
     public static void InsertOneLead(Contact c, Lead l){
       oneConToLead(c,l);
       insert l;
     }

   
   
    
    // remove one signle contact role
 
    public static void removeContactRole(Id oldAcctid, Id contactId) {
        Map<Id, Id> mapConToAcct = new Map<Id, Id>();
        mapConToAcct.put(contactId, oldAcctid);
        removeContactRole_bulk(mapConToAcct);
    }
   
   
   
   // Bulk mode for trigger usage. Map key to value: current contactid vs. old account id
   
   public static void removeContactRole_bulk(Map<Id,Id> contactAcctMap) {
    List<Opportunity> opptys = new List<Opportunity>();
    List<OpportunityContactRole>  OppContactRolesDel =  new List<OpportunityContactRole>();
    Messaging.SingleEmailMessage[] outmails = new Messaging.SingleEmailMessage[]{};
    Set<Id> accoutids = new Set<Id>();
    
    
     for(Id i : contactAcctMap.keyset() ) {
         accoutids.add(contactAcctMap.get(i)); 
     }
     
     opptys = [Select AccountId, owner.email, ownerid, (Select Id, OpportunityId, ContactId From OpportunityContactRoles)
     From Opportunity 
     where AccountId in :accoutids and StageName!='Closed/Won' and StageName!='Closed/Lost'];
     if(opptys.size()>0)  {
        for(Id contactid : contactAcctMap.keyset() ) {
          for (Opportunity opp : opptys) {
            for(OpportunityContactRole ocr : opp.OpportunityContactRoles) {
               if( contactid  == ocr.contactid ) {
                  OppContactRolesDel.add(ocr);
                  
                  if(currUser != opp.ownerid) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(opp.owner.email==null ||opp.owner.email=='')
                       opp.owner.email='mikizhang@yahoo.com';
                    String[] toAddresses = new String[] {opp.owner.email}; 
                    mail.setToAddresses(toAddresses);
                    mail.setReplyTo('support@linkedin.com');
                    mail.setSenderDisplayName('linkedin Support');
                    mail.setSubject('Opportunity : ' + opp.Id + ' ContactRole ' + ocr.contactid + ' is removed');
                    mail.setPlainTextBody('Your Opportunity: ' + opp.Id +' contact role' + ocr.id + ' with contact ' + ocr.contactid +' has changed.');
                    outmails.add(mail);
                  }
                  
               }
            }
          }
       }
     }
     
     if(OppContactRolesDel.size()>0)
        delete OppContactRolesDel;
     
     if(outmails.size()>0)
       Messaging.sendEmail(outmails);
           
      
   }
   
   @future
   public static void MarkFirstContact(Set<Id> accountids) {
      List<Contact> conUpdateList = new List<Contact>();
       for(List<Account> accts : [Select name, (select id, firstcontact__c from contacts order by createddate asc) 
       from Account where id in :accountids])
       {
          for(Account a : accts) {
            for(integer i=0; i<a.contacts.size(); i++) {
                if(i==0) {
                a.contacts[0].firstcontact__c = true;
                } else {
                a.contacts[i].firstcontact__c = false;
                }
                
            }
            conUpdateList.addall(a.contacts);
           // update a.contacts;
           }  // per account
          
       }
       update conUpdateList;
   }
}