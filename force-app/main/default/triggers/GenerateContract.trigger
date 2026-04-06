trigger GenerateContract on Opportunity (before update, after update) {
    
    if(trigger.isUpdate && trigger.isBefore){
        GenerateContractHandler.beforeUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isUpdate && trigger.isAfter){
        GenerateContractHandler.afterUpdate(trigger.new, trigger.oldMap);
        GenerateContractHandler.sendSuccessEmail(trigger.new);
    }
}