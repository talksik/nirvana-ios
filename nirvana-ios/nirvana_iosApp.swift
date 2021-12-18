//
//  nirvana_iosApp.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

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
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
          print("Colors application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
            
          print("initialized Firebase")
          FirebaseApp.configure()
          return true
      }
    
      func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          print("\(#function)")
          //MARK: add this when I have APN setup through app
          // gets the APN token so that firebase can send notifications to app
//          Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
      }
      
      func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            print("did receive remote notification")
            print("\(#function)")
          //MARK: add this when I have APN setup through app
//            if Auth.auth().canHandleNotification(notification) {
//              completionHandler(.noData)
//              return
//            }
          
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
}
