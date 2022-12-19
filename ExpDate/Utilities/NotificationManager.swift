//
//  NotificationManager.swift
//  ExpDate
//
//  Created by Khawlah on 11/12/2022.
//

import SwiftUI
import CloudKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print(error.localizedDescription)
            } else if success {
                print("All set!")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.subscribeToNotifications()
                }
            }
        }
    }
    
    
    func scheduleNotification(for product: ProductModel) {
        let content = UNMutableNotificationContent()
        content.title = "ExpDate App"
        content.body = "The expiry date of the \(product.name) is coming to an end!"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        var dateInfo = DateComponents()
        dateInfo.day = calendar.component(.day, from: product.notificationTime)
        dateInfo.month = calendar.component(.month, from: product.notificationTime)
        dateInfo.year = calendar.component(.year, from: product.notificationTime)
        dateInfo.hour = calendar.component(.hour, from: product.notificationTime)
        dateInfo.minute = calendar.component(.minute, from: product.notificationTime)
        print(dateInfo)
        //specify if repeats or no
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // pass identifier
        let identifier = product.name
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for product: ProductModel) {
        let identifier = product.name
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // For cloud kit notification
    
    func subscribeToNotifications() {
            
            let predicate = NSPredicate(value: true)

            let subscription = CKQuerySubscription(recordType: "Product", predicate: predicate, subscriptionID: "product_added_to_database", options: .firesOnRecordCreation)
            
            let notification = CKSubscription.NotificationInfo()
            notification.title = "There's a new Product!"
            notification.alertBody = "Open the app to check your list."
            notification.soundName = "default"
            
            subscription.notificationInfo = notification
            
            CKContainer.default().privateCloudDatabase.save(subscription) { returnedSubscription, returnedError in
                if let error = returnedError {
                    print(error)
                } else {
                    print("Successfully subscribed to notifications!")
                }
            }
        }
    
    func unsubscribeToNotifications() {
            CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: "product_added_to_database") { returnedID, returnedError in
                if let error = returnedError {
                    print(error)
                } else {
                    print("Successfully unsubscribed!")
                }
            }
        }
}
