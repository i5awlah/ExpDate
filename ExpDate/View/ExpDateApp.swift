//
//  ExpDateApp.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI
import UserNotifications
import CloudKit

@main
struct ExpDateApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // to make alert and action sheet using the accent color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color("AccentColor"))
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

// AppDelegate.swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Here we actually handle the notification
        print("Notification received with identifier \(notification.request.identifier)")
        // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
}

// MARK: UISceneSession Lifecycle
extension AppDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if options.userActivities.first?.activityType == "newWindow" {
                let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
                configuration.delegateClass = SceneDelegate.self
                return configuration
            } else {
                // Called when a new scene session is being created.
                // Use this method to select a configuration to create the new scene with.
                return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            }
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        print("userDidAcceptCloudKitShareWith")
        guard cloudKitShareMetadata.containerIdentifier == "iCloud.com.khawlah.ExpDate" else {
            print("Shared container identifier \(cloudKitShareMetadata.containerIdentifier) did not match known identifier.")
            return
        }

        // Create an operation to accept the share, running in the app's CKContainer.
        let container = CKContainer(identifier: "iCloud.com.khawlah.ExpDate")
        let operation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])

        debugPrint("Accepting CloudKit Share with metadata: \(cloudKitShareMetadata)")

        operation.perShareResultBlock = { metadata, result in
            let shareRecordType = metadata.share.recordType

            switch result {
            case .failure(let error):
                debugPrint("Error accepting share: \(error)")

            case .success:
                debugPrint("Accepted CloudKit share with type: \(shareRecordType)")
            }
        }

        operation.acceptSharesResultBlock = { result in
            if case .failure(let error) = result {
                debugPrint("Error accepting CloudKit Share: \(error)")
            }
        }

        operation.qualityOfService = .utility
        container.add(operation)
    }
}
