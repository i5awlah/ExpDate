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
    let title: String
    let images: [String]
    let category: [String]
}

extension Product {
    func toExistingCategory() -> ProductCategory? {
        for category in category {
            for productCategory in ProductCategory.allCases {
                if category.lowercased().contains(productCategory.rawValue.lowercased()) {
                    return productCategory
                }
            }
        }
        return nil
    }
}
