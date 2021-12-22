//
//  CloudStorageService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/22/21.
//

import Foundation
import Firebase

class CloudStorageService {
    // Get a reference to the storage service using the default Firebase App
    private let storage = Storage.storage()

    func uploadLocalUrl(localFileUrl: URL, completion: @escaping((_ audioDataUrl: URL?) -> ())) {
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        let audioFileName = UUID().uuidString // for the firestore and cloud storage connection
        
        let audioMessageRef = storageRef.child("messages/\(audioFileName).m4a")
        
        // Upload the file to the path "images/{fileName}.m4a"
        let uploadTask = audioMessageRef.putFile(from: localFileUrl, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
              print("error in uploading audio file to cloud storage")
              completion(nil)
            return
          }
            
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
            
          // You can also access to download URL after upload.
            audioMessageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                    completion(nil)
                  return
                }
                  print("successfully got the download online url that I need\(downloadURL)")
                  completion(downloadURL)
              }
        }
    }
}
