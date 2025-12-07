trigger CandidateTrigger on Candidate__c (after insert, after update) {

    if ( trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if ( !Trigger.new.isEmpty()){   
        CandidateTriggerHandler.updateCandidateSkills(Trigger.new);
        }
    }

}