//
//  ProductViewModel.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import Foundation
import CloudKit


class ProductViewModel: ObservableObject {
    
    // MARK: - Error

    enum ViewModelError: Error {
        case invalidRemoteShare
    }

    // MARK: - State

    enum State {
        case loading
        case loaded(privateGroups: [ProductGroup], sharedGroups: [ProductGroup])
        case error(Error)
    }

    // MARK: - Properties

    /// State directly observable by our view.
    @Published private(set) var state: State = .loading
        /// Use the specified iCloud container ID, which should also be present in the entitlements file.
    lazy var container = CKContainer(identifier: "iCloud.com.khawlah.ExpDate")
    /// This project uses the user's private database.
    private lazy var database = container.privateCloudDatabase
    
    @Published var privateProducts: [ProductGroup] = []
    @Published var sharedProducts: [ProductGroup] = []
    @Published var selectedCategory: ProductCategory = .all
    
    @Published var selectedGroup: ProductGroup = ProductGroup(zone: CKRecordZone(zoneName: "-"), products: [])
    @Published var isPrivateList = true
    
    @Published var allProducts: [ProductModel] = []
    @Published var filterdProducts: [ProductModel] = []
    
    // MARK: - Init

    init() {
        addNewList(group: "My List") { returnedRecordZone, returnedError in
            if let returnedRecordZone {
                DispatchQueue.main.async {
                    print("selectedGroup: \(self.selectedGroup)")
                    self.selectedGroup = ProductGroup(zone: returnedRecordZone, products: [])
                    Task {
                        try await self.refresh()
                    }
                }
            } else if let returnedError {
                print("Error when creating new zone: \(returnedError.localizedDescription)")
            }
        }
    }
    
    // MARK: - API

    /// Fetches products from the remote databases and updates local state.
    
