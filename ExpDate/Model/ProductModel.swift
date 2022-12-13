//
//  ProductModel.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import Foundation
import CloudKit

enum ProductCategory: String, CaseIterable {
    case all = "All"
    case food = "Food"
    case medicine = "Medicine"
    case selfCare = "Self care"
}

struct ProductModel {
    var recordId: CKRecord.ID?
    var recordCreationDate: Date?
    let imageurl: String
    let name: String
    let expirationDate: Date
    let openDate: Date
    let afterOpeningExpiration: Int // day
    let productCategory: String
    let quantity: Int
    var notificationTime: Date
    
    var expiry: Date {
        if afterOpeningExpiration == 0 {
            return expirationDate
        }
        // Calc the secondExpirationDate by Adding afterOpeningExpiration to openDate
        var dateComponent = DateComponents()
        dateComponent.day = afterOpeningExpiration

        let secondExpirationDate = Calendar.current.date(byAdding: dateComponent, to: openDate)
        if let secondExpirationDate {
            return expirationDate > secondExpirationDate ? secondExpirationDate : expirationDate
        } else {
            return expirationDate
        }
    }
    
    init(recordId: CKRecord.ID? = nil, recordCreationDate: Date? = nil, imageurl: String, name: String, expirationDate: Date, openDate: Date, afterOpeningExpiration: Int, productCategory: ProductCategory, quantity: Int, notificationTime: Date) {
        self.recordId = recordId
        self.recordCreationDate = recordCreationDate
        self.imageurl = imageurl
        self.name = name
        self.expirationDate = expirationDate
        self.openDate = openDate
        self.afterOpeningExpiration = afterOpeningExpiration
        self.productCategory = productCategory.rawValue
        self.quantity = quantity
        self.notificationTime = notificationTime
    }
    
    func toDictonary() -> [String: Any] {
        return [
            "imageurl": imageurl,
            "name": name,
            "expirationDate": expirationDate,
            "openDate": openDate,
            "afterOpeningExpiration": afterOpeningExpiration,
            "productCategory": productCategory,
            "quantity": quantity,
            "notificationTime" : notificationTime
        ]
    }
    
    static func fromRecord(_ record: CKRecord) -> ProductModel? {
        guard let imageurl = record.value(forKey: "imageurl") as? String
                , let name = record.value(forKey: "name") as? String
                , let expirationDate = record.value(forKey: "expirationDate") as? Date
                , let openDate = record.value(forKey: "openDate") as? Date
                , let afterOpeningExpiration = record.value(forKey: "afterOpeningExpiration") as? Int
                , let productCategoryString = record.value(forKey: "productCategory") as? String
                , let quantity = record.value(forKey: "quantity") as? Int
                , let notificationTime = record.value(forKey: "notificationTime") as? Date else { return nil }
        
        let productCategory: ProductCategory = ProductCategory(rawValue: productCategoryString) ?? .all
        
        return ProductModel(recordId: record.recordID, recordCreationDate: record.creationDate, imageurl: imageurl, name: name, expirationDate: expirationDate, openDate: openDate, afterOpeningExpiration: afterOpeningExpiration, productCategory: productCategory, quantity: quantity, notificationTime: notificationTime)
    }
}


extension ProductModel {
    static var testProduct: ProductModel {
        let formatter = ISO8601DateFormatter()
        let expirationDate: Date = formatter.date(from: "2022-12-15T18:01:55Z") ?? .now
        let openDate: Date = formatter.date(from: "2023-10-10T18:01:55Z") ?? .now
        let recordCreationDate: Date = formatter.date(from: "2022-12-01T18:01:55Z") ?? .now
        let notificationTime: Date = formatter.date(from: "2022-12-25T18:01:55Z") ?? .now
        
        return ProductModel(recordCreationDate: recordCreationDate, imageurl: "https://123office.com/products/10652/images/2065144/9438490__67880.1651139149.1280.1280.jpg?c=1", name: "Carmex Moisturizing Lip Balm, Original Flavor", expirationDate: expirationDate, openDate: openDate, afterOpeningExpiration: 90, productCategory: .selfCare, quantity: 2, notificationTime: notificationTime)
    }
}
