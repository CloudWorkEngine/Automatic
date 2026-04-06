trigger GenerateContract on Opportunity (before update) {
    
    List<Contract> contracts = new List<Contract>();
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Opportunity opp:  Trigger.new){
            if(opp.AccountId != null && !opp.IsContractGenerated && opp.Amount > 10000 && opp.StageName == 'Closed Won'){
                Contract contract = new Contract(
                    AccountId = opp.AccountId,
                    OpportunityId = opp.Id,
                    Status = 'Draft'
                    );
                opp.IsContractGenerated = true;
                contracts.add(contract);
            }
        }
        insert contracts;
    }
}