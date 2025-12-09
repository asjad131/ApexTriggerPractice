trigger caseTrigger on Case (before insert, after insert,after update, after delete, after undelete) {
            

    if(trigger.isInsert && trigger.isAfter)
    {
     //caseTriggerHandler.updateLatestCaseNumber(Trigger.New);
    }
    if(trigger.isInsert && trigger.isBefore)
    {
     caseTriggerHandler.relateCaseToContact(Trigger.New);
    }
    
    if (( Trigger.isUpdate || Trigger.isUndelete || Trigger.isInsert || trigger.isDelete) && Trigger.isAfter)
    {       
      caseTriggerHandler.updateCaseCount(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
      caseTriggerHandler.updateAccountRating(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate); 
    }
    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter ){
      caseTriggerHandler.createTask(Trigger.New,Trigger.oldMap);
    }

}