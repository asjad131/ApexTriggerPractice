trigger contactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    
        if (( Trigger.isUpdate || Trigger.isInsert) && Trigger.isAfter)
        {
        
        	if ( !Trigger.new.isEmpty())
            {            
            ContactTriggerHandler.updateAccountDesc(Trigger.new, Trigger.oldMap);                       
            }
        }
    
        if (( Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore)
        {
        
        	if ( !Trigger.new.isEmpty())
            {            
            ContactTriggerHandler.preventDupContact(Trigger.new, Trigger.oldMap); 
            ContactTriggerHandler.updateContactType(Trigger.new, Trigger.oldMap);                       
            }
        }
        /*
        if ((Trigger.isInsert) && Trigger.isBefore)
        {
        	if ( !Trigger.new.isEmpty())
            {            
            	ContactTriggerHandler.preventContactCreation(Trigger.new);                                   
          	}  
        }
            */
        
    	if (( Trigger.isUpdate || Trigger.isUndelete || Trigger.isInsert || trigger.isDelete) && Trigger.isAfter)
    	{
        	ContactTriggerHandler.updateContactCount(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
    	}

        if (( Trigger.isInsert) && Trigger.isAfter)
        {
        
        	if ( !Trigger.new.isEmpty())
            {            
            ContactTriggerHandler.updateAccountAndOpp(Trigger.new);                       
            }
        }

}