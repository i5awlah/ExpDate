//
//  ProductResponse.swift
//  ExpDate
//
//  Created by Khawlah on 09/12/2022.
//

import Foundation

// MARK: - ProductResponse
struct ProductResponse: Codable {
    let product: Product
    enum CodingKeys: String, CodingKey {
        case product = "0"
    }
}

// MARK: - Product
struct Product: Codable {
    let productname, imageurl, producturl, price: String
    let currency, saleprice, storename: String
}
