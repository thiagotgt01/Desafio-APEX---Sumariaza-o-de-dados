/**
 * @description       : Sumariazação de dados
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderItemTriggerHandler {
    
    List<OrderItem> oldRecords {get; set;}   //Trigger.new
    List<OrderItem> newRecords {get; set;}   //Trigger.old
    Map<Id,OrderItem> oldMap {get; set;}  //Trigger.oldMap
    Map<Id,OrderItem> newMap {get; set;}  //Trigger.newMap

    public OrderItemTriggerHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id,OrderItem> oldMap, Map<Id,OrderItem> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;

        this.oldMap = oldMap; 
        this.newMap = newMap;
    }

    public void afterInsert(){
        List<Account> accountList = OrderItemHelper.summarizeAccounts(this.newRecords);
        if(!accountList.isEmpty()){
            update accountList;
        }
    }

    public void afterUpdate(){
        List<Account> accountList = OrderItemHelper.summarizeAccounts(this.oldMap, this.newMap);
        if (!accountList.isEmpty()) {
            update accountList;
        }
    }

    public void afterDelete(){
        List<Account> accountList = OrderItemHelper.summarizeAccounts(this.oldRecords);
        if (!accountList.isEmpty()) {
            update accountList;
        }
    }


}
