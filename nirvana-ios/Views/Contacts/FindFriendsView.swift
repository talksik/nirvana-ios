//
//  FindFriendsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import Contacts
import NavigationStack
import AlertToast

struct FindFriendsView: View {
    @EnvironmentObject var navigationStack : NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    @StateObject var contactsVM = ContactsViewModel()
    
    @State private var searchQuery: String = ""
    
    var body: some View {
        // main content
        NavigationView {
            VStack {
                Text("You must have someone in your phone contacts to add them. Remember: \(self.authSessionStore.friendsArr.count)/\(RuleBook.maxFriends) spots filled in your circle. 🥬")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal)
                
                List {
                    ForEach(searchItems, id: \.self) { key in
                        if let currContact = self.contactsVM.contacts[key] { // getting contact's info
                            ListContactRow(contactsVM: self.contactsVM, contact: currContact)
                        }
                    }
                }
                .searchable(text: self.$searchQuery)
            }
            .navigationBarTitle("Find Friends")
            .navigationBarItems(
                leading:
                    Button {
                        self.navigationStack.pop()
                    } label: {
                        Label("back", systemImage:"chevron.left")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .foregroundColor(NirvanaColor.teal)
                    }
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.contactsVM.fetchContacts()
        }
        .toast(isPresenting: self.$contactsVM.showToast) {
            self.contactsVM.toast?.view ?? AlertToast(displayMode: .hud, type: .error(Color.red), title: "Something went wrong")
        }
    }
    
    var searchItems: [String] {
        let keys = (Array(self.contactsVM.contacts.keys) as [String]).sorted()
        
        // checking if currcontact is already a friend
        let newPotentialFriends = keys.filter {contactSortProp in
            if let friend = self.contactsVM.contacts[contactSortProp]?.user { // seeing if this contact is an existing user
                // if this is already an ACTIVE friend -> don't show
                // we want to show inactive friends
                if self.authSessionStore.friendsArr.contains(friend.id!) {
                    return false
                }
                
                // goes here if is an existing contact and not a friend
            }
            
            return true
        }
        
        if self.searchQuery.isEmpty  {
            return newPotentialFriends
        } else {
            return newPotentialFriends.filter { $0.contains(self.searchQuery) }
        }
    }
    
    
}

struct FindFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FindFriendsView().environmentObject(AuthSessionStore(isPreview: true))
    }
}

// TODO: just encapsulate in main sheet view so that the dismiss works nicely
struct ListContactRow: View {
    @EnvironmentObject var navigationStack : NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    @ObservedObject var contactsVM: ContactsViewModel
    var contact:ContactsViewModelContact
    
    @State var showAlert = false
    @State var alertText = "🌱Confirm Arjun into Your Circle?"
    @State var alertMessage = "Note: You can have a maximium of \(RuleBook.maxFriends) people in your circle!"
    
    var body: some View {
        if contact.isExisting { // add to circle
            // TODO: check if this contact is already in user's circle
            HStack(alignment: .center, spacing: 0) {
                Image(contact.user?.avatar ?? SystemImages.avatars[1])
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 10)
                        
                Text(contact.cnName)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    print("showing alert now")
                    if self.authSessionStore.friendsArr.count >= RuleBook.maxFriends {
                        self.contactsVM.toast = .maxFriendsInCircle
                        return
                    }
                    
                    self.showAlert.toggle()
                    
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .font(.title3)
                        .foregroundColor(NirvanaColor.solidTeal)
                }
            }
            .alert(isPresented: self.$showAlert) {
                Alert(
                    title: Text(self.alertText),
                    message: Text(self.alertMessage),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .default(Text("Confirm")) {
                        print("adding contact to circle")
                        if self.authSessionStore.friendsArr.count >= RuleBook.maxFriends {
                            self.contactsVM.toast = .maxFriendsInCircle
                            return
                        }
                        
                        self.contactsVM.addOrActivateFriendToCircle(userId: self.authSessionStore.user!.id!, friendId: (contact.user!.id)!) {res in
                            print(res)
                            
                            switch res {
                            case .error(let err):
                                print(err)
                                self.contactsVM.toast = .generalError
                            case .success(let str):
                                print(str)
                                self.contactsVM.toast = .addedFriend
                                self.navigationStack.push(InnerCircleView())
                            }
                        }
                    }
                )
            }
            
        }
        else { // invite button to text the person
            HStack(alignment: .center, spacing: 0) {
                Image(SystemImages.avatars[1])
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                    .padding(.trailing, 10)
                
                Text(contact.cnName)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    print("inviting user now")
                    // text message to him/her
                    
                    if contact.cnPhoneNumber != nil {
                        let sms: String = "sms://\(contact.cnPhoneNumber)&body=Join me on Nirvana! I sent you a message there! https://usenirvana.com"
                        let strUrl: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        
                        UIApplication.shared.open(URL(string: strUrl)!, options: [:], completionHandler: nil)
                    } else {
                        print("phone number is nil of contact")
                        self.contactsVM.toast = .generalError
                    }
                } label: {
                    Label("Invite", systemImage: "paperplane")
                        .font(.title3)
                        .foregroundColor(Color.orange)
                }
            }
        }
    }
}


