//
//  ConvoFooterView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/30/21.
//

import SwiftUI

struct ConvoFooterView: View {
    @EnvironmentObject var convoVM: ConvoViewModel
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var innerCircleVM: InnerCircleViewModel
    
    @State private var convoRelativeTime = ""
    @State private var selectedConvo: Convo? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                HStack {
                    if self.selectedConvo != nil {
                        // TODO: get their info for warm intros to be made
//                        var unknownUsers = self.selectedConvo!.users.filter {userId in
//                            return !self.authSessionStore.relevantUsersDict.keys.contains(userId)
//                        }
                        // the users which I have data for
                        let filteredUsers = self.authSessionStore.relevantUsersDict.filter {
                            return self.selectedConvo!.users.contains($0.key)
                        }
                        let convoUsers: [User] = Array(filteredUsers.values).sorted(by: { $0.nickname ?? "" > $1.nickname ?? "" })
                        
                        ProfilePicturesOverlappedView(indvAvatarWidth: CGFloat(35), users: convoUsers)
                            .padding(.leading, 20)
                            .padding(.trailing, 10)
                                                                    
                        // meta data of convo
                        VStack (alignment: .leading) {
                            ConvoUsernames(users: convoUsers, unknownUserCount: self.selectedConvo!.users.count - convoUsers.count)
                            
                            switch self.convoVM.connectionState {
                            case .connecting:
                                Label("connecting", systemImage: "chart.bar")
                                    .foregroundColor(Color.orange)
                                    .font(.caption)
                            case .connected:
                                Label("connected", systemImage: "chart.bar.fill")
                                    .foregroundColor(Color.green)
                                    .font(.caption)
                            case .reconnecting:
                                Label("reconnecting", systemImage: "chart.bar")
                                    .foregroundColor(Color.orange)
                                    .font(.caption)
                            case .failed:
                                Label("failed", systemImage: "chart.bar")
                                    .foregroundColor(Color.red)
                                    .font(.caption)
                            case .disconnected:
                                Label("disconnected", systemImage: "chart.bar")
                                    .foregroundColor(Color.red)
                                    .font(.caption)
                            default:
                                Label("disconnected", systemImage: "chart.bar")
                                    .foregroundColor(Color.red)
                                    .font(.caption)
                            }
                            
                            Text(self.convoRelativeTime)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // disconnect button
                        Button {
                            print("showing more info about the chat")
                            
                            // show a sheet of the members in the call and add them if I want
                            
                        } label: {
                            Label("attendees", systemImage: "person.2.circle.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(NirvanaColor.teal)
                                .font(.title2)
                                .padding(.trailing, 5)
                        }
                        
                        // disconnect button
                        Button {
                            print("disconnecting user now ")
                            
                            self.innerCircleVM.setupMessagingAudioSession()
                            
                            self.convoVM.leaveConvo()
                            
                            
                            // show success or failure toast
                        } label: {
                            Label("Call", systemImage: "powerplug.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(Color.red)
                                .font(.title2)
                                .padding(.trailing, 5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 60) // 60 is the height of the footer control big circle
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
            }
        }
        .padding()
        .animation(Animation.spring(), value: self.convoVM.selectedConvoId)
        .offset(
            x:0,
            y:self.convoVM.selectedConvoId == nil ? 150 : 0
        )
        .onReceive(self.convoVM.$relevantConvos) {newConvos in
            // update meta data based on which convo was selected
            
            if self.convoVM.selectedConvoId == nil {
                print("nothing to show as there is no convo selected")
                return
            }
            
            self.selectedConvo = newConvos.first {convo in
                convo.id == self.convoVM.selectedConvoId
            }
        }
        .onReceive(timer) { _ in
            if self.selectedConvo != nil {
                // get relative start time of convo
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                self.convoRelativeTime = "started " + formatter.localizedString(for: self.selectedConvo?.startedTimestamp ?? Date(), relativeTo: Date())
            }
        }
    }
}

struct ConvoFooterView_Previews: PreviewProvider {
    static var previews: some View {
        ConvoFooterView()
    }
}

struct ConvoUsernames: View {
    var users: [User]
    var unknownUserCount: Int = 0
    
    var body: some View {
        if let userId = AuthSessionStore.getCurrentUserId() {
            let userNames = self.users.map{user in
                if user.id == userId {
                    return "me"
                }
                
                return user.nickname ?? ""
            }.joined(separator: ", ")
            Text(unknownUserCount > 0 ? "\(userNames), and \(unknownUserCount) other(s)": userNames)
                .foregroundColor(NirvanaColor.light)
        }
        else {
            EmptyView()
        }
    }
}
