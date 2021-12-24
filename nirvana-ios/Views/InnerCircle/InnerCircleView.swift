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
    
    @State var selectedFriendIndex: Int? = nil
    
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
            else if self.authSessionStore.friendsArr.count == 0 {
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
                Image("undraw_fall_is_coming_yl-0-x")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .blur(radius: 20)
                
                
                // content
                CircleGridView(selectedFriendIndex: self.$selectedFriendIndex)
                    .environmentObject(innerCircleVM)
            }
            
            // header
            VStack(alignment: .leading) {
                
                CircleNavigationView(alertActive: self.$alertActive, alertText: self.$alertText, alertSubtext: self.$alertSubtext).environmentObject(innerCircleVM)
                
                Spacer()
            }
            
            CircleFooterView(selectedFriendIndex: self.$selectedFriendIndex)
            
            // helper for new users
            if self.authSessionStore.friendsArr.count <= 1 {
                ZStack(alignment: .bottomTrailing) {
                    Color.clear

                    Button {
                        self.alertActive.toggle()
                        self.alertText = "👆🏼It's simple!"
                        self.alertSubtext = "Press and hold to send a message. \n Tap to listen!"
                    } label: {
                        Label("help!", systemImage: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(NirvanaColor.teal)
                            .padding()
                            .background(.ultraThinMaterial)
                            .shadow(radius: 10)
                            .clipShape(Circle())
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .alert(self.alertText, isPresented: self.$alertActive) {

            Button("OK", role: ButtonRole.cancel) { }

        } message: {
            Text(self.alertSubtext)
        }
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
