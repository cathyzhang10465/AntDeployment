global class BatchOpportunityEmailMask implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

    public String query = 'Select Id, OWNER_EMAIL__C, PSR_EMAIL__C, RSM_EMAIL__C from Opportunity';
    public String mask  = '.spw';
    public Integer total = 0;
    public Integer failed = 0;
    public Datetime startTime;
    public Datetime endTime;

    global BatchOpportunityEmailMask() {
        startTime = Datetime.now();
    }
    
    global BatchOpportunityEmailMask(String msk) {
        this.mask = msk;
        startTime = Datetime.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> scope) {

       List<Opportunity> lsToUpdate = new List<Opportunity>();
       Boolean updated = false;
       for(Opportunity o : scope){
          if (o.OWNER_EMAIL__C != null){
            o.OWNER_EMAIL__C += this.mask;
            updated = true;
          }
          if (o.PSR_EMAIL__C != null){
            o.PSR_EMAIL__C  += this.mask;
            updated = true;
          }
          if (o.RSM_EMAIL__C != null){
            o.RSM_EMAIL__C  += this.mask;
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
                be.ObjectType__c = 'Opportunity';
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
        BatchOpportunityEmailMask batch = new BatchOpportunityEmailMask();
        Database.executeBatch(batch, 200);
    }
        
    global void run() {
        BatchOpportunityEmailMask batch = new BatchOpportunityEmailMask(mask);
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
      br.ObjectType__c = 'Opportunity';
      br.Failed__c   = this.failed;
      br.Total__c   = this.total;
      insert br;

      //BatchContactEmailMask batch = new BatchContactEmailMask(mask);
      //batch.run();
    }
}