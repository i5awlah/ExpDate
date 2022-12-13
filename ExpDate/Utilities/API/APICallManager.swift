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

    func createRequest(
        _ url: String,
        onSuccess successCallback: ((ProductResponse) -> Void)?,
        onFailure failureCallback: ((String) -> Void)?
    ) {
        AF.request(url).responseData { response in
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
