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

struct ProductModel: Identifiable {
    let id: String
    let imageurl: String
    let imageURL: URL?
    let name: String
    let expirationDate: Date
    let openDate: Date
    let afterOpeningExpiration: Int // day
    let productCategory: String
    let quantity: Int
    var notificationTime: Date
    let associatedRecord: CKRecord
    
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
    
}
extension ProductModel {
    init?(record: CKRecord) {
        guard let imageurl = record.value(forKey: "imageurl") as? String
                , let name = record.value(forKey: "name") as? String
                , let expirationDate = record.value(forKey: "expirationDate") as? Date
                , let openDate = record.value(forKey: "openDate") as? Date
                , let afterOpeningExpiration = record.value(forKey: "afterOpeningExpiration") as? Int
                , let productCategoryString = record.value(forKey: "productCategory") as? String
                , let quantity = record.value(forKey: "quantity") as? Int
                , let notificationTime = record.value(forKey: "notificationTime") as? Date else { return nil }
        
        self.id = record.recordID.recordName
        self.associatedRecord = record
        self.imageurl = imageurl
        self.name = name
        self.expirationDate = expirationDate
        self.openDate = openDate
        self.afterOpeningExpiration = afterOpeningExpiration
        self.productCategory = productCategoryString
        self.quantity = quantity
        self.notificationTime = notificationTime
        
        let imageAsset = record.value(forKey: "image") as? CKAsset
        self.imageURL = imageAsset?.fileURL
    }
    
    func toDictonary() -> [String: Any] {
        if imageURL != nil {
            return [
                "imageurl": imageurl,
                "image": CKAsset(fileURL: imageURL!),
                "name": name,
                "expirationDate": expirationDate,
                "openDate": openDate,
                "afterOpeningExpiration": afterOpeningExpiration,
                "productCategory": productCategory,
                "quantity": quantity,
                "notificationTime" : notificationTime
            ]
        } else {
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
    }
}


extension ProductModel {
    static var testProduct: ProductModel {
        let formatter = ISO8601DateFormatter()
        let expirationDate: Date = formatter.date(from: "2022-12-15T18:01:55Z") ?? .now
        let openDate: Date = formatter.date(from: "2023-10-10T18:01:55Z") ?? .now
        let notificationTime: Date = formatter.date(from: "2022-12-25T18:01:55Z") ?? .now
        
        return ProductModel(
            id: UUID().uuidString,
            imageurl: "https://123office.com/products/10652/images/2065144/9438490__67880.1651139149.1280.1280.jpg?c=1", imageURL: nil,
            name: "Carmex Moisturizing Lip Balm, Original Flavor",
            expirationDate: expirationDate,
            openDate: openDate,
            afterOpeningExpiration: 90,
            productCategory: ProductCategory.selfCare.rawValue,
            quantity: 2,
            notificationTime: notificationTime,
            associatedRecord: CKRecord(recordType: "Product")
        )
    }
}
