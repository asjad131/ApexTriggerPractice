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
    //update Account with Opp Amount and create Opportunity if 0 opportunities
    public static void updateAccountAndOpp(List<Contact> newCon){

        Set<Id> accIds = new Set<Id>();
        for(Contact con: newCon){
            if (con.AccountId != null) {
            accIds.add(con.AccountId);
        }
        }
        Map<Id, Decimal> accMap = new Map<Id, Decimal>();
        List<Account> accListToUpdate = new List<Account>();
        List<Opportunity> oppListToInsert = new List<Opportunity>();

         //Query Account names
        Map<Id, Account> accDetailsMap = new Map<Id, Account>(
        [SELECT Id, Name FROM Account WHERE Id IN :accIds]
        );
            
            for ( Opportunity  objOpp : [Select Id, AccountId, Amount from Opportunity where AccountId IN: accIds])
            {
               accMap.put(objOpp.AccountId, 
               accMap.get(objOpp.AccountId) == null ? objOpp.Amount : accMap.get(objOpp.AccountId) + objOpp.Amount);  
            }
           
            for ( Id accId : accIds){

                if(accMap.containsKey(accId)){

                    Account acc = new Account();
                    acc.Id = accId;
                    acc.Description = String.valueOf(accMap.get(accId));  
                    accListToUpdate.add(acc);

                }else{
                    // Get Account name
                    String accName = accDetailsMap.get(accId).Name;
                    //Build new opp
                    Opportunity opp = new Opportunity(
                    Name = accName + ' - Test Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    AccountId = accId
                    );
                    oppListToInsert.add(opp);

                }
            }
            update accListToUpdate;
            insert oppListToInsert;
            
        
    }

    //new contact check box
    public static void updateNewContact(List<Contact> newCon){

        Set<Id> accIds = new Set<Id>();
        for(Contact c: newCon){
            accIds.add(c.AccountId);
        }

        List<Contact> lstCon = [SELECT Id, AccountId, New_Contact__c FROM Contact where AccountId IN:accIds ORDER BY CreatedDate DESC ];

        Map<Id, Contact> recConByAccount = new Map<Id, Contact>();
        
        for (Contact con : lstCon) {

                if (!recConByAccount.containsKey(con.AccountId)) {
                    recConByAccount.put(con.AccountId, con);
                }
        }
        List<Contact> lstConToUpdate = new List<COntact>();

        for(Contact cont: lstCon){
            
            Contact recentCon = recConByAccount.get(cont.AccountId);

            if(recentCon.Id == cont.Id && recentCon.New_Contact__c == false){
                cont.New_Contact__c= true;
                lstConToUpdate.add(cont);
            }
            else{

                if(cont.New_Contact__c == true){
                    cont.New_Contact__c= false;
                    lstConToUpdate.add(cont);
                }

            }
        }
        update lstConToUpdate;
    }
    //update all contacts description to Account
    public static void updateAccountDescAll(Map<Id,Contact> newMap, Map<Id,Contact> oldMap, Boolean isDelete, Boolean isUpdate){
        
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

        if(!accountIds.isEmpty()){
            Map<Id,LIst<String>> accContactInfo = new Map<Id,List<String>>();
            List<Contact> lstCon = new List<Contact>([Select Id, Name, CreatedDate, AccountId from Contact where AccountId IN: accountIds]);
            List<Account> accsToUpdate = new List<Account>();
        
            for (Contact cont: lstCon){
                String contactInfo = 'Contact Name:' + cont.Name + ' - ' + 'Created Date:' + cont.CreatedDate;

                if(!accContactInfo.containsKey(cont.AccountId)){
                    accContactInfo.put(cont.AccountId, new List<String>{contactInfo}) ;   
                }else{
                    accContactInfo.get(cont.AccountId).add(contactInfo);
                }
            
            }
            for(Id ids: accountIds){
                Account acc = new Account();
                acc.Id = ids;

                if(accContactInfo.containsKey(ids)){
                    acc.Description = String.join(accContactInfo.get(ids), ';');
                }
                accsToUpdate.add(acc);
            }
            update accsToUpdate;
        }
    }

}