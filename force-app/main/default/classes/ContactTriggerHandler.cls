public class ContactTriggerHandler {
    
    //Copy Contact desc to Account Desc
    public static void updateAccountDesc(List<Contact> newCon, Map<Id,Contact> oldMap){
        
        Set<Id> accIds = new Set<Id>();
        
        for (Contact con: newCon){
            
            if(con.Description != null && con.Description != oldMap.get(con.Id).Description){
                accIds.add(con.AccountId);                
            }
        }
        if(!accIds.isEmpty()){
        Map<Id,Account> accMap = new Map<Id,Account> ([select Id,Description from Account where Id IN: accIds]);
        List<Account> accsToUpdate = new List<Account>();
        
        for (Contact cont: newCon){
            
            Account acc = accMap.get(cont.AccountId);
            if(cont.Description != null){
                acc.Description= cont.Description;
                accsToUpdate.add(acc);
                }
            
        }
        if (!accsToUpdate.isEmpty()){
       update  accsToUpdate;
            }
            }
    }
    //Rollup number of contacts
    public static void updateContactCount(Map<Id, Contact> newMap, Map<Id, Contact> oldMap, Boolean isDelete, Boolean isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        if (isDelete) {
            for (Contact con : oldMap.values()) {
                if (con.AccountId != null) accountIds.add(con.AccountId);
            }
        } else if (isUpdate) {
            for (Contact con : oldMap.values()) {
                if (con.AccountId != null) accountIds.add(con.AccountId);
            }
            for (Contact con : newMap.values()) {
                if (con.AccountId != null) accountIds.add(con.AccountId);
            }
        } else {
            for (Contact con : newMap.values()) {
                if (con.AccountId != null) accountIds.add(con.AccountId);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountsToUpdate.add(new Account(
                Id = (Id) ar.get('AccountId'),
                Number_Of_Contacts__c = (Integer) ar.get('contactCount')
            ));
        }

        update accountsToUpdate;
    }
    //Prevent more than 2 contacts
    public static void preventContactCreation(List<Contact> newCon){
        
        Set<Id> accIds = new Set<Id>();
         for (Contact con: newCon)
         {
			accIds.add(con.AccountId);                            
         }
         
        Map<Id, Integer> contCount = new Map<Id, Integer>();
        List<AggregateResult> aggrList =[SELECT AccountId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :accIds
            GROUP BY AccountId];
        
        for(AggregateResult agr: aggrList){
            contCount.put((Id) agr.get('AccountId'),(Integer) agr.get('contactCount'));
        }
        
         for (Contact cont: newCon)
         {
             if ((contCount.get(cont.AccountId)) >= 2){
                 cont.addError('Account Can not have more than 2 contacts.');
             }                            
         }
    }
    //Prevent duplication of contact based on Phone and Email
    public static void preventDupContact(List<Contact> newCon, Map<Id,Contact> oldMap){
        
        Map<String,Contact> conPhoneMap = new Map<String,Contact>();
        Map<String,Contact> conEmailMap = new Map<String,Contact>();
        
        for(Contact con: newCon){
            if(oldMap != null){
                if(con.Phone != null && con.Phone!= oldMap.get(con.Id).Phone){
                conPhoneMap.put(con.Phone,con);
            }
                if(con.email != null && con.email!= oldMap.get(con.Id).email){
                conEmailMap.put(con.email,con);
            }
            }
            else{
                if(con.Phone != null ){
                conPhoneMap.put(con.Phone,con);
            }
                if(con.email != null ){
                conEmailMap.put(con.email,con);
            }
            }            
        }
        
        List<Contact> existingCons = [Select Id, Email, Phone from Contact where Email IN:conEmailMap.keyset()
                                     OR Phone IN:conPhoneMap.keyset()];
        
        String errMessage ='';
        
        for(Contact cont: existingCons){
            
            if(cont.Phone != null){
                
                if(conPhoneMap.get(cont.Phone)!= null){
                    errMessage ='Phone';
                }
            }
            if(cont.Email != null){
                
                if(conEmailMap.get(cont.Email)!= null){
                    errMessage = errMessage + (errMessage != ''? ' and Email' : 'Email');
                }
            }
        }
        for(Contact conObj: newCon){
            
            if(errMessage != ''){
                
                conObj.addError('Your contact '+ errMessage + ' Already exists in the System.');
            }
            
        }
    }
    //update Contact Type
    public static void updateContactType(List<Contact> newCon, Map<Id,Contact> oldMap){
        
        Set<Id> accIds = new Set<Id>();
        Map<Id,String> accMap = new Map<Id,String>(); 

        if(!newCon.isEmpty() ){

            for (Contact con: newCon){
                    accIds.add(con.AccountId);                
            }

            if(!accIds.isEmpty()){
            
            for (Account acc : [select Id,RecordType.Name from Account where Id IN: accIds])
            {
                accMap.put(acc.Id, acc.RecordType.Name);
            }
            }
            if(oldMap == null){
            for(Contact conObj: newCon){
                string RecordTypeName = accMap.get(conObj.AccountId);
                if (RecordTypeName != null){
                    conObj.Contact_Type__c = RecordTypeName;
                }
            }
            }
            else{
                for(Contact conObj: newCon){
                string RecordTypeName = accMap.get(conObj.AccountId);
                if (RecordTypeName != null){
                    if(conObj.Contact_Type__c != RecordTypeName){
                        conObj.addError('Contact Type Can not be other than Account Type!');
                    }
                }
            }

            }
       }
    }

}