public with sharing class Scoops {

    public Carton[] cartons {get; private set;}
    @testVisible private Map <id, carton> cartonsById;
    public Decimal total {get; private set;}
    public String first_name {get; set;}
    public String last_name {get; set;}
    public String street {get; set;}
    public String zip {get; set;}
    public String email {get; set;}
    public String credit_card_number {get; set;}
    public String exp_month {get; set;}
    public String exp_year {get; set;}
    public String security_code {get; set;}
    public SelectOption[] exp_year_options {get; private set;}
    public String state {get; private set;}
    public String pageMessage {get; private set;}

    @testVisible private class Carton {
        public Item__c item {get; private set;}
        @testVisible public Integer quantity {get; private set;}
        public Decimal subtotal {get {return quantity * item.price__c;}}
        public Integer selectedquantity {get; set;}
        
        public Carton(Item__c item){
            this.item = item;
            quantity = 0;
        }
    }

    public Scoops() {
        cartons = new carton[] {};
        cartonsById = new Map <id, carton> ();
        total = 0;
        Item__c[] items = [SELECT name, description__c, price__c FROM item__c];
        for (Item__c item : items) {
            Carton carton = new carton(item);
            cartons.add(carton);
            cartonsById.put(item.id, carton);
        }
        buildExpYearOptions();
        state = 'shopping';
     }

    public void buildExpYearOptions() {
        exp_year_options = new selectOption[]{};
        Integer current_year = date.today().year();
        for (Integer i = 0 ; i < 5 ; i ++) {
            exp_year_options.add(new selectOption(string.valueOf(current_year + i), string.valueOf(current_year + i)));
        }
    }

    public void checkout() {
        state = 'checkout';
    }

    public void addtocart() {
        // identify item id
        // get item
        // set items quantity
        // calculate total 
        Carton carton = cartonsById.get(selecteditemid);
        carton.quantity += carton.selectedquantity;

        // for (Carton carton : cartons) {
        //     if (carton.item.id == selecteditemid) {
        //         carton.quantity += carton.selectedquantity;
        //     }   
        // }
        calculatetotal();
    }

    public void calculatetotal() {
        total = 0;
        for (Carton carton : cartons) {
            total += carton.subtotal;
            carton.selectedquantity = 1;
        }
    }

    public String debug {get; private set;}

    public void chargeCard() {
        http http = new http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setEndPoint('https://apitest.authorize.net/xml/v1/request.api');
        httpRequest.setBody(authorizeRequestbody());
        HttpResponse httpResponse = http.send(httpRequest);
        Authorize response = (authorize)json.deserialize(httpResponse.getBody().substring(1), authorize.class);
        if (response.transactionResponse != null) {
           if (response.transactionResponse.responseCode == '1') {
               chargeCardSuccess();
           }
           else {
               pageMessage = response.transactionResponse.errors[0].errorText;
           }
        } 
        else {
            pageMessage = 'Transaction Unsuccessful';
        }
        debug = httpResponse.getBody();
        System.debug(debug);
    }

    public void chargeCardSuccess() {
        pageMessage = 'Thank you';

        order__c order = new order__c( Customer_Name__c = first_name + ' ' + last_name, 
                                        Customer_Email__c = email,
                                        Street__c = street,
                                        State__c = state
                                        );
        insert order;

        Order_Line__c[] orderLines = new Order_Line__c[] {};
        for (Carton carton : cartons) {
            if (carton.quantity > 0) {
                Order_Line__c orderLine = new Order_Line__c(
                    Order__c = order.id,
                    Price__c = carton.item.price__c,
                    Quantity__C = carton.quantity,
                    Item__c = carton.item.id
                );
                orderLines.add(orderLine);
             }
            }
          
        insert orderLines;
        state = 'charged';
    }
    

    public Id selecteditemid {get; set;}

    private String authorizeRequestbody() {
        // For some reason, the Authorize Dot Net API requires the components of this JSON string to be in a specific order,
        // so we are forced to use the JSON Generator instead of serializing an APEX object.
        // This is lame but out of our control...
        // ----------------- EXAMPLE JSON -----------------
        // {
        //   "createTransactionRequest" : {
        //     "merchantAuthentication" : {
        //       "name" : "XXX",
        //       "transactionKey" : "YYY"
        //     },
        //     "transactionRequest" : {
        //       "transactionType" : "authCaptureTransaction",
        //       "amount" : "13.14",
        //       "payment" : {
        //         "creditCard" : {
        //           "cardNumber" : "5424000000000015",
        //           "expirationDate" : "052018",
        //           "cardCode" : "123"
        //         }
        //       },
        //       "order" : {
        //         "invoiceNumber" : "123"
        //         "description" : "Stuff"
        //       },
        //       "customer" : {
        //         "email" : "ItWasMe@WhoFarted.com"
        //       },
        //       "billTo" : {
        //         "firstName" : "test",
        //         "lastName" : "last",
        //         "address": "1313 Mockingbird Lane",
        //         "zip" : "03062"
        //       },
        //       "transactionSettings" : {
        //         "setting" : {
        //           "settingName" : "emailCustomer",
        //           "settingValue" : "1"
        //         }
        //       }
        //     }
        //   }
        // }

        Api_Credentials__c credentials = [SELECT User_Name__c, Password__c FROM Api_Credentials__c WHERE name = 'authorize.net' LIMIT 1];


        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
           gen.writeFieldName('createTransactionRequest');
           gen.writeStartObject();
              gen.writeFieldName('merchantAuthentication');
              gen.writeStartObject();
                 gen.writeStringField('name',           credentials.user_name__c);
                 gen.writeStringField('transactionKey', credentials.password__c);
              gen.writeEndObject();
              gen.writeFieldName('transactionRequest');
              gen.writeStartObject();
                 gen.writeStringField('transactionType', 'authCaptureTransaction');
                 gen.writeStringField('amount', string.valueOf(total));
                 gen.writeFieldName('payment');
                 gen.writeStartObject();
                    gen.writeFieldName('creditCard');
                    gen.writeStartObject();
                       gen.writeStringField('cardNumber',     credit_card_number);
                       gen.writeStringField('expirationDate', exp_month + exp_year);
                       gen.writeStringField('cardCode',       security_code);
                    gen.writeEndObject();
                 gen.writeEndObject();
                 gen.writeFieldName('order');
                 gen.writeStartObject();
                    gen.writeStringField('invoiceNumber', 'the_record_id');
                    gen.writeStringField('description', 'description');
                 gen.writeEndObject();
                 gen.writeFieldName('customer');
                 gen.writeStartObject();
                    gen.writeStringField('email', email);
                 gen.writeEndObject();
                 gen.writeFieldName('billTo');
                 gen.writeStartObject();
                    gen.writeStringField('firstName', first_name);
                    gen.writeStringField('lastName',  last_name);
                    gen.writeStringField('address',   street);
                    gen.writeStringField('zip',       zip);
                 gen.writeEndObject();
                 gen.writeFieldName('transactionSettings');
                 gen.writeStartObject();
                    gen.writeFieldname('setting');
                    gen.writeStartObject();
                       gen.writeStringField('settingName', 'emailCustomer');
                       gen.writeStringField('settingValue', '1');
                    gen.writeEndObject();
                 gen.writeEndObject();
              gen.writeEndObject();
           gen.writeEndObject();
        gen.writeEndObject();
        // This output contains a credit card number, so we shouldn't log it in production where real details are used.
        System.debug('*** JSON output ***');
        System.debug(gen.getAsString());
        return gen.getAsString();
    }
}