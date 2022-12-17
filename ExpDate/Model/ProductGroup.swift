//
//  ProductGroup.swift
//  ExpDate
//
//  Created by Khawlah on 17/12/2022.
//

import Foundation
import CloudKit

struct ProductGroup {
    let zone: CKRecordZone
    let products: [ProductModel]
    
    var name: String {
        zone.zoneID.zoneName
    }
}

extension ProductGroup: Identifiable {
    var id: String {
        name
    }
}

