public class caseTriggerHandler {
    
    public static void updateLatestCaseNumber(List<Case> newCase){
        
            Set<Id> accIds = new Set<Id>();
                
        	if ( !newCase.isEmpty())
            {            
         		for (Case c: newCase)
         		{
					accIds.add(c.AccountId);                            
         		}                                
          	}
        
        Map<Id,Account> accMap = new Map<Id,Account> ([select Id,Latest_Case_Number__c  from Account where Id IN: accIds]);
        List<Account> accsToUpdate = new List<Account>();

        if ( !newCase.isEmpty()){
            for (Case cs: newCase)
            { 
            Account acc = accMap.get(cs.AccountId);
            acc.Latest_Case_Number__c= cs.CaseNumber;
            accsToUpdate.add(acc);
           }
        }
        if(!accsToUpdate.isEmpty()){
            update accsToUpdate;
        }
        

      }
    //update case count on account for each status
    public static void updateCaseCount(Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isDelete, Boolean isUpdate){
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Integer> newCaseMap = new map<Id, Integer>();
        Map<Id, Integer> workingCaseMap = new map<Id, Integer>();
        Map<Id, Integer> escalatedCaseMap = new map<Id, Integer>();
        Map<Id,Account> accsToUpdate = new Map<Id,Account>();
        
        if (isDelete) {
            for (Case c : oldMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        } else if (isUpdate) {
            for (Case c : oldMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
            for (Case c : newMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        } else {
            for (Case c : newMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        }
        
        if(!accountIds.isEmpty()){
            
            for(Account acc : [Select Id, Number_Of_New_Cases__c ,Number_Of_Working_Cases__c , Number_Of_Escalated_Cases__c ,
                              (select Id, status from Cases) from Account where Id IN:accountIds])
            {
                newCaseMap.put(acc.Id, 0);
                workingCaseMap.put(acc.Id, 0);
                escalatedCaseMap.put(acc.Id, 0);
                
                for (Case caseobj: acc.Cases){
                    
                    if(caseobj.Status == 'New'){
                        newCaseMap.put(acc.Id, newCaseMap.get(acc.Id)+1);
                      }
                    else if(caseobj.Status == 'Working'){
                        workingCaseMap.put(acc.Id, workingCaseMap.get(acc.Id)+1);
                      }
                    else if(caseobj.Status == 'Escalated'){
                        escalatedCaseMap.put(acc.Id, escalatedCaseMap.get(acc.Id)+1);
                      }
                }
                acc.Number_Of_New_Cases__c = newCaseMap.get(acc.Id);
                acc.Number_Of_Working_Cases__c = workingCaseMap.get(acc.Id);
                acc.Number_Of_Escalated_Cases__c = escalatedCaseMap.get(acc.Id);
                
                accsToUpdate.put(acc.Id, acc);
            }
            If(!accsToUpdate.isEmpty()){
            update accsToUpdate.values();
                }
        }        
        
    }
    //update account rating based on number of closed cases
    public static void updateAccountRating(Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isDelete, Boolean isUpdate){
                
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Decimal> caseCountMap = new Map<Id, Decimal>();
        List<Account> lstAccsToUpdate = new List<Account>();
        
        if (isDelete) {
            for (Case c : oldMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        } else if (isUpdate) {
            for (Case c : oldMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
            for (Case c : newMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        } else {
            for (Case c : newMap.values()) {
                if (c.AccountId != null) accountIds.add(c.AccountId);
            }
        }
        
        for (AggregateResult ar : [
            SELECT AccountId, Count(Id) totalCount
            FROM Case
            WHERE AccountId IN :accountIds
            AND Status = 'Closed'
            GROUP BY AccountId
        ]) {
            caseCountMap.put((Id) ar.get('AccountId'), (Decimal) ar.get('totalCount'));
           }
        
        for(Id ids :caseCountMap.keyset()){
            String strRating = '';
            
                if(caseCountMap.get(ids) < 2){
                    strRating = 'Cold';
                }else if(caseCountMap.get(ids) < 5){
                    strRating = 'Warm';                    
                }else if(caseCountMap.get(ids) > 5){
                     strRating = 'Hot';
                }
            
            Account acc = new Account();
            acc.id = ids;
            acc.Rating = strRating;
            lstAccsToUpdate.add(acc);
            
        }
        if(!lstAccsToUpdate.isEmpty()){
            update lstAccsToUpdate;
            }
        
        }

        public static void createTask(List<Case> newCases, Map<Id,Case> oldMap){

            Set<Id> accIds = new Set<Id>();
           
            for(Case c: newCases)
            {  
                if(oldMap != null)
                {
                    if(c.Create_Task__c == true && oldMap.get(c.Id).Create_Task__c != true){
                        accIds.add(c.AccountId);
                    }
                }
                else
                {
                    if(c.Create_Task__c == true)
                    {
                        accIds.add(c.AccountId);
                    }
                }
           }

          Map<Id,Id> accConMap = new Map<Id,Id>();
          List<Contact> conList = [SELECT Id, AccountId
                                    FROM Contact
                                    WHERE AccountId IN :accIds
                                    AND Primary_Contact__c = true
                                    LIMIT 1]; 
          
        for(Contact con: conList){
            accConMap.put(con.AccountId,con.Id);
          }
        
          List<Task> lstTask = new List<Task>();
        for(Case cs: newCases){
            if(cs.Create_Task__c == true && accConMap.containsKey(cs.AccountId) ){

                Task task = new Task();
                task.Subject = 'Follow Up task';
                task.Status = 'Not Started';
                task.WhoId = accConMap.get(cs.AccountId);
                task.WhatId =cs.AccountId;
                lstTask.add(task);
            }
        }
        insert lstTask;

        }

        public static void relateCaseToContact(List<Case> newCases){

            Set<String> caseEmails = new Set<String>();

            for (Case c: newCases){

                if(c.Supplied_Email__c != null){
                    caseEmails.add(c.Supplied_Email__c);
                }
            }
            
            List<Contact> conList = [Select Id, Email from Contact where Email IN: caseEmails ];
            Map<String, Contact> conEmailMap = new Map<String,Contact>();
            Map<String,Id> emailToContactId = new Map<String, Id>();
            List<Contact> lstContactsToBeInserted= new List<Contact>();

            for(Contact con: conList){
                conEmailMap.put(con.Email,con);
            }

            for (Case ca: newCases){

                if(ca.Supplied_Email__c != null){
                    
                    if (conEmailMap.containsKey(ca.Supplied_Email__c)){
                        Contact existingContact = conEmailMap.get(ca.Supplied_Email__c);
                        emailToContactId.put(ca.Supplied_Email__c,existingContact.Id);

                    }else{
                        Contact con = new Contact();
                        con.LastName = 'Test';
                        con.Email= ca.Supplied_Email__c;
                        lstContactsToBeInserted.add(con);
                    }
                }
            }

            insert lstContactsToBeInserted;
            
            for(Contact newCon : lstContactsToBeInserted){
                 emailToContactId.put(newCon.Email,newCon.Id);

            }
             for (Case csr: newCases){

                if(emailToContactId.containsKey(csr.Supplied_Email__c)){
                    csr.ContactId = emailToContactId.get(csr.Supplied_Email__c);

                }

             }


        }
             
}