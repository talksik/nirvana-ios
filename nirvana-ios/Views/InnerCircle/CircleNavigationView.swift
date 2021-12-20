//
//  NavigationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack

struct CircleNavigationView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    var body: some View {
        HStack(alignment: .center) {
            Menu {
                Button("Edit Profile") {
                    self.navigationStack.push(AddBasicInfoView())
                }
                
                Button("Friends") {
                    print("manage friends page")
                }
                
                Button("Log out") {
                    print("log out button clicked")
                    
                    self.authSessionStore.logOut()
                    
                    // once logged out, then the listener will listen and router view will take care of us thereafter
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
                        .background(NirvanaColor.teal.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(5)
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
                        
                    } label: {
                        Label("groups", systemImage: "rectangle.3.group")
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

struct CircleNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CircleNavigationView()
    }
}