    func refresh() async throws {
        DispatchQueue.main.async {
            self.state = .loading
        }
        do {
            let (privateProducts, sharedProducts) = try await fetchPrivateAndSharedProducts()
            print(privateProducts.count)
            print(sharedProducts.count)
            
            DispatchQueue.main.async {
                
                self.privateProducts = privateProducts
                self.sharedProducts = sharedProducts
                
                self.refreshSelectedGroup()
                
                // update state
                self.state = .loaded(privateGroups: privateProducts, sharedGroups: sharedProducts)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error)
            }
        }
    }
    
    func refreshSelectedGroup() {
        // refresh selected group
        for group in privateProducts {
            if self.selectedGroup.id == group.id {
                self.selectedGroup = group
                self.allProducts = group.products
                self.filterdProducts = group.products
                self.isPrivateList = true
            }
        }
        
        for group in sharedProducts {
            if self.selectedGroup.id == group.id {
                self.selectedGroup = group
                self.allProducts = group.products
                self.filterdProducts = group.products
                self.isPrivateList = false
            }
        }
        self.sortAndFilter()
    }
    
    func sortAndFilter() {
        // filter
        if self.selectedCategory == .all {
            self.filterdProducts = self.allProducts
        } else {
            self.filterdProducts = self.allProducts.filter({ $0.productCategory == self.selectedCategory.rawValue})
        }
        
        // sort
        self.filterdProducts = self.filterdProducts.sorted(by: { $0.expiry < $1.expiry })
    }
    
    /// Fetches both private and shared products in parallel.
    /// - Returns: A tuple containing separated private and shared products.
    func fetchPrivateAndSharedProducts() async throws -> (private: [ProductGroup], shared: [ProductGroup]) {
        // Determine zones for each set of contacts.
        // In the Private DB, we want to ignore the default zone.
        let privateZones = try await database.allRecordZones()
            .filter { $0.zoneID != CKRecordZone.default().zoneID }
        let sharedZones = try await container.sharedCloudDatabase.allRecordZones()

        // This will run each of these operations in parallel.
        async let privateProducts = fetchProducts(scope: .private, in: privateZones)
        async let sharedProducts = fetchProducts(scope: .shared, in: sharedZones)

        return (private: try await privateProducts, shared: try await sharedProducts)
    }
    
    /// Adds a new Product to the database.
    ///  - Parameters:
    ///   - product: ProductModel
    ///   - group: Group name the Product should belong to.
    func addProduct(product: ProductModel, group: String) async throws {
        let scope: CKDatabase.Scope = isPrivateList ? .private  : .shared
        let database = container.database(with: scope)
        do {
            // Ensure zone exists first.
            let zone = CKRecordZone(zoneName: group)
            try await database.save(zone)
            
            let id = CKRecord.ID(zoneID: zone.zoneID)
            let productRecord = CKRecord(recordType: "Product", recordID: id)
            productRecord.setValuesForKeys(product.toDictonary())

            try await database.save(productRecord)
        } catch {
            debugPrint("ERROR: Failed to save new Contact: \(error)")
            throw error
        }
    }
    
    
    func addNewList(group: String, completionHandler: @escaping (CKRecordZone?, Error?) -> Void) {
        let zone = CKRecordZone(zoneName: group)
        database.save(zone, completionHandler: completionHandler)
    }

    /// Fetches an existing `CKShare` on a group zone, or creates a new one in preparation to share a group of products with another user.
    /// - Parameters:
    ///   - contactGroup: Group of Products to share.
    ///   - completionHandler: Handler to process a `success` or `failure` result.
    func fetchOrCreateShare(productGroup: ProductGroup) async throws -> (CKShare, CKContainer) {
        guard let existingShare = productGroup.zone.share else {
            let share = CKShare(recordZoneID: productGroup.zone.zoneID)
            share[CKShare.SystemFieldKey.title] = productGroup.name
            _ = try await database.modifyRecords(saving: [share], deleting: [])
            return (share, container)
        }

        guard let share = try await database.record(for: existingShare.recordID) as? CKShare else {
            throw ViewModelError.invalidRemoteShare
        }

        return (share, container)
    }

    // MARK: - Private

    /// Fetches grouped products for a given set of zones in a given database scope.
    /// - Parameters:
    ///   - scope: Database scope to fetch from.
    ///   - zones: Record zones to fetch products from.
    /// - Returns: An array of grouped products (a zone/group name and an array of `Product Model` objects).
    private func fetchProducts(
        scope: CKDatabase.Scope,
        in zones: [CKRecordZone]
    ) async throws -> [ProductGroup] {
        guard !zones.isEmpty else {
            return []
        }

        let database = container.database(with: scope)
        var allProducts: [ProductGroup] = []

        // Inner function retrieving and converting all product records for a single zone.
        @Sendable func contactsInZone(_ zone: CKRecordZone) async throws -> [ProductModel] {
            if zone.zoneID == CKRecordZone.default().zoneID {
                return []
            }

            var allProducts: [ProductModel] = []

            /// `recordZoneChanges` can return multiple consecutive changesets before completing, so
            /// we use a loop to process multiple results if needed, indicated by the `moreComing` flag.
            var awaitingChanges = true
            /// After each loop, if more changes are coming, they are retrieved by using the `changeToken` property.
            var nextChangeToken: CKServerChangeToken? = nil

            while awaitingChanges {
                let zoneChanges = try await database.recordZoneChanges(inZoneWith: zone.zoneID, since: nextChangeToken)
                let contacts = zoneChanges.modificationResultsByID.values
                    .compactMap { try? $0.get().record }
                    .compactMap { ProductModel(record: $0) }
                allProducts.append(contentsOf: contacts)

                awaitingChanges = zoneChanges.moreComing
                nextChangeToken = zoneChanges.changeToken
            }

            return allProducts
        }

        // Using this task group, fetch each zone's contacts in parallel.
        try await withThrowingTaskGroup(of: (CKRecordZone, [ProductModel]).self) { group in
            for zone in zones {
                group.addTask {
                    (zone, try await contactsInZone(zone))
                }
            }

            // As each result comes back, append it to a combined array to finally return.
            for try await (zone, contactsResult) in group {
                allProducts.append(ProductGroup(zone: zone, products: contactsResult))
            }
        }

        return allProducts
    }
    
    func deleteProduct(_ recordId: CKRecord.ID) {
        let scope: CKDatabase.Scope = isPrivateList ? .private  : .shared
        let database = container.database(with: scope)
        database.delete(withRecordID: recordId) { deletedRecordID, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("deleted successfully")
            }
        }
    }
    
    func updateProduct(updatedItem: ProductModel) {
        
        let scope: CKDatabase.Scope = isPrivateList ? .private  : .shared
        let database = container.database(with: scope)
        
        database.fetch(withRecordID: updatedItem.associatedRecord.recordID) { record, error in
            if let record = record, error == nil {
                //update your record here
                record.setValuesForKeys(updatedItem.toDictonary())
                // save record in database
                database.save(record) { returnRecord, error in
                    if let error = error {
                        print("ERRORR::\(error.localizedDescription)")
                    } else {
                        print("updated successfully")
                        Task {
                            try await self.refresh()
                        }
                    }
                }
            }
        }
    }
}

