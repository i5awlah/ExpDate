//
//  APICallManager.swift
//  ExpDate
//
//  Created by Khawlah on 09/12/2022.
//

import Foundation
import Alamofire

class APICallManager {
    static let shared = APICallManager()
    
    let headers: HTTPHeaders = [
        "X-RapidAPI-Key": "36d8e68db9msh690f129e2fd1053p1f4a79jsn4c9891c56a3b",
        "X-RapidAPI-Host": "barcodes1.p.rapidapi.com"
    ]

    func createRequest(
        _ url: String,
        onSuccess successCallback: ((ProductResponse) -> Void)?,
        onFailure failureCallback: ((String) -> Void)?
    ) {
        AF.request(url, method: .get, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    
                    print("response: \(response)")
                    print("result: \(response.result)")
                    
                    let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    successCallback?(productResponse)
                } catch {
                    failureCallback?("product not found: \(data.description)")
                }
            case .failure(let error):
                if let callback = failureCallback {
                    callback(error.localizedDescription)
                }
            }
        }
    }
    
}
