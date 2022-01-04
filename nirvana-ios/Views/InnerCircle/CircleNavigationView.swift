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
                    
                    // TODO: brute force navigating out as it's not working
                    self.navigationStack.push(RouterView())
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
                        .overlay(alignment: .bottomTrailing) {
                            // user status
                            switch self.authSessionStore.user?.userStatus {
                            case .online:
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(Color.green)
                            case .offline:
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(Color.red)
                            case .inConvo:
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(Color.orange)
                            default:
                                EmptyView()
                            }
                        }
                } else {
                    ZStack {
                        // more animations on recording
                        Circle()
                            .foregroundColor(Color.orange.opacity(0.3))
                            .frame(width: 39, height: 39)
                            .scaleEffect(self.innerCircleVM.isRecording ? 1.3: 1)
                            .animation(self.innerCircleVM.isRecording ? Animation.easeIn(duration: 2).repeatForever(autoreverses: true) : .default, value: self.innerCircleVM.isRecording)
                        Circle()
                            .foregroundColor(Color.orange.opacity(0.5))
                            .frame(width: 39, height: 39)
                            .scaleEffect(self.innerCircleVM.isRecording ? 1.2: 1)
                            .animation(self.innerCircleVM.isRecording ? Animation.easeOut(duration: 2).repeatForever(autoreverses: true) : .default, value: self.innerCircleVM.isRecording)
                        Circle()
                            .foregroundColor(Color.orange)
                            .frame(width: 40, height: 40)
                            .scaleEffect(self.innerCircleVM.isRecording ? 1.1: 1)
                            .animation(self.innerCircleVM.isRecording ? Animation.easeInOut.repeatForever(autoreverses: false) : .default, value: self.innerCircleVM.isRecording)
                        
                        Image((self.authSessionStore.user?.avatar)!)
                            .resizable()
                            .scaledToFit()
                            .background(Color.teal.opacity(0.5))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .overlay(alignment: .topTrailing) {
                                // user status
                                UserStatusView(status: self.authSessionStore.user?.userStatus, size: 10)
                                    .scaleEffect(self.innerCircleVM.isRecording ? 0: 1)
                                
                                // animation on recording
                                Image(systemName: "waveform.circle.fill")
                                    .scaleEffect(self.innerCircleVM.isRecording ? 1: 0)
                                    .frame(width: 10)
                                    .foregroundColor(Color.orange)
                                    .animation(.spring())
                            }
                    }
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
                        self.innerCircleVM.toast = .circlesPreview
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
                        self.innerCircleVM.toast = .remoteWorkPreview
                        
                    } label: {
                        Label("teams", systemImage: "suitcase")
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
                        self.innerCircleVM.toast = .moreSpacesPreview
                        
                    } label: {
                        Label("more spaces", systemImage: "plus")
                            .labelStyle(.iconOnly)
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
