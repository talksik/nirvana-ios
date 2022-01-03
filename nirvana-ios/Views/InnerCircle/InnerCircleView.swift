//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI
import NavigationStack
import AlertToast

struct InnerCircleView: View {
    @StateObject var convoViewModel: ConvoViewModel = ConvoViewModel()
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
            
            // stale state: create profile
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
            } // add friend: stale state
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
                // inner circle grid
                CircleGridView(selectedFriendIndex: self.$selectedFriendIndex)
                    .environmentObject(self.innerCircleVM)
                    .environmentObject(self.convoViewModel)
            }
            
            // header
            ZStack(alignment: .topLeading) {
                Color.clear
                
                CircleNavigationView().environmentObject(innerCircleVM)
            }
            
            CircleFooterView(selectedFriendIndex: self.$selectedFriendIndex)
                .environmentObject(self.innerCircleVM)
                .environmentObject(self.convoViewModel)
            
            ConvoFooterView()
                .environmentObject(self.convoViewModel)
        }
        .alert(self.alertText, isPresented: self.$alertActive) {

            Button("OK", role: ButtonRole.cancel) { }

        } message: {
            Text(self.alertSubtext)
        }
        .onAppear {
            // activate 3 data listeners once for authsessionstore/usermanager if not already called, but authsessionstore will handle that
            // TODO: can/should do this on init of view model
            self.authSessionStore.activateMainDataListeners()
                        
            // set up push notifications and such + save up to date device token
            // TODO: this is firing too often?
            self.innerCircleVM.setUpPushNotifications()
            
            // set status of user to online
            self.authSessionStore.updateUserStatus(userStatus: .online)
        }
        .toast(isPresenting: self.$convoViewModel.showToast) {
            self.convoViewModel.toast?.view ?? AlertToast(displayMode: .hud, type: .error(Color.red), title: "Something went wrong")
        }
        .toast(isPresenting: self.$innerCircleVM.showToast) {
            self.innerCircleVM.toast?.view ?? AlertToast(displayMode: .hud, type: .error(Color.red), title: "Something went wrong")
        }
//        .onDisappear {
//            print("deiniting data listeners, but current data should still be cached!")
//
//            // deactivate all data listeners
//            self.authSessionStore.deinitAllDataListeners()
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
