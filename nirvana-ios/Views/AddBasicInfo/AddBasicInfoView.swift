//
//  AddBasicInfoView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI
import NavigationStack

struct AddBasicInfoView: View {
    @EnvironmentObject var navigationStack : NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @ObservedObject var addInfoViewModel: AddBasicInfoViewModel = AddBasicInfoViewModel()
    
    @State var nickname =  ""
    @State var selectedAvatarIndex: Int = 0
    
    var columns: [GridItem] =
    Array(
        repeating: GridItem(.fixed(100), spacing: 0, alignment: .center),
        count: 5)
    
    var body: some View {
        ZStack {
            // bg
            WavesGlassBackgroundView()
            
            // programmatic back button
            ZStack(alignment: .topLeading) {
                Color.clear
                
                Button {
                    self.navigationStack.pop()
                } label: {
                    Label("back", systemImage:"chevron.left")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                .padding()
            }
            
            // main content
            VStack {
                // header logo area
                LogoHeaderView()
                
                // action text
                VStack(alignment: .leading) {
                    Text("Let's Build A Profile")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(NirvanaColor.teal)
                        .multilineTextAlignment(.center)
                    
                    Text("Select an avatar you like, then make a username! You can always change this later.")
                        .font(.subheadline)
                        .foregroundColor(Color.black.opacity(0.7))
                }
                .padding()
                
                // Horizontal scroll view to allow user to select the avatar he or she wants
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVGrid(columns: columns) {
                        ForEach(0..<Avatars.avatarSystemNames.count) { index in
                            Image(Avatars.avatarSystemNames[index])                                
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100, alignment: .center)
                                .blur(radius: self.selectedAvatarIndex == index ? 0 : 1)
                                .scaleEffect(self.selectedAvatarIndex == index ? 1.3 : 1)
                                .padding()
                                .background(self.selectedAvatarIndex == index ? Color.white.opacity(0.3) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    print("selected another avatar: \(index)")
                                    
                                    self.selectedAvatarIndex = index
                                }
                                .animation(.spring())
                        }
                    }.padding(.top, 20)
                }
                                
                // input nickname
                VStack {
                    TextField("Nickname", text: self.$nickname)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        
                    Text("What do your friends call you?")
                        .font(.footnote)
                        .foregroundColor(Color.black.opacity(0.7))
                
                }
                .padding()
                
                
                Spacer()

                // button to save information
                Button {
                    var updatedUser = self.authSessionStore.user
                    updatedUser?.avatar = Avatars.avatarSystemNames[self.selectedAvatarIndex]
                    updatedUser?.nickname = self.nickname                    
                    
                    print("attempting to save information \(updatedUser)")
                    
                    if updatedUser != nil {
                        self.addInfoViewModel.updateUser(currUser: updatedUser!) {
                            self.navigationStack.push(InnerCircleView())
                        }
                    }                    
                } label: {
                    Text("Save")
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(self.nickname.count == 0 ? Color.white.opacity(0.3) : NirvanaColor.teal)
                        .clipShape(Capsule())
                        .shadow(radius:10)
                }
                .animation(.default)
                .padding()
            }
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            // get current user nickname and avatar if they have one
            self.nickname = self.authSessionStore.user?.nickname ?? ""
            if self.authSessionStore.user?.avatar != nil { // if user has previously selected an avatar
                self.selectedAvatarIndex = Avatars.avatarSystemNames.firstIndex(of: (self.authSessionStore.user?.avatar)!) ?? 0 // 0 in case the system names doesn't have it anymore
            }
        }
        //TODO: hook up the alert with the view model
//        .alert(isPresented: Binding<Bool>(
//            get: { self.addInfoViewModel.state == ProfileRegistrationState.failed},
//            set: { _ in self.addInfoViewModel.state = ProfileRegistrationState.na }
//        )) {
//            Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
//        }
    }
}

struct AddBasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AddBasicInfoView().environmentObject(AuthSessionStore())
    }
}
