public with sharing class ContactsList {
    public Contact[] contacts {get; private set;}

    public String firstname {get; set;}
    public String lastname {get; set;}
    public String title {get; set;}
    public String email {get; set;}

    public ContactsList() {
        filter();
     }

    public void filter() {
        String query = 'SELECT name, account.name, title, phone, email FROM contact';
        query += filters(); 

        contacts = database.query(query);
    }

    public String filters() {
        String[] filters = new String[]{};
        if (String.isnotblank(firstname)) {
            filters.add('FirstName = :firstname');
        }
        if (String.isnotblank(lastname)) {
            filters.add('LastName = :lastname');
        }
        if (String.isnotblank(title)) {
            filters.add('Title = :title');
        }
        if (String.isnotblank(email)) {
            filters.add('Email = :email');
        }



        if (filters.isempty()){
            return '';
        }
        else {
            return ' WHERE ' + String.join(filters, ' and ');
        }
    }


    // public contact[] getcontacts() {
    //    return contacts;
    // } 
}
