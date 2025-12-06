trigger oppTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    if (( Trigger.isUpdate || Trigger.isUndelete || Trigger.isInsert || trigger.isDelete) && Trigger.isAfter){
        
        OpportunityTriggerHandler.updateOpportunityAmount(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
        //OpportunityTriggerHandler.updateMaxOpportunityName(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
        OpportunityTriggerHandler.updateAccountStatus(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);
        OpportunityTriggerHandler.updateMaxOpportunityAmount(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate);

    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        OpportunityTriggerHandler.upsertTask(Trigger.new, Trigger.oldMap);
        
    }
    

}