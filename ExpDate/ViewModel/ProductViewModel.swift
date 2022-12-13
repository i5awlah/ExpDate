//
//  ProductViewModel.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import Foundation
import CloudKit

class ProductViewModel: ObservableObject {
    
    private var database: CKDatabase
    
    @Published var selectedCategory: ProductCategory = .all
    
    @Published var products: [ProductModel] = []
    
    init() {
        let container = CKContainer(identifier: "iCloud.com.khawlah.ExpDate")
        self.database = container.privateCloudDatabase
        
        fetchProducts()
    }
    
    
    func deleteProduct(_ recordId: CKRecord.ID) {
        database.delete(withRecordID: recordId) { deletedRecordID, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("deleted successfully")
                self.fetchProducts()
            }
        }
    }
    
    func updateProduct(recordId: CKRecord.ID, updatedItem: ProductModel) {
        database.fetch(withRecordID: recordId) { record, error in
            
            if let record = record, error == nil {
                
                //update your record here
                record.setValuesForKeys(updatedItem.toDictonary())
                
                // save record in database
                self.database.save(record) { returnRecord, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("updated successfully")
                        self.fetchProducts()
                    }
                }
            }
        }
        
    }
    
    func addProduct(product: ProductModel) {
        let record = CKRecord(recordType: "Product")
        record.setValuesForKeys(product.toDictonary())
        
        // save record in database
        database.save(record) { newRecord, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let newRecord = newRecord {
                    print("added successfully")
                    if let product = ProductModel.fromRecord(newRecord) {
                        DispatchQueue.main.async {
                            self.selectedCategory = .all
                            self.products.append(product)
                            self.products = self.products.sorted(by: {$0.expiry < $1.expiry})
                        }
                    }
                }
            }
        }
    }
    
    func fetchProducts() {
        var products: [ProductModel] = []
        
        var predicate = NSPredicate(value: true)
        if selectedCategory != .all {
            predicate = NSPredicate(format: "productCategory = %@", argumentArray: [selectedCategory.rawValue])
        }
        
        let query = CKQuery(recordType: "Product", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        database.fetch(withQuery: query) { result in
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            print("Record: \(record)")
                            if let product = ProductModel.fromRecord(record) {
                                products.append(product)
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                DispatchQueue.main.async {
                    self.products = products.sorted(by: {$0.expiry < $1.expiry})
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    
}

