//
//  PushNotificationService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/23/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications
import UIKit

class PushNotificationService: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let firestoreService = FirestoreService()
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token, // sending to the device token of the desired receiving device
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAFddKFpg:APA91bFHKmsZOg4ltxbmlM-anf8EhdkezjZPxAD__cNzQu4c8azSVbgszqaaO4Ym_NMuHc5MqySuX51T7ejgwqjgAtFA-DGdKJj0XJL4_Sb2ZOztN8c8zC2Et3Y5L8sjDPSFKRP2XuKI", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let deviceToken = Messaging.messaging().fcmToken {
            if let user = Auth.auth().currentUser {
              // User is signed in.
                print("have access to user Id when I received registration token: \(user.uid)")
                
                // kind of have to store in database or update every time, because don't know if the user logged in and out or if there is a new token or not
                // https://firebase.google.com/docs/cloud-messaging/ios/client#access_the_registration_token
                
                firestoreService.updateUserDeviceToken(userId: user.uid, deviceToken: deviceToken) { res in
                    print(res)
                }
            } else {
              // No user is signed in.
              // ...
                print("can't save user device token to a user")
            }
        }
    }
}

