/**
 * @description       : Sumariazação de dados
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderItemHelper {
    public OrderItemHelper() {}

    //  ----  overload do metodo 'summarizeAccounts'  ---- 
    public static List<Account> summarizeAccounts(Map<Id,OrderItem> oldMap, Map<Id,OrderItem> newMap){

        List<OrderItem> modifiedOrderItemList = new List<OrderItem>();

        for(OrderItem newOrderItem : newMap.values()){
            OrderItem oldOrderItem = oldMap.get(newOrderItem.Id);

            if((newOrderItem.Quantity != oldOrderItem.Quantity) || (newOrderItem.UnitPrice != oldOrderItem.UnitPrice)){
                modifiedOrderItemList.add(newOrderItem);
            }
        }



        return summarizeAccounts(modifiedOrderItemList);
    }//  ----  FIM  overload do metodo 'summarizeAccounts'  ----  

    //Metodo principal
    public static List<Account> summarizeAccounts(List<OrderItem> orderItemList){
        Set<Id> orderIdSet = new Set<Id>();

        for (OrderItem orderItem : orderItemList) {
            orderIdSet.add(orderItem.OrderId);
        }

        List<Order> orderList = [
            SELECT  Id,AccountId
            FROM Order
            WHERE Id IN: orderIdSet
         ];

        Set<Id> accountIdSet = new Set<Id>();

        for(Order order: orderList){
            accountIdSet.add(order.AccountId);
        }  

        List<AggregateResult> resultList = getAggregateOrderAmount(accountIdSet);
        
        List<Account> accountList = buildAmountData(resultList);
        return accountList;
    }// FIM summarizeAccounts


    public static List<AggregateResult> getAggregateOrderAmount(Set<Id> accountIdSet){
        List<AggregateResult> resultList = [
            SELECT AccountId, Status,SUM(TotalAmount) TotalAmount
            FROM Order
            WHERE AccountId IN: accountIdSet
            GROUP BY AccountId,Status
        ];

        return resultList;
    }


    public static List<Account> buildAmountData(List<AggregateResult> resultList){
        //Map com valores dos status e nomes de API
        Map<String,String> statusToFieldMap = new Map<String,String>{
            'Open' => 'OpenOrderAmount__c',
            'Canceled' => 'CanceledOrderAmount__c',
            'Closed' => 'ClosedOrderAmount__c'
        };

        //
        Map<Id,Account> accountMap = new Map<Id,Account>();

        for(AggregateResult result : resultList){
            Decimal totalAmount = (Decimal)result.get('TotalAmount');
            Id accountId = (Id)result.get('AccountId');
            String status = (String)result.get('Status');

            if (accountMap.containsKey(accountId)) {
                Account account = accountMap.get(accountId);

                if(statusToFieldMap.containsKey(status)){
                    account.put(statusToFieldMap.get(status), totalAmount);
                }
            }else{
                Account account = new Account (
                    Id = accountId
                );
                if(statusToFieldMap.containsKey(status)){
                    account.put(statusToFieldMap.get(status), totalAmount);

                    accountMap.put(accountId, account);
                }
                
            }
        }
        return accountMap.values();
    }
    

}
