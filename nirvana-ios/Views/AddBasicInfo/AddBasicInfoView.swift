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
    
    @State var firstName =  ""
    @State var lastName = ""
    
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
                    
                    Text("Select an avatar you like, then input your first and last name! You can always change this later.")
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
                                .onTapGesture {
                                    print("selected another avatar: \(index)")
                                    
                                    self.selectedAvatarIndex = index
                                }
                                .animation(.spring())
                        }
                    }.padding(.top, 20)
                }
                                
                // input first and last name
                VStack {
                    TextField("First Name", text: self.$firstName)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .keyboardType(.phonePad)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    TextField("Last Name", text: self.$lastName)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .keyboardType(.phonePad)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                
                Spacer()
                                
                // button to save information
                Button {
                    print("saving information")
                    
                    // activate loading splashscreen
                    
                    // let view model do work of saving to firestore
                    
                    // note: I need these updated attributes to be listened to when loading the circle hub next
                    // but maybe just change the data in cache and no need to re-fetch
                } label: {
                    Text("Save")
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(NirvanaColor.teal)
                        .clipShape(Capsule())
                        .shadow(radius:10)
                }
                .offset(x: 0, y: self.firstName.count == 0 || self.lastName.count == 0 ? 200 : 0)
                .animation(.spring())
                .padding()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct AddBasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AddBasicInfoView().environmentObject(AuthSessionStore())
    }
}
