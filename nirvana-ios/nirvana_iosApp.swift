//
//  nirvana_iosApp.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseMessaging

@main
struct nirvana_iosApp: App {
    @StateObject var authSessionStore: AuthSessionStore = AuthSessionStore()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authSessionStore)
                .onOpenURL { url in
                    print("Received URL: \(url)")
                    Auth.auth().canHandle(url) // <- just for information purposes
                  }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
          print("application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
            
          print("initialized Firebase")
          FirebaseApp.configure()
          
          // setting up cloud messaging
          Messaging.messaging().delegate = self
          
          // setting up notifications ... requesting authorization from user
          if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { _, _ in }
            )
          } else {
            let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
          }

          application.registerForRemoteNotifications()

          
          return true
      }
    
      func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          // gets the APN token so that firebase can send notifications to app
//          Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
          
//          Messaging.messaging().apnsToken = deviceToken
      }
      
      func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            print("did receive remote notification")
          
          // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification

            // With swizzling disabled you must let Messaging know about the message, for Analytics
             Messaging.messaging().appDidReceiveMessage(notification)

            // Print message ID.
            if let messageID = notification[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
            }

            // Print full message.
            print(notification)

            completionHandler(UIBackgroundFetchResult.newData)
          
            // phone auth
            if Auth.auth().canHandleNotification(notification) {
              completionHandler(.noData)
              return
            }
      }
    
    // For iOS 9+
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        // MARK: turned off google sign in link in for phone below
        //        return GIDSignIn.sharedInstance.handle(url)
        
        // if the url has to do with phone auth, then it will do so
        if Auth.auth().canHandle(url) {
          return true
        }
        // URL not auth related, developer should handle it.
        
        return true
    }
    
    // For iOS 8-
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
      if Auth.auth().canHandle(url) {
        return true
      }
      // URL not auth related, developer should handle it.
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed ot register for remote notifications with error: \(error)")
    }
    
}

// cloud messaging
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
        
      // Note: This callback is fired at each app startup and whenever a new token is generated.
        let firestoreService = FirestoreService()
        let user = Auth.auth().currentUser
        
        // TODO: store it on loading of circle view and not on launch as this may just never get called
        // use the notification center above
        // https://stackoverflow.com/questions/58818046/how-to-set-addobserver-in-swiftui
        if user != nil && fcmToken != nil {
          // User is signed in.
          // ...
            print("have access to user Id when I received registration token: \(user!.uid)")
            
            // kind of have to store in database or update every time, because don't know if the user logged in and out or if there is a new token or not
            // https://firebase.google.com/docs/cloud-messaging/ios/client#access_the_registration_token
            
            firestoreService.updateUserDeviceToken(userId: user!.uid, deviceToken: fcmToken!) { res in
                print(res)
            }
        } else {
          // No user is signed in.
          // ...
            print("can't save user device token to a user")
        }
        
    }
    
}

// user notifications...in app notifications
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
      completionHandler([[.banner, .alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
