//
//  IAP.swift
//  ElhayesGroup
//
//  Created by MohammedEssam on 3/27/19.
//  Copyright © 2019 ElhayesGroup. All rights reserved.
//

    import Foundation
    import UIKit
    import StoreKit

    enum  IAPHandlerAlertType{
        case disabled
        case restored
        case purchased

        func message() -> String{
            switch self {
            case .disabled: return "purchase Failed"//"Purchases are disabled in your device!"
            case .restored: return "You've successfully restored your purchase!"
            case .purchased: return "purchase Done"//"You've successfully bought this purchase!"
            }
        }
    }


    class  IAPHandler: NSObject {
        static let shared =  IAPHandler()
        //create next 3 properties from your developer account and replace there value
        fileprivate let CONSUMABLE_PURCHASE_PRODUCT_ID = "CONSUMABLE_PURCHASE_PRODUCT_ID"
        fileprivate let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "NON_CONSUMABLE_PURCHASE_PRODUCT_ID"
        fileprivate let SUBSCRIPTION_SECRET = "SUBSCRIPTION_SECRET"

        fileprivate var productID = ""
        fileprivate var productsRequest = SKProductsRequest()
        fileprivate var iapProducts = [SKProduct]()


        var purchaseStatusBlock: (( IAPHandlerAlertType) -> Void)?
        fileprivate var productsCallback: (( [SKProduct]) -> Void)?

        // MARK: - MAKE PURCHASE OF A PRODUCT
        func canMakePurchases() -> Bool {
            return SKPaymentQueue.canMakePayments()
        }

        func purchaseMyProduct(index: Int){
            guard !iapProducts.isEmpty else{ return }

            if self.canMakePurchases() {
                let product = iapProducts[index]
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)

                print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
                productID = product.productIdentifier
            } else {
                purchaseStatusBlock?(.disabled)
            }
        }

        // MARK: - RESTORE PURCHASE
        func restorePurchase(){
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }


        // MARK: - FETCH AVAILABLE IAP PRODUCTS
        func fetchAvailableProducts(_  callback: (( [SKProduct]) -> Void)?) {
            productsCallback = callback
            
            // Put here your IAP Products ID's
            let productIdentifiers = NSSet(objects:NON_CONSUMABLE_PURCHASE_PRODUCT_ID,CONSUMABLE_PURCHASE_PRODUCT_ID)
            productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }

    extension  IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
        // MARK: - REQUEST IAP PRODUCTS
        func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
            print("===>>SKProductsRequest,didReceive",response.products)
            guard !response.products.isEmpty else{return}
                iapProducts = response.products
                
                for product in iapProducts{
                    let numberFormatter = NumberFormatter()
                    numberFormatter.formatterBehavior = .behavior10_4
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = product.priceLocale
                    let price1Str = numberFormatter.string(from: product.price)
                    print(product.localizedDescription + "\nfor just \(price1Str!)")
                    print(product.localizedTitle)
                    print(product.productIdentifier)
                }
                
                productsCallback?(iapProducts)
        }

        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            purchaseStatusBlock?(.restored)
        }

        // MARK:- IAP PAYMENT QUEUE
        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            print("====>>>paymentQueue",transactions)

            for transaction:AnyObject in transactions {
                if let trans = transaction as? SKPaymentTransaction {
                    print("===>>>trans")
                    print(trans)
                    switch trans.transactionState {
                    case .purchased:
                        print("purchased")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        receiptValidation()
                        purchaseStatusBlock?(.purchased)
                        break

                    case .failed:
                        print("failed")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        purchaseStatusBlock?(.disabled)
                        break
                        
                    case .restored:
                        print("restored")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        purchaseStatusBlock?(.restored)
                        break

                    default: break
                    }}}
        }
    }

extension IAPHandler{
    func receiptValidation() {
        if let receiptPath = Bundle.main.appStoreReceiptURL?.path,
            FileManager.default.fileExists(atPath: receiptPath){
            do{
                let receiptData:NSData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!,
                                         options: NSData.ReadingOptions.alwaysMapped)
                let base64encodedReceipt = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
                
                print("====>>>base64encodedReceipt",base64encodedReceipt)
                
                self.validateWithApple(base64encodedReceipt)
            }catch{
                print("ERROR: " + error.localizedDescription)
            }
        }
    }
    
    func validateWithApple(_ base64encodedReceipt:String){
                    
//            In the test environment, use https://sandbox.itunes.apple.com/verifyReceipt as the URL.
//            In production, use https://buy.itunes.apple.com/verifyReceipt as the URL.
        let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"
        let parameters = ["receipt-data":base64encodedReceipt,"password":SUBSCRIPTION_SECRET]
                    
//        Just make your own post request just to check with apple if this receipt real or fake 
    }
}


//MARK:-Usage
// to get your products
//IAPHandler.shared.fetchAvailableProducts(){ [weak self] (products) in
//
//}

//func CollectionViewCellHandling(product:SKProduct){
//    let numberFormatter = NumberFormatter()
//    numberFormatter.formatterBehavior = .behavior10_4
//    numberFormatter.numberStyle = .currency
//    numberFormatter.locale = product.priceLocale
//    let price1Str = numberFormatter.string(from: product.price)
//
//    let title = product.localizedTitle + " :  \(price1Str!)"
//    let description = product.localizedDescription
//}



//handle status block
//IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
//    guard let strongSelf = self else{ return }
//        let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//
//        })
//        alertView.addAction(action)
//        strongSelf.present(alertView, animated: true, completion: nil)
//}

//buy a product
//    IAPHandler.shared.purchaseMyProduct(index: selected )

