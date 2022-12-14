//
//  ProductService.swift
//  ExpDate
//
//  Created by Khawlah on 09/12/2022.
//

import Foundation


class ProductService {
    
    let baseURLString = "https://barcodes1.p.rapidapi.com/?query="
    
    func getProductAPI(id: String,
                       onSuccess successCallback: ((_ response: ProductResponse) -> Void)?,
                       onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        // concatenate base url with id of product
        let url = baseURLString + id
        
        APICallManager.shared.createRequest(url,
                                            onSuccess: {(productResponse: ProductResponse) -> Void in
            successCallback?(productResponse)
        }, onFailure: {(errorMessage: String) -> Void in
            failureCallback?(errorMessage)
        })
    }
    
}
