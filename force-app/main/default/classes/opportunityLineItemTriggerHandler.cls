public class opportunityLineItemTriggerHandler {
    
    public static void createAsset(List<OpportunityLineItem> OliList){
        
        Set<Id> oppLiIds = new Set<Id>();
        
        for(OpportunityLineItem OLI: OliList){            
             oppLiIds.add(OLI.Id);  
        }
          
     List<OpportunityLineItem> exoliList = [Select Id,Name, Quantity,Opportunity.Id, Opportunity.AccountId from OpportunityLineItem where Id IN: oppLiIds];
     List<Asset> toInsert = new List<Asset>();
        
        for(OpportunityLineItem oli: exoliList)  {
            
            Asset a = new Asset();
            a.Name        = oli.Name;
            a.AccountId   = oli.Opportunity.AccountId;
            a.Quantity    = (Decimal) oli.Quantity;
            toInsert.add(a);
            
        }
        insert toInsert;
    }
    
    //update account field with OLI Count
    public static void updateProductCount(List<OpportunityLineItem> oliList){
        
        Set<Id> oppIds = new Set<Id>();
        
        If(!oliList.isEmpty()){
        for(OpportunityLineItem oli: oliList){            
             oppIds.add(oli.OpportunityId);  
        }
        }
        
        if(!oppIds.IsEmpty()){
            List<Opportunity> oppList = [Select Id,AccountId from Opportunity where Id IN:oppIds];
            Map<Id,Decimal> countMap = new Map<Id,Decimal>();
            List<Account> lstToUpdate = new List<Account>();
            
            for(Opportunity opp: oppList){
                countMap.put(opp.AccountId,0);
            }
            
            for (AggregateResult aggr: [Select count(Id) oliCount, Opportunity.AccountId acctId from OpportunityLineItem 
                                        where Opportunity.AccountId!= null and Opportunity.AccountId IN: countMap.keyset()
                                       GROUP BY Opportunity.AccountId])
            							{
                                          countMap.put((Id)aggr.get('acctId'), (Decimal)aggr.get('oliCount'));
            							}
            for (Id ids: countMap.keyset()){
                Account acc = new Account();
                acc.Id = ids;
                acc.Product_Count__c = countMap.get(ids);
                lstToUpdate.add(acc);
            }
            update lstToUpdate;
        }
        
    }
    //update Account Descripption
        public static void updateAccountDescription(List<OpportunityLineItem> OliList){
        
        Set<Id> oppLiIds = new Set<Id>();
        
        for(OpportunityLineItem OLI: OliList){            
             oppLiIds.add(OLI.Id);  
        }
          
     List<OpportunityLineItem> exoliList = [Select Id,Name, Description ,Opportunity.Id, Opportunity.AccountId from OpportunityLineItem where Id IN: oppLiIds];
     List<Account> lstToUpdate = new List<Account>();
        
        for(OpportunityLineItem oli: exoliList)  {
            
            Account a = new Account();
            a.Id   = oli.Opportunity.AccountId;
            a.Description    =  oli.Description;
            lstToUpdate.add(a);
            
        }
        update lstToUpdate;
    }

}