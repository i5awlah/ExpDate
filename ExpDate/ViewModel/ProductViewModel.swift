//
//  ProductViewModel.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import Foundation
class ProductViewModel : ObservableObject {
    
    @Published var productService: ProductService = ProductService()
    @Published var product: Product
    
    init() {
        self.product = Product(productname: "", imageurl: "", producturl: "", price: "", currency: "", saleprice: "", storename: "")
    }
    
    func getProductAPI(productID: String) {
        print("getProductAPI: \(productID)")
        productService.getProductAPI(
                    id: productID,
                    onSuccess: {(response) in
                        
                        print("response: \(response)")
                        self.product = response.product
                        
                    },
                    onFailure: {(message) in
                        print("message \(message)")
                    })
    }
    

}
