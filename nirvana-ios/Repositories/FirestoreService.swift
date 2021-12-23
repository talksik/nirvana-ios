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
            
            DispatchQueue.main.async {
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
            let userFriendCollection = db.collection(Collection.userFriends.rawValue)
            
            // get the userFriend based on...if not exists, then update
            let userFriendDocRef = userFriendCollection.whereField("userId", isEqualTo: userFriend.userId).whereField("friendId", isEqualTo: userFriend.friendId)

            userFriendDocRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("error in trying to check if user friend relationship exists \(err.localizedDescription)")
                    completion(ServiceState.error(ServiceError(description: err.localizedDescription)))
                } else {
                    // TODO: there shoudn't be multiple, see if this would cause issues
                    if querySnapshot!.documents.isEmpty {  //not existing already, create one
                        let _ = try? userFriendCollection.addDocument(from: userFriend)
                        
                        print("created new user friend! no existing relationship")
                        
                        completion(ServiceState.success("created userfriend in firestore service"))
                    }
                    else { // there seems to be something existing
                        for document in querySnapshot!.documents {
                            // update this userFriend that is existing
                            let _ = try? userFriendCollection.document(document.documentID).setData(["isActive": true, "lastUpdatedTimestamp": self.getFirestoreServerTimestamp()], merge:true)
                            print("already existing, just updated")
                            completion(ServiceState.success("updated userfriend in firestore service"))
                        }
                    }
                }
            }
            
        } catch {
            print("error in creating user friend \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
        
    }
    
    func createMessage(message: Message, completion: @escaping((_ state: ServiceState) -> ())) {
        do {
            let _ = try db.collection(Collection.messages.rawValue).addDocument(from: message)
            
            completion(ServiceState.success("message created"))
        } catch {
            print("error in creating message \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
    }
    
    func updateUserDeviceToken(userId: String, deviceToken: String, completion: @escaping((_ state: ServiceState) -> ()))  {
        do {
            if userId != nil {
                let _ = try db.collection(Collection.users.rawValue).document(userId).setData(["deviceToken": deviceToken], merge: true)
                completion(ServiceState.success("Updated user device token"))
            } else {
                completion(ServiceState.error(ServiceError(description: "No user id given to firestore service")))
            }
        } catch {
            print("error in updating user \(error.localizedDescription)")
            completion(ServiceState.error(ServiceError(description: error.localizedDescription)))
        }
    }
    
}
