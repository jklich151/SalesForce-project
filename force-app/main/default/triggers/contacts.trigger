trigger contacts on Contact (after insert, after update, after delete, after undelete) {
    if (Trigger.isbefore) {
        if (Trigger.isinsert) {

        } else if (Trigger.isupdate) {

        } else if (Trigger.isdelete) {

        } else {

        }
    } else {
        if (Trigger.isinsert) {
            contactsHandler.countContactsOnAccounts(Trigger.new);
        } else if (Trigger.isupdate) {
            contactsHandler.countContactsOnAccounts(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isdelete) {
            contactsHandler.countContactsOnAccounts(Trigger.old);
        } else  {
            contactsHandler.countContactsOnAccounts(Trigger.new);
        }
    }
}