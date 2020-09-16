public without sharing class ContactsHandler {

    public static void countContactsOnAccounts(Contact[] contacts) {
         // declare what will be returned
         Set <id> accountIds = new Set <id> {};
         // left side is temporary variable, right side is set or list of what we are iterating over
         for (Contact contact : contacts) {
             // add account id of current contact to set
             accountIds.add(contact.accountId);
         }
        countContactsForAccounts(accountIds);
    }

    public static void countContactsOnAccounts(Map<Id, Contact> oldContactsById, map<Id, Contact> newContactsByID ) {
        Set <id> accountIds = new Set <id> {};
        // collect set of account ids related to contacts in an update scenario...what changed? if we care about what changed, need to collect correct accountids, could be old and new
        for (Id id : oldContactsById.keySet()) {
            Contact oldContact = oldContactsById.get(id);
            Contact newContact = newContactsByID.get(id);
            if (oldContact.accountId != newContact.accountId) {
                if (oldContact.accountId != null) {
                    accountIds.add(oldContact.accountId);
                }
                if (newContact.accountId != null) {
                    accountIds.add(newContact.accountId);
                }
            }
        }
        countContactsForAccounts(accountIds);
    }

    // public since it will be called from another file/class
    private static void countContactsForAccounts(Set <id> accountIds) {
        // get set of account ids
        // since this is an after, won't need to consider 0 case. doing this as an example.
        // query... end result is a list of accounts with id and list of contacts
        Account[] accounts = [
            SELECT Number_of_Contacts__c, (SELECT Id FROM Contacts)
            FROM Account
            WHERE Id in :accountIds 
        ];

        Account[] accountsToUpdate = new Account[] {};
        // case for number does not actually change (update)
        
        for (Account account : accounts ) {
        // does it need to change? if so, change and add to DB....size for collection
        // if they are different....make them the same
            if (account.Number_of_Contacts__c != account.contacts.size()){
                account.Number_of_Contacts__c = account.contacts.size();
                accountsToUpdate.add(account);
            }
        }

        update accountsToUpdate;
    }
}