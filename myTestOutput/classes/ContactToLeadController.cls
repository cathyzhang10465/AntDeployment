public with sharing class ContactToLeadController {

    public Id contactId;
    public Contact con {get;set;}

    public ContactToLeadController (ApexPages.StandardController controller) {
      
       
        this.contactId = controller.getId();
        if( this.contactId!=null) {
        con = [select AccountId, Account.Name,Description,LastName,FirstName,
        MailingPostalCode, DoNotCall, Email, HasOptedOutOfEmail,HasOptedOutOfFax, Fax,LeadSource,MobilePhone, MailingCity,MailingState,MailingCountry,MailingStreet,
        Phone, Title from contact where id = :this.contactId];
        }
      }
    

    public PageReference revertToLead(){
        List<Contact> listCon = new List<Contact>();
      
        Lead l = new Lead();
        UtilContact.oneConToLead(con, l);
        UtilContact.removeContactRole(con.AccountId, con.Id);
        Savepoint sp = Database.setSavepoint();
        try{         
        insert l;
        delete con;
        }
        catch( Exception e ){
             Database.rollback( sp );
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());

             return null;
        }

        PageReference p = new PageReference('/' + l.id);
        p.setRedirect(true);
        return p;
    }
}