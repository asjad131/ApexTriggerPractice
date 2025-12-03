public class OpportunityTriggerHandler {
    
    
    //Rollup opportunity Amount
    public static void updateOpportunityAmount(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        if (isDelete) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else if (isUpdate) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else {
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : [
            SELECT AccountId, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountsToUpdate.add(new Account(
                Id = (Id) ar.get('AccountId'),
                Total_Opportunity_Amount__c  = (Decimal) ar.get('totalAmount')
            ));
        }

        update accountsToUpdate;
    }
    //update Account with MAX opportunity Name 
    public static void updateMaxOpportunityName(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        if (isDelete) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else if (isUpdate) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else {
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }

        List<Account> accountsToUpdate = [Select Max_Opportunity_Name__c,(select Id, Name, Amount from Opportunities
                                                                         where Amount != NULL ORDER BY Amount DESC LIMIT 1) 
                                          from Account where Id IN:accountIds];
        List<Account> lstAcc = new List<Account>();
        
        for(Account acc: accountsToUpdate){
            acc.Max_Opportunity_Name__c = acc.Opportunities[0].Name;
            lstAcc.add(acc);
            
        }

        update lstAcc;
    }
    //upsert Task on stage change
    public static void upsertTask(List<Opportunity> lstOpp, Map<Id, Opportunity> oldMap){
        
        Set<Id> oppIds = new Set<Id>();
        
        if(!lstOpp.isEmpty()){
            for(Opportunity opp: lstOpp){
                
                if(opp.StageName != oldMap.get(opp.id).StageName){
                    oppIds.add(opp.Id);
                }
            }           
        }
        
        List<Task> lstTask = [Select Id, WhatId, Description from Task where WhatId IN:oppIds ];
        Map<Id, Task> mapTask = new Map<Id,Task>();
        List<Task> lstToUpsert = new List<Task>();
        
        for (Task tsk: lstTask){
            
            mapTask.put(tsk.WhatId, tsk);
        }
        
        for (Opportunity objOpp : lstOpp){
            
            if(objOpp.StageName != oldMap.get(objOpp.id).StageName){
            Task newTask;
           
            
            if(mapTask.containsKey(objopp.Id)){
                newTask= maptask.get(objOpp.Id);
                newTask.Description = 'Opportunity Stage has been updated to ' + objOpp.StageName;
                lstToUpsert.add(newTask);
            }
            else{
                newTask = new Task();
                newTask.Subject = 'Opportunity Stage Updated.';
                newTask.Description = 'Opportunity Stage has been updated to ' + objOpp.StageName;
                newTask.OwnerId = UserInfo.getUserId();
                newTask.WhatId = objOpp.Id;
                newTask.Status = 'Not Started';
                lstToUpsert.add(newTask);
            }    
        }
        }
        upsert lstToUpsert;
        
        
    }
    //update Account Status
    public static void updateAccountStatus(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        if (isDelete) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else if (isUpdate) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else {
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }
        
        if(!accountIds.isEmpty()){
            
            Map<Id, List<Opportunity>> accMap = new Map<Id, List<Opportunity>>();
            List<Account> accListToUpdate = new List<Account>();
            
            for ( Opportunity  objOpp : [Select Id, AccountId, StageName from Opportunity where AccountId IN: accountIds])
            {
                if(!accMap.containsKey(objOpp.AccountId)){
                    accMap.put(objOpp.AccountId, new List<Opportunity>());
                }
                accMap.get(objOpp.AccountId).add(objOpp);   
            }
            
            for(Id ids : accMap.keyset()){
                List<Opportunity> accOpps = accMap.get(ids);
                
                if(!accOpps.isEmpty()){
                    Boolean allOppsClosed = true;
                    
                    for (Opportunity opp: accOpps){
                        
                        if(!opp.StageName.equals('Closed Won')){
                            allOppsClosed=false;
                            break;
                        }
                    }
                    
                    if(allOppsClosed){
                        accListToUpdate.add(new Account(Id= ids, Account_Status__c ='Closed'));
                    }
                    else{
                        accListToUpdate.add(new Account(Id= ids, Account_Status__c ='Open'));
                    }
                }
            
                
            }
            update accListToUpdate;
        }   
    }

        public static void updateMaxOpportunityAmount(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        if (isDelete) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else if (isUpdate) {
            for (Opportunity opp : oldMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        } else {
            for (Opportunity opp : newMap.values()) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : [
            SELECT AccountId, MAX(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]) {
            accountsToUpdate.add(new Account(
                Id = (Id) ar.get('AccountId'),
                Maximum_Opportunity_Amount__c  = (Decimal) ar.get('totalAmount')
            ));
        }

        update accountsToUpdate;
    }

}