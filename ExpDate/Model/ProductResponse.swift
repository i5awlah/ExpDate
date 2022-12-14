//
//  ProductResponse.swift
//  ExpDate
//
//  Created by Khawlah on 09/12/2022.
//

import Foundation

// MARK: - ProductRe
struct ProductResponse: Codable {
    let product: Product
}

// MARK: - Product
struct Product: Codable {

    let images: [String]
    let title: String
}
