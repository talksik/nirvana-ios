//
//  NavigationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack

struct CircleNavigationView: View {
    @EnvironmentObject var innerCircleVM: InnerCircleViewModel
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    @Binding var alertActive: Bool
    @Binding var alertText: String
    @Binding var alertSubtext: String
    
    var body: some View {
        HStack(alignment: .center) {
            Menu {
                Button {
                    print("going to show contacts now")
                    self.navigationStack.push(FindFriendsView())
                } label: {
                    Label("add peeps", systemImage: "person.2.wave.2")
                        .foregroundColor(NirvanaColor.teal)
                }
                
                Button {
                    self.navigationStack.push(AddBasicInfoView())
                } label: {
                    Label("profile", systemImage: "person.crop.circle")
                        .foregroundColor(NirvanaColor.teal)
                }
                
                Button {
                    self.navigationStack.push(OnboardingOneView())
                } label: {
                    Label("why?", systemImage: "leaf")
                        .foregroundColor(NirvanaColor.teal)
                }
                
                Button {
                    print("navigate to usenirvana.com")
                    if let url = URL(string: "https://usenirvana.com") {
                       UIApplication.shared.open(url)
                   }
                    
                } label: {
                    Label("about us", systemImage: "globe.americas")
                        .foregroundColor(NirvanaColor.teal)
                }
                
                Button(role: .destructive) {
                    print("log out button clicked")
                    
                    self.authSessionStore.logOut()
                    
                    // once logged out, then the listener will listen and router view will take care of us thereafter
                } label: {
                    Label("log out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(NirvanaColor.teal)
                }
                
            } label: {
                if self.authSessionStore.user?.avatar == nil {
                    Image("Artboards_Diversity_Avatars_by_Netguru-1")
                        .resizable()
                        .scaledToFit()
                        .background(NirvanaColor.teal.opacity(0.1))
                        .blur(radius: 5)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(5)
                } else {
                    Image((self.authSessionStore.user?.avatar)!)
                        .resizable()
                        .scaledToFit()
                        .background(self.innerCircleVM.isRecording ? Color.orange : NirvanaColor.teal.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(5)
                        .shadow(radius: 10)
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    Button {
                        
                    } label: {
                        Label("circle", systemImage: "peacesign")
                            .font(.caption2)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.teal.opacity(0.5))
                            ).overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(01), lineWidth: 1)
                            )
                    }
                
                    
                    Button {
                        self.alertActive.toggle()
                        
                        self.alertText = "👯‍♂️ Coming Soon!"
                        
                        self.alertSubtext = "Stay posted for buttery smooth convos with groups! We will be limiting you to 3 circles!"
                    } label: {
                        Label("circles", systemImage: "circle.hexagongrid")
                            .font(.caption2)
                            .foregroundColor(Color.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(1), lineWidth: 1)
                            )
                    }
                    
                    Button {
                        self.alertActive.toggle()
                        
                        self.alertText = "💼 Coming Soon!"
                        
                        self.alertSubtext = "Efficient and more authentic communication for teams! Contact us for more info."
                        
                    } label: {
                        Label("work", systemImage: "suitcase")
                            .font(.caption2)
                            .foregroundColor(Color.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(1), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

//struct CircleNavigationView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleNavigationView().environmentObject(AuthSessionStore(isPreview: true))
//    }
//}
