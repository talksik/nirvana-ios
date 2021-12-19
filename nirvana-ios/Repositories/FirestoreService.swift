//
//  FirestoreService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreService {
    enum Collection: String {
        case users = "users"
        case messages = "messages"
        case user_friends = "user_friends" // associating a user to
    }
    
    private var db = Firestore.firestore()
    
    func getUser(userId: String) -> User? {
        let docRef = db.collection(Collection.users.rawValue).document(userId)

        var user:User? = nil
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                user = try? document.data(as: User.self)
            } else {
                user = nil
            }
        }
        
        return user
    }
    
    func createUser(user: User) {
        do {
            let _ = try db.collection(Collection.users.rawValue).addDocument(from: user)
        } catch {
            print("error in creating user \(error.localizedDescription)")
        }
    }
    
    func updateUser(user: User) -> ServiceState {
        do {
            if user.id != nil {
                let _ = try db.collection(Collection.users.rawValue).document(user.id!).setData(from: user)
                return ServiceState.success("Updated user in firestore service")
            } else {
                return ServiceState.error(ServiceError(description: "No user id given to firestore service"))
            }
        } catch {
            print("error in creating user \(error.localizedDescription)")
            return ServiceState.error(ServiceError(description: error.localizedDescription))
        }
    }
    
    func getCollectionRef(_ collectionName: Collection) -> CollectionReference {
        return db.collection(collectionName.rawValue)
    }
    
    func getFirestoreServerTimestamp() -> FieldValue {
        return FieldValue.serverTimestamp()
    }
    
}
