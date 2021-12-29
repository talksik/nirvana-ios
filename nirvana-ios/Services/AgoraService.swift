//
//  AgoraService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import FirebaseAuth
import Firebase

class AgoraService {
    func getAgoraUserToken(channelName: String) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            // Handle error
            return;
          }

          // Send token to your backend via HTTPS
          // ...
            let baseUrl = ProcessInfo.processInfo.environment["nirvana-server-url"] ?? "http://localhost:3000"
            let reqUrl = baseUrl + "agoraToken?channelName=" + channelName
            guard let url = URL(string: reqUrl) else { fatalError("Missing URL") }

            var urlRequest = URLRequest(url: url)
            urlRequest.addValue(idToken!, forHTTPHeaderField: "authorization")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print("Request error: ", error)
                    return
                }

                guard let response = response as? HTTPURLResponse else { return }

                if response.statusCode == 200 {
                    guard let data = data else { return }
                    print("the token is: \(data)")
                }
            }

            dataTask.resume()
        }
    }
}