//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI
import NavigationStack

struct InnerCircleView: View {
    @StateObject var innerCircleVM: InnerCircleViewModel = InnerCircleViewModel()
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    
    @State var selectedFriendIndex: String? = nil
    
    let universalSize = UIScreen.main.bounds
        
    @State var alertActive = false
    @State var alertText = ""
    @State var alertSubtext = ""
    
    var body: some View {
        ZStack {
            // background
            WavesGlassBackgroundView(isRecording: self.innerCircleVM.isRecording)
            
            // stale states
            if self.authSessionStore.user?.nickname == nil || self.authSessionStore.user?.avatar == nil {
                VStack(alignment: .center) {
                    Image("undraw_fall_is_coming_yl-0-x")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom)
                    
                    Button {
                        self.navigationStack.push(AddBasicInfoView())
                    } label: {
                        Text("Create Profile")
                            .fontWeight(.heavy)
                            .foregroundColor(NirvanaColor.white)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    Text("Personalize with a simple avatar and nickname! 🌿")
                        .font(.caption)
                        .foregroundColor(NirvanaColor.teal)
                        .multilineTextAlignment(.center)
                        
                }
                .padding()
            }
            else if self.authSessionStore.friendsArr.count == 0 && self.authSessionStore.inboxUsersArr.count == 0 {
                VStack(alignment: .center) {
                    Image("undraw_fall_is_coming_yl-0-x")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom)
                    
                    Button {
                        self.navigationStack.push(FindFriendsView())
                    } label: {
                        Text("Add Friends")
                            .fontWeight(.heavy)
                            .foregroundColor(NirvanaColor.white)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    Text("Start talking with your bestie right away! 🐥")
                        .font(.caption)
                        .foregroundColor(NirvanaColor.teal)
                        .multilineTextAlignment(.center)
                        
                }
                .padding()
            } else {                 
                // content
                CircleGridView(selectedFriendIndex: self.$selectedFriendIndex)
                    .environmentObject(innerCircleVM)
            }
            
            // header
            VStack(alignment: .leading) {
                
                CircleNavigationView(alertActive: self.$alertActive, alertText: self.$alertText, alertSubtext: self.$alertSubtext).environmentObject(innerCircleVM)
                
                Spacer()
            }
            
            CircleFooterView(selectedFriendIndex: self.$selectedFriendIndex).environmentObject(innerCircleVM)
            
            // helper for new users
            // TODO: make it back to 1 instead of 10...testing
            if self.authSessionStore.friendsArr.count == 1 && self.selectedFriendIndex == nil { // don't show if bottom metadata showing
                ZStack(alignment: .bottomTrailing) {
                    Color.clear

                    Button {
                        self.alertActive.toggle()
                        self.alertText = "👆🏼It's simple!"
                        self.alertSubtext = "Press and hold on a friend to send a message. \n Tap on them to listen!"
                    } label: {
                        Label("help!🙉", systemImage: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(NirvanaColor.teal)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .shadow(radius: 10)
                            .labelStyle(.titleOnly)
                            .clipShape(Capsule())
                    }
                    .padding()
                }
                .transition(.slide)
            }
        }
        .alert(self.alertText, isPresented: self.$alertActive) {

            Button("OK", role: ButtonRole.cancel) { }

        } message: {
            Text(self.alertSubtext)
        }
        .onAppear {
            // activate 3 data listeners once for authsessionstore/usermanager if not already called, but authsessionstore will handle that
            self.authSessionStore.activateMainDataListeners()
                        
            // set up push notifications and such + save up to date device token
            // TODO: this is firing too often?
            self.innerCircleVM.setUpPushNotifications()
        }
//        .onDisappear {
//            print("deiniting data listeners, but current data should still be cached!")
//
//            // deactivate all data listeners
//            self.authSessionStore.deinitDataListeners()
//        }
    }
}

struct InnerCircleView_Previews: PreviewProvider {
    static var previews: some View {
        InnerCircleView().environmentObject(AuthSessionStore(isPreview: true))
    }
}

//
//struct Axes : View {
//    var body: some View {
//        GeometryReader { geometry in
//            Path {path in
//                path.move(to: CGPoint(x: geometry.frame(in: .global).maxX, y: geometry.))
//
//            }
//        }
//    }
//}
