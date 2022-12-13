//
//  NotificationManager.swift
//  ExpDate
//
//  Created by Khawlah on 11/12/2022.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("All set!")
            }
        }
    }
    
    
    func scheduleNotification(in notificationDate: Date, for product: ProductModel) {
        let content = UNMutableNotificationContent()
        content.title = "ExpDate App"
        content.body = "The expiry date of the \(product.name) is coming to an end!"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        var dateInfo = DateComponents()
        dateInfo.day = calendar.component(.day, from: notificationDate)
        dateInfo.month = calendar.component(.month, from: notificationDate)
        dateInfo.year = calendar.component(.year, from: notificationDate)
        dateInfo.hour = calendar.component(.hour, from: notificationDate)
        dateInfo.minute = calendar.component(.minute, from: notificationDate)
        print(dateInfo)
        //specify if repeats or no
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // pass identifier
//        guard let recordID = product.recordId else { return }
//        let identifier =  recordID.recordName
        let identifier = product.name
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            print("Error: \(error?.localizedDescription)")
        }
    }
    
    func cancelNotification(for product: ProductModel) {
//        guard let recordID = product.recordId else { return }
//        let identifier =  recordID.recordName
        let identifier = product.name
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
