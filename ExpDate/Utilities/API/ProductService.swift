//
//  ProductService.swift
//  ExpDate
//
//  Created by Khawlah on 09/12/2022.
//

import Foundation

let accessToken = "5AA38EB8-F7AA-4B6E-886B-849D47FF9AEB"
let baseURLString = "https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=\(accessToken)&upc="

class ProductService {
    
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
