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
                
                Text("Let's Build Your Profile")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(NirvanaColor.teal)
                    .multilineTextAlignment(.center)
                
                // Horizontal scroll view to allow user to select the avatar he or she wants
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(0..<Avatars.avatarSystemNames.count) { index in
                            Image(Avatars.avatarSystemNames[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100, alignment: .center)
                                .blur(radius: self.selectedAvatarIndex == index ? 0 : 4)
                                .onTapGesture {
                                    print("selected another avatar: \(index)")
                                    
                                    self.selectedAvatarIndex = index
                                }
                        }
                    }
                }
                .padding()
                                
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
