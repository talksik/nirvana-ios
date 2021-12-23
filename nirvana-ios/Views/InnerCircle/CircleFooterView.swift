//
//  CircleFooterView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack

struct CircleFooterView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore

    @Binding var selectedFriendIndex: Int?
    
    @State private var convoRelativeTime = ""
    @State private var selectedFriend: User?
    @State private var myTurn: Bool?
    
    var body: some View {
        // TODO: do cool animations with this footer background fill in while recording or playing a message
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                HStack {
                    if self.selectedFriend != nil {
                        // friend avatar
                        Image(self.selectedFriend!.avatar ?? "")
                            .resizable()
                            .scaledToFit()
                            .background(NirvanaColor.teal.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(5)
                    }
                    
                    
                    
                    // meta data of convo
                    VStack (alignment: .leading) {
                        if self.selectedFriend != nil {
                            Text(self.selectedFriend!.nickname ?? "")
                                .font(.footnote)
                                .foregroundColor(NirvanaColor.light)
                        }
                        if !self.convoRelativeTime.isEmpty && self.myTurn != nil {
                            Text(self.convoRelativeTime)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if self.selectedFriend != nil {
                        // call button
                        Button {
                            print("calling user now")
                            
                            if self.selectedFriend?.phoneNumber != nil {
                                let tel: String = "tel://\(self.selectedFriend!.phoneNumber!)"
                                let strUrl: String = tel.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                
                                UIApplication.shared.open(URL(string: strUrl)!, options: [:], completionHandler: nil)
                            } else {
                                print("phone number is nil of contact")
                            }
                        } label: {
                            Label("Call", systemImage: "phone.and.waveform")
                                .labelStyle(.iconOnly)
                                .foregroundColor(NirvanaColor.teal)
                                .padding()
                                .font(.title2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 60) // 60 is the height of the footer control big circle
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
            }
        }
        .padding()
        .animation(Animation.spring(), value: self.selectedFriendIndex)
        .offset(
            x:0,
            y:self.selectedFriendIndex == nil ? 150 : 0
        )
        .onChange(of: self.selectedFriendIndex) {newValue in
            // update meta data based on which friend was selected
            let myId = self.authSessionStore.user?.id
            
            // set convo moment/relative time to show
            if newValue != nil && myId != nil {
                self.selectedFriend = self.authSessionStore.friendsArr[newValue!]
                
                // get the latest message's timestamp...will be the first in list now
                let lastMessage = self.authSessionStore.friendMessagesDict[self.selectedFriend!.id!]?.first
                if lastMessage != nil {
                    // figure out whose turn it is
                    self.myTurn = lastMessage!.receiverId == myId! ? true : false
                                        
                    // ask for the full relative date
                    let formatter = RelativeDateTimeFormatter()
                    formatter.unitsStyle = .full

                    let relativeDate = formatter.localizedString(for: lastMessage?.sentTimestamp ?? Date(), relativeTo: Date())

                    print("Relative date is: \(relativeDate)")
                    
                    // setting the state for ui to update
                    self.convoRelativeTime = self.myTurn! ? "received " + relativeDate: "sent " + relativeDate
                }
            }
        }
    }
}

struct CircleFooterView_Previews: PreviewProvider {
    static var previews: some View {
        CircleFooterView(selectedFriendIndex: Binding.constant(nil)).environmentObject(AuthSessionStore())
    }
}
