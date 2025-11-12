public class AccountTriggerHandler {
    
    //Account Phone Validation
    public static void validatePhone(List<Account> newAcc){
        
        for (Account acc: newAcc){            
            if (acc.Phone == null){
            acc.addError('You can not leave Account Phone blank!');
          }
        }        
    }
    
    //Copy Billing address to Shipping Address
    public static void updateShippingAddress(List<Account> newAcc){
        
        for (Account acc: newAcc){
            
            acc.ShippingStreet = acc.BillingStreet;
            acc.ShippingCity = acc.BillingCity;
            acc.ShippingState = acc.BillingState;
            acc.ShippingCountry = acc.BillingCountry;
            acc.ShippingPostalCode = acc.BillingPostalCode;
        }        
    }
    
    //Copy Account Phone to Contact Phone
    public static void updateContactsPhone(List<Account> newAcc, Map<Id,Account> oldMap){
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for (Account acc: newAcc){
            
            if(acc.Phone != oldMap.get(acc.Id).Phone){
                accMap.put(acc.Id,acc);                
            }
         List<Contact> conList = [select Id,AccountId, Phone from Contact where AccountId IN: accMap.keyset()];   
            
            for(Contact con: conList){
                con.Phone= accMap.get(con.AccountId).Phone;
            }
            update conList;
        }
    }
    
    //Prevent duplicate Account by Name
    public static void validateDuplicateAccounts(List<Account> newAcc, Map<Id,Account> oldMap, Boolean isUpdate){
        
        Set<String> accNames = new Set<String>();
        
        for(Account acc: newAcc){
            
            If(isUpdate){
            	If(!oldMap.isEmpty() && (oldMap.get(acc.Id).Name != acc.Name))
                {
            		accNames.add(acc.Name);
            	}
            }
            else
            {
                	accNames.add(acc.Name);
            }
        }
        
        Map<String,Account> dupAccounts = new Map<String,Account>();
        for (Account accd : [SELECT Id, Name FROM Account WHERE Name IN :accNames]) {
    			dupAccounts.put(accd.Name, accd);
			}
        
        for(Account acct: newAcc){
            
            If( dupAccounts.containskey(acct.Name)){
                acct.addError('An Account already exists with same Name!');
            }
        }
    }
    
    //Create a related contact
    public static void createContact(List<Account> newAcc){
        
        List<Contact> lstCon = new List<Contact>();
        for(Account acc: newAcc){
            
            if(acc.Create_Contact__c == true){
                
                            Contact con = new Contact (FirstName = 'Test',
                					   LastName = 'Test '+acc.Name,
                                       Phone= acc.Phone,
                                       AccountId=acc.Id
                                      );	
                lstCon.add(con);
            }
        }

        insert lstCon;
    }
    
    //update old opportunities
    public static void updateOldOpportunities(List<Account> newAcc){
        set<Id> accIds = new set<Id>();
        
        for(Account acc: newAcc){
            accIds.add(acc.Id);
        }
    
       List<Opportunity> lstOpps = new List<Opportunity>([Select Id,StageName, AccountId from Opportunity
                                                         WHERE AccountId IN:accIds
                                                         AND Test_Created_Date__c < LAST_N_DAYS:30
                                                         AND IsClosed = false                                                     
                                                       ]);
        
        for (Opportunity opp: lstOpps){
            opp.StageName = 'Closed Lost';
            opp.CloseDate = Date.today();
        }
        
        update lstOpps;
        
    }
    //prevent active account deletion
    public static void preventDeletion(List<Account> oldAcc){
         for(Account acc: oldAcc){
             if(acc.Is_Active__c == true){
                 acc.addError('You can not delete an active Account!');
             }
        }
    }
    //Send email to contact when Account type changes
    public static void sendEmailToContact(List<Account> newAcc, Map<Id,Account> oldMap){
        
        Set<Id> accIds = new Set<Id>();
        
        for(Account acc: newAcc){
                
            	If(!oldMap.isEmpty() && (oldMap.get(acc.Id).Type  != acc.Type))
                {
            		accIds.add(acc.Id);
            	}
        }
        List<Contact> conList = new List<Contact>([Select Id,Email, AccountId, LastName from Contact where AccountId IN:accIds ]);
        List<Messaging.SingleEmailMessage> mailsToSend = new List <Messaging.SingleEmailMessage>();
        
        for (Contact con: conList){
            
            if (con.Email != null){
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(con.Id);
            mail.setSenderDisplayName('System Administrator');
            mail.setSubject('Account Type Updated:');
            string body = 'Dear '+con.LastName+ ',</br>';
            body +='Your Account Type has been updated.';
            mail.setHtmlBody(body);
            mail.toAddresses = new string[]{con.Email};
            mailsToSend.add(mail);    
         }
        Messaging.sendemail(mailsToSend);
      }
    }

}