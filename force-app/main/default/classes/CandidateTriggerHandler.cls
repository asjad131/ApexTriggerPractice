public with sharing class CandidateTriggerHandler {
    
    public static void updateCandidateSkills(List<Candidate__c> newCan){

        Map<String,Skill__c> existingSkillsMap = new Map<String, Skill__c>();
        Map<String,Candidate__c> candidateSkillsMap = new Map<String,Candidate__c>();
        List<Candidate_Skill__c> lstToInsertCandidateSkill = new List<Candidate_Skill__c>();
        List<Skill__c> lstToInsertSkill = new List<Skill__c>();
        
        //existing skills map
        for(Skill__c skill: [select Id, Name from Skill__c]){
            existingSkillsMap.put(skill.Name, skill);            
        }
        //cnadidates skills map
        if(!newCan.isEmpty()){

            for(Candidate__c cand : newCan){
                String[] skillNames = cand.Skills__c.split(',');

                for(String skillname:skillNames){
                    if(!candidateSkillsMap.containsKey(skillname)){
                        candidateSkillsMap.put(skillname, cand);
                    }
                }
            }
        }

        //cnadidate skill records
        for(String candskill: candidateSkillsMap.keyset()){

            if(existingSkillsMap.containsKey(candskill)){

                Candidate_Skill__c cs = new Candidate_Skill__c();
                cs.Skill__c = existingSkillsMap.get(candskill).Id;
                cs.Name = candidateSkillsMap.get(candskill).Name + ' - ' + candskill;
                cs.Candidate__c = candidateSkillsMap.get(candskill).Id;
                lstToInsertCandidateSkill.add(cs);
            }
            else{

                Skill__c recSkill = new Skill__c();
                recSkill.Name = candskill;
                lstToInsertSkill.add(recSkill);
            }
        }
        if(!lstToInsertSkill.isEmpty()){
            insert lstToInsertSkill;

            for (Skill__c sk: lstToInsertSkill){

                Candidate_Skill__c csr = new Candidate_Skill__c();
                csr.Skill__c = sk.Id;
                csr.Name = candidateSkillsMap.get(sk.Name).Name + ' - ' + sk.Name;
                csr.Candidate__c = candidateSkillsMap.get(sk.Name).Id;
                lstToInsertCandidateSkill.add(csr);
            }
        }
       
        if(!lstToInsertCandidateSkill.isEmpty()){
            insert lstToInsertCandidateSkill;
        }
    
    }
}