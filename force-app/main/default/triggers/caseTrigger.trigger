trigger caseTrigger on Case (after insert,after update, after delete, after undelete) {
            

    if(trigger.isInsert && trigger.isAfter)
    {
     caseTriggerHandler.updateLatestCaseNumber(Trigger.New);
    }
    
    if (( Trigger.isUpdate || Trigger.isUndelete || Trigger.isInsert || trigger.isDelete) && Trigger.isAfter)
    {       
      caseTriggerHandler.updateCaseCount(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
      caseTriggerHandler.updateAccountRating(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate); 
    }

}