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
    
    @State private var convoRelativeTime = "started 20 minutes ago"
    @State private var selectedConvo: Convo? = nil
    
    var body: some View {
        
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                HStack {
                    if self.selectedConvo != nil {
                        let filteredUsers = self.authSessionStore.relevantUsersDict.filter {
                            return self.selectedConvo!.users.contains($0.key)
                        }
                        let convoUsers: [User] = Array(filteredUsers.values)
                        
                        ProfilePicturesOverlappedView(indvAvatarWidth: CGFloat(35), users: convoUsers)
                            .padding(.leading, 20)
                            .padding(.trailing, 10)
                                                                    
                        // meta data of convo
                        VStack (alignment: .leading) {
                            ConvoUsernames(users: convoUsers)
                            
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
                            
                            self.convoVM.leaveConvo()
                                                    
                            // show success or failure toast
                        } label: {
                            Label("Call", systemImage: "powerplug.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(Color.orange)
                                .font(.title2)
                                .padding(.trailing, 5)
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
        .animation(Animation.spring(), value: self.convoVM.selectedConvoId)
        .offset(
            x:0,
            y:self.convoVM.selectedConvoId == nil ? 150 : 0
        )
        .onReceive(self.convoVM.$selectedConvoId) {newConvoId in
            // update meta data based on which convo was selected
            
            // reset the selected options to start fresh
            self.convoRelativeTime = ""
            
            self.selectedConvo = self.convoVM.relevantConvos.first {convo in
                convo.id == newConvoId
            }
            
            // get relative start time of convo
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.convoRelativeTime = formatter.localizedString(for: self.selectedConvo?.startedTimestamp ?? Date(), relativeTo: Date())
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
    
    var body: some View {
        let userNames = self.users.map{$0.nickname ?? ""}.joined(separator: ",")
        Text(userNames)
            .font(.footnote)
            .foregroundColor(NirvanaColor.light)
    }
}
