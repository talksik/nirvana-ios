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
    @EnvironmentObject var innerCircleVM: InnerCircleViewModel

    @Binding var selectedFriendIndex: String?
    
    @State private var convoRelativeTime = ""
    @State private var selectedFriend: User?
    @State private var myTurn: Bool?
    @State private var showDetails = false
    
    var body: some View {
        // TODO: do cool animations with this footer background fill in while recording or playing a message
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                if self.showDetails {
                    HStack {
                        // friend avatar
                        Image(self.selectedFriend!.avatar ?? "")
                            .resizable()
                            .scaledToFit()
                            .background(NirvanaColor.teal.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(alignment: .topTrailing) {
                                // user status
                                ZStack(alignment: .topTrailing) {
                                    if self.myTurn ?? false {
                                        ProgressBarView(progress: self.innerCircleVM.messagesListeningProgress, color: Color.orange)
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    UserStatusView(status: self.selectedFriend!.userStatus, size: 10)
                                }
                            }
                            .padding(5)
                     
                        // meta data of convo
                        VStack (alignment: .leading) {
                            
                            Text((self.selectedFriend!.nickname ?? "") + " ")
                                .font(.footnote)
                                .foregroundColor(NirvanaColor.light)
                            +
                            UserStatusTextView(status: self.selectedFriend!.userStatus).body
                            
                            if !self.convoRelativeTime.isEmpty && self.myTurn != nil {
                                if self.myTurn! {
                                    Label("your turn", systemImage: "wave.3.right.circle.fill")
                                        .foregroundColor(Color.orange)
                                        .font(.caption)
                                } else {
                                    Label("their turn", systemImage: "wave.3.right.circle.fill")
                                        .foregroundColor(NirvanaColor.dimTeal)
                                        .font(.caption)
                                }
                                
                                Text(self.convoRelativeTime)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // friend options
                        Menu {
                            Button(role: .destructive) {
                                print("deactivating friend...removing from circle")
                                if self.authSessionStore.user?.id != nil && self.selectedFriendIndex != nil {
                                    self.innerCircleVM.activateOrDeactiveInboxUser(activate: false, userId: self.authSessionStore.user!.id!, friendId: self.selectedFriendIndex!)
                                    
                                    self.selectedFriendIndex = nil
                                }
                            } label: {
                                Label("remove from circle", systemImage: "person.crop.circle.fill.badge.minus")
                            }
                            
                            Button {
                                self.innerCircleVM.toast = .shareAddyPreview
                            } label: {
                                Label("share addy", systemImage: "house.circle.fill")
                            }
                            
                            
                        } label: {
                            Label("friend options", systemImage: "leaf.circle.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(NirvanaColor.dimTeal)
                                .font(.title)
                        }
                        .frame(height: 90)
                        .padding(.trailing, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 60) // 60 is the height of the footer control big circle
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
                    .transition(.scale)
                }
            }
        }
        .padding()
        .onChange(of: self.selectedFriendIndex) {_ in
            self.updateLocals()
        }
    }
    
    func updateLocals() {
        // update meta data based on which friend was selected
        let myId = AuthSessionStore.getCurrentUserId()
        
        // reset the selected options to start fresh
        withAnimation {
            self.showDetails = false
        }
        
        self.selectedFriend = nil
        self.myTurn = false
        self.convoRelativeTime = ""
                    
        // set convo moment/relative time to show
        if myId != nil && self.selectedFriendIndex != nil {
            self.selectedFriend = self.authSessionStore.relevantUsersDict[self.selectedFriendIndex!]
            
            // get the latest message's timestamp...will be the first in list now
            let lastMessage = self.authSessionStore.relevantMessagesByUserDict[self.selectedFriend!.id!]?.first
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
            
            withAnimation {
                self.showDetails = true
            }
        }
    }
}

struct CircleFooterView_Previews: PreviewProvider {
    static var previews: some View {
        CircleFooterView(selectedFriendIndex: Binding.constant(nil)).environmentObject(AuthSessionStore())
    }
}
