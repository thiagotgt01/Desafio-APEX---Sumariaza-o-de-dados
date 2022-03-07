/**
 * @description       : Sumariazação de dados
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderItemTrigger on OrderItem (after insert,after update, after delete) {

    OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
        Trigger.old, Trigger.new,Trigger.oldMap,Trigger.newMap
    );

    switch on Trigger.operationType {
        when  AFTER_INSERT {
    handler.afterInsert();
        }
        when AFTER_UPDATE {
    handler.afterUpdate(); 
        }
        when AFTER_DELETE{
    handler.afterDelete();
        }
    }

}