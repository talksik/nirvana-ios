//
//  FirestoreService.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    enum Collection: String {
        case users = "users"
        case messages = "messages"
        case userFriends = "user_friends" // associating a user to
    }
    
    private var db = Firestore.firestore()
    
    func getUserRealtime(userId: String, completion: @escaping((_ user: User?) -> ())) {
        db.collection(Collection.users.rawValue).document(userId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching getting user realtime listener: \(error!)")
                completion(nil)
                return
            }
            
            guard let updatedOrNewUser = try? document.data(as: User.self)
            else {
                completion(nil)
                print("Document data was empty. tried fetching updated user document in firestore service")
                return
            }
            // up to date user
            completion(updatedOrNewUser)
        }
    }
    
    func getUser(userId: String, completion: @escaping((_ user: User?) -> ())) {
        let docRef = db.collection(Collection.users.rawValue).document(userId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let returnedUser = try? document.data(as: User.self)
                completion(returnedUser)
            } else {
                print("user doesn't exist")
                completion(nil)
            }
        }
    }

    func getUserByPhoneNumber(phoneNumber: String, completion: @escaping((_ user: User?) -> ())) {
        // TODO: validation here as well to verify that phone number string is even valid
        db.collection(Collection.users.rawValue).whereField("phoneNumber", isEqualTo: phoneNumber)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(nil)
                } else {
                    if !(querySnapshot?.isEmpty)! {
                        for document in querySnapshot!.documents {
                            let returnedUser = try? document.data(as: User.self)
                            completion(returnedUser)
                        }
                    } else {
                        completion(nil)
                    }
                }
        }
    }
    
    func createUser(user: User, completion: @escaping((_ state: ServiceState) -> ()))  {
        do {
            let _ = try db.collection(Collection.users.rawValue).document(user.id!).setData(from: user)
            
            completion(ServiceState.success("user created"))
        } catch {
            print("error in updating user \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
    }
    
    func updateUser(user: User, completion: @escaping((_ state: ServiceState) -> ()))  {
        do {
            if user.id != nil {
                let _ = try db.collection(Collection.users.rawValue).document(user.id!).setData(from: user)
                completion(ServiceState.success("Updated user in firestore service"))
            } else {
                completion(ServiceState.error(ServiceError(description: "No user id given to firestore service")))
            }
        } catch {
            print("error in updating user \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
    }
    
    func getCollectionRef(_ collectionName: Collection) -> CollectionReference {
        return db.collection(collectionName.rawValue)
    }
    
    func getFirestoreServerTimestamp() -> FieldValue {
        return FieldValue.serverTimestamp()
    }
    
    
    
    func createOrUpdateUserFriends(userFriend: UserFriends, completion: @escaping((_ state: ServiceState) -> ()))  {
        do {
            if userFriend.id != nil {
                let _ = try db.collection(Collection.userFriends.rawValue).addDocument(from: userFriend)
                completion(ServiceState.success("created/updated userfriend in firestore service"))
            } else {
                completion(ServiceState.error(ServiceError(description: "No userfriend id given to firestore service")))
            }
        } catch {
            print("error in creating user friend \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
        
    }
    
}
