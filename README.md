# IAP_ViewModel_Swift
make it easy to make in app purchase

// to get your products

    IAPHandler.shared.fetchAvailableProducts(){ [weak self] (products) in
        
    }
        
//to show them on cell or any thing like that 

    func CollectionViewCellHandling(product:SKProduct){
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let price1Str = numberFormatter.string(from: product.price)
        let title = product.localizedTitle + " :  \(price1Str!)"
        let description = product.localizedDescription
    }




//handle status block

    IAPHandler.shared.purchaseStatusBlock = {[weak self] (status) in
        guard let strongSelf = self else{ return }
             let alertView = UIAlertController(title: "", message: status.message(), preferredStyle: .alert)
             let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
        })
        alertView.addAction(action)
        strongSelf.present(alertView, animated: true, completion: nil)
    }

//buy a product // be sure you handled purchaseStatusBlock first 

    IAPHandler.shared.purchaseMyProduct(index: indexSelected )

