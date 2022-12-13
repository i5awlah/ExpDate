//
//  CloudViewModel.swift
//  ExpDate
//
//  Created by Khawlah on 11/12/2022.
//

import Foundation
import CloudKit

class CloudViewModel: ObservableObject {
    
    private var container: CKContainer
    @Published var permissionStatus: Bool = false
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.khawlah.ExpDate")
                
        getiCloudStatus()
        requestPermission()
        fetchiCloudUserRecordId()
    }
    
    func getiCloudStatus() {
        container.accountStatus { status, error in
            switch (status) {
                
            case .couldNotDetermine:
                print("couldNotDetermine")
                break
            case .available:
                print("available!!")
            case .restricted:
                break
            case .noAccount:
                break
            case .temporarilyUnavailable:
                break
            @unknown default:
                break
            }
        }
    }
    
    
    func requestPermission() {
        container.requestApplicationPermission([.userDiscoverability]) { [weak self] returnedDtatus, error in
            DispatchQueue.main.async {
                if returnedDtatus == .granted {
                    self?.permissionStatus = true
                }
            }
        }
    }
    
    func fetchiCloudUserRecordId() {
        container.fetchUserRecordID { [weak self] recordID, error in
            if let recordID = recordID {
                self?.discoveriCloudUser(id: recordID)
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        container.discoverUserIdentity(withUserRecordID: id) { userdentity, error in
            DispatchQueue.main.async {
                guard let givenName = userdentity?.nameComponents?.givenName else { return }
                guard let familyName = userdentity?.nameComponents?.familyName else { return }
                let fullName = "\(givenName) \(familyName)"
                print("Welcome, \(fullName)")
            }
        }
    }
    
}

// do not run it let
