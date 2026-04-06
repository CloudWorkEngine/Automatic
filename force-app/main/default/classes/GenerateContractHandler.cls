public with sharing class GenerateContractHandler {

    public static Boolean isRunning = false;

    // BEFORE UPDATE
    public static void beforeUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);
            
            if(opp.StageName == 'Closed Won' && !opp.IsContractGenerated__c && opp.Amount > 10000 &&
                opp.AccountId != null && !oldOpp.IsContractGenerated__c)
                opp.IsContractGenerated__c = true;
        }
    }

    // AFTER UPDATE
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        if (isRunning) return;
        isRunning = true;

        List<Contract> contracts = new List<Contract>();

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            if(opp.StageName == 'Closed Won' && opp.IsContractGenerated__c && opp.Amount > 10000
                && opp.AccountId != null && !oldOpp.IsContractGenerated__c){
                Contract contract = new Contract(
                    Opportunity__c = opp.Id,
                    AccountId = opp.AccountId,
                    Status = 'Draft'
                );
                contracts.add(contract);
            }
        }

        if (!contracts.isEmpty()) {
            insert contracts;
        }

        isRunning = false;
    }
}