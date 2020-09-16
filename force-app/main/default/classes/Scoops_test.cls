@isTest
public class Scoops_test {
    @testSetup static void setup(){
        Item__c[] items = new item__c[]{};
        items.add(new item__c (name = 'Flavor 1', description__c = 'Cold', price__c = 3));
        items.add(new item__c (name = 'Flavor 2', description__c = 'Creamy', price__c = 4));
        items.add(new item__c (name = 'Flavor 3', description__c = 'Delicious', price__c = 5));

        insert items;
    }

    @isTest static void testInitialization(){
        scoops controller = new Scoops();
        System.assertEquals(0, controller.total);
        System.assertEquals('shopping', controller.state);
        System.assertEquals(3, controller.cartons.size());
        for (Scoops.carton carton : controller.cartons){
            System.assert(carton.item.name.contains('Flavor'));
            System.assert(carton.item.description__c != null);
            System.assert(carton.item.price__c > 0);
            System.assertEquals(0, carton.quantity);
            carton.quantity = 4;
            System.assertEquals(carton.item.price__c * carton.quantity, carton.subtotal);
        }
    }

}
