trigger accountTrigger on Account (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        
        if ( !Trigger.new.isEmpty()){            
            AccountTriggerHandler.validatePhone(Trigger.new);
            AccountTriggerHandler.updateShippingAddress(Trigger.new);
            AccountTriggerhandler.validateDuplicateAccounts(Trigger.new,Trigger.oldMap, Trigger.isUpdate);                       
          }
        
        }

      if (( Trigger.isUpdate) && Trigger.isBefore){
        
        if ( !Trigger.new.isEmpty()){            
            AccountTriggerHandler.preventDeactivation(Trigger.new,Trigger.oldMap);                   
          }
        
        }
    
    if ((Trigger.isInsert) && Trigger.isAfter){
        
        if ( !Trigger.new.isEmpty()){            
            AccountTriggerHandler.createContact(Trigger.new);                       
          }
        
        }
    
    if (( Trigger.isUpdate) && Trigger.isAfter){
        
        if ( !Trigger.new.isEmpty()){            
            AccountTriggerHandler.updateContactsPhone(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.sendEmailToContact(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateOldOpportunities(Trigger.new);  
            AccountTriggerHandler.sendMailToAccountOwner(Trigger.new, Trigger.oldMap);
          }
        
        }
 if ((Trigger.isDelete) && Trigger.isBefore){
        
        if ( !Trigger.old.isEmpty()){            
            AccountTriggerHandler.preventDeletion(Trigger.old);                       
          }
        
        }    
    
}