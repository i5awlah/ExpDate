//
//  ProductAPIViewModel.swift
//  ExpDate
//
//  Created by Khawlah on 12/12/2022.
//

import Foundation
class ProductAPIViewModel : ObservableObject {
    
    @Published var productService: ProductService = ProductService()
    @Published var product: Product
    @Published var isFeaching = false
    @Published var isLoading = false
    
    init() {
        self.product = Product(title: "", images: [], category: [])
    }
    
    func getProductAPI(productID: String) {
        isLoading = true
        print("getProductAPI: \(productID)")
        productService.getProductAPI(
                    id: productID,
                    onSuccess: {(response) in
                        
                        print("response: \(response)")
                        self.product = response.product
                        self.isFeaching = true
                        self.isLoading = false
                    },
                    onFailure: {(message) in
                        print("message \(message)")
                        self.isLoading = false
                    })
    }
    

}
