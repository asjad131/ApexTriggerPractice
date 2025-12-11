trigger productTrigger on Product2 (before insert, before update) {

    if (( Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore)
        {
        
        	if ( !Trigger.new.isEmpty())
            {            
            productTriggerHandler.calculateOfferPrice(Trigger.new);                     
            }
        }

}