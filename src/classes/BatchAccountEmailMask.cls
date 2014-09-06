global class BatchAccountEmailMask implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

    public String query = 'Select ID, PERSONEMAIL, EMAIL__C, ORACLE_VENDOR_EMAIL__C, ORACLE_VENDOR_EMAIL_FIELD_VALUE__C, ADDITIONAL_OPPORTUNITY_EMAIL_RECIPIENT__C,Invoice_Document_Email__c from Account';
    public String mask  = '.spw';
    public Integer total = 0;
    public Integer failed = 0;
    public Datetime startTime;
    public Datetime endTime;

    global BatchAccountEmailMask() {
        startTime = Datetime.now();
    }
    
    global BatchAccountEmailMask(String msk) {
        this.mask = msk;
        startTime = Datetime.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> scope) {

       List<Account> lsToUpdate = new List<Account>();
       Boolean updated = false;
       for(Account o : scope){
          if (o.PersonEmail != null){
            o.PersonEmail  += this.mask;
            updated = true;
          }
          if (o.Oracle_Vendor_Email__c != null){
            o.Oracle_Vendor_Email__c  += this.mask;
            updated = true;
          }
          if (o.Additional_Opportunity_Email_Recipient__c != null){
            o.Additional_Opportunity_Email_Recipient__c  += this.mask;
            updated = true;
          }
          if (o.Invoice_Document_Email__c != null){
            o.Invoice_Document_Email__c  += this.mask;
            updated = true;
          }
          if (o.Email__c != null){
            o.Email__c  += this.mask;
            updated = true;
          }
          if (updated){
            lsToUpdate.add(o); 
          }
       } 
       try{
         if (lsToUpdate.size() > 0){
            Database.SaveResult[] lsr = Database.update(lsToUpdate,false);
            Integer recordid = 0;
            List<Batch_Job_Error__c> lbe = new List<Batch_Job_Error__c>();
            for (Database.SaveResult SR : lsr) {
              if (!SR.isSuccess()) {
                Batch_Job_Error__c be = new Batch_Job_Error__c();
                be.ObjectType__c = 'Account';
                be.Recordid__c   = lsToUpdate[recordid].id;
                Integer eid = 1;
                for (Database.Error err : SR.getErrors()){
                  if (be.ErrorMessage__c == null){
                    be.ErrorMessage__c = 'Error '+ eid + ': ' + err.getMessage() + '\n';

                  }
                  else{
                    be.ErrorMessage__c += 'Error '+ eid + ': ' + err.getMessage() + '\n';
                  }
                  eid++;  
                }
                lbe.add(be);
                this.failed++;
              }
              this.total++;
              recordid++;
            }

            if (lbe.size() > 0){
              insert lbe;
            }
          }        
        }
        catch(Exception e){
          system.debug('Lead Exception Message: ' + e.getMessage());
          system.debug('Lead Exception Trace: ' + e.getStackTraceString());
          throw e;
        }
    }

    global void execute(SchedulableContext SC) {
        BatchAccountEmailMask batch = new BatchAccountEmailMask();
        Database.executeBatch(batch, 200);
    }
        
    global void run() {
        BatchAccountEmailMask batch = new BatchAccountEmailMask(mask);
        Database.executeBatch(batch, 200);
    }

    global void finish(Database.BatchableContext BC) {
      // Get the ID of the AsyncApexJob representing this batch job
      // from Database.BatchableContext.
      // Query the AsyncApexJob object to retrieve the current job's information.
      AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
        :BC.getJobId()];        
      endTime = Datetime.now();

      Batch_Job_Result__c br = new Batch_Job_Result__c();
      br.Status__c     = job.Status;
      br.Start_Time__c = startTime;
      br.End_Time__c   = endTime;
      br.Apex_Job_Id__c = BC.getJobId();
      br.ObjectType__c = 'Account';
      br.Failed__c   = this.failed;
      br.Total__c   = this.total;
      insert br;

      //BatchContactEmailMask batch = new BatchContactEmailMask(mask);
      //batch.run();
    }
}