trigger oppLineItemTrigger on OpportunityLineItem (after insert, after delete, after update) {
    
    if(trigger.isAfter && Trigger.isInsert){
        
        opportunityLineItemTriggerHandler.createAsset(Trigger.New);
        opportunityLineItemTriggerHandler.updateProductCount(Trigger.New);
        opportunityLineItemTriggerHandler.updateAccountDescription(Trigger.New);
    }
    if(trigger.isAfter && Trigger.isUpdate){
        opportunityLineItemTriggerHandler.updateAccountDescription(Trigger.New);
    }
    if(trigger.isAfter && Trigger.isDelete){
        
        opportunityLineItemTriggerHandler.updateProductCount(Trigger.old);
        //opportunityLineItemTriggerHandler.updateAccountDescription(Trigger.Old);
    }

}