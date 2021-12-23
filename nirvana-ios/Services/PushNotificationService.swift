//
//  PushNotificationService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/23/21.
//

import Foundation

class PushNotificationService {
    
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
}

