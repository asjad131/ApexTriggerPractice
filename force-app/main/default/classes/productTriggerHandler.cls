public with sharing class productTriggerHandler {
   
    //Calculate Offer price
    public static void calculateOfferPrice(List<Product2> newProducts){

        if(!newProducts.isEmpty()){

            for(Product2 prod: newProducts ){

                if(prod.Offer_Available__c){

                    if (prod.Offer_Type__c == 'Flat'){

                        if(prod.Flat_Discount__c == null){

                            prod.addError('Flat Discount should be filled for Offer type Flat');

                        }else{

                            prod.Offer_Price__c = prod.Original_Price__c - prod.Flat_Discount__c;

                        }
                        
                    }
                    if (prod.Offer_Type__c == 'Percentage'){

                        if(prod.Percentage_Discount__c == null){

                            prod.addError('Percetage Discount should be filled for Offer type Percentage');

                        }else{

                            prod.Offer_Price__c = prod.Original_Price__c - ((prod.Original_Price__c * prod.Percentage_Discount__c)/100);

                        }
                        
                    }


                }
            }
        }


    }
}