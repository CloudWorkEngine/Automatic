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
        List<Opportunity> successOpportunities = new List<Opportunity>();
        List<Opportunity> failureOpportunities = new List<Opportunity>();

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
            Database.SaveResult[] results = Database.insert(contracts, false);
            
        }

        sendSuccessEmail(successOpportunities);
        sendFailureEmail(failureOpportunities);

        isRunning = false;
    }

    public static void sendSuccessEmail(List<Opportunity> opportunities){

        Set<Id> accountsIds = new Set<Id>();
        for(Opportunity opp: opportunities){
            if(opp.AccountId != null)
                accountsIds.add(opp.AccountId);
        }

        Map<Id,Account> accountsOpportunities = new Map<Id, Account>(
            [SELECT Id, Owner.Email FROM Account WHERE Id IN :accountsIds]
        ) ;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp: opportunities){
            if(opp.AccountId != null){
                Account account = accountsOpportunities.get(opp.AccountId);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Recipient address
                String[] toAddresses = new String[]{account.Owner.Email};
                //Set email content
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('fzoussama25@gmail.com');
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject('New contract generated for opportunity ' + opp.Name);
                mail.setPlainTextBody('A new contract was created for the opportunity with id: ' + opp.Id);

                mails.add(mail);
            }
        }

        if(!mails.isEmpty())
            Messaging.sendEmail(mails);
    }


    public static void sendFailureEmail(List<Opportunity> opportunities){

        Set<Id> OwnerIds = new Set<Id>();
        for(Opportunity opp: opportunities){
            if(opp.OwnerId != null)
                OwnerIds.add(opp.OwnerId);
        }

        Map<Id, User> owners = new Map<Id, User>(
            [SELECT Id, Email FROM User WHERE Id IN :OwnerIds]
        );
        

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(Opportunity opp: opportunities){
            User owner = owners.get(opp.OwnerId);

            if(owner != null){
            
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Recipient address
                String[] toAddresses = new String[]{owner.Email};
                //Set email content
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('fzoussama25@gmail.com');
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject('Contract generation failed for opportunity: ' + opp.Name);
                mail.setPlainTextBody('Contract generation failed for the opportunity with id: ' + opp.Id);

                mails.add(mail);
            }
        }

        if(!mails.isEmpty())
            Messaging.sendEmail(mails);
    }
}