//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI
import NavigationStack

enum SheetView : Identifiable {
    var id: Self { self }
    case contacts
    case inbox
}

struct InnerCircleView: View {
    @StateObject var innerCircleVM: InnerCircleViewModel = InnerCircleViewModel()
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    
    @State var sheetView: SheetView? = nil
    
    @State var selectedFriendIndex: Int? = nil
    
    let universalSize = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            // background
            WavesGlassBackgroundView()
            
            // content
            CircleGridView(selectedFriendIndex: self.$selectedFriendIndex)
                .environmentObject(innerCircleVM)
            
            // header
            VStack(alignment: .leading) {
                
                CircleNavigationView(sheetView: self.$sheetView)
                
                Spacer()
            }
            
            CircleFooterView(selectedFriendIndex: self.$selectedFriendIndex)
        }
        .sheet(item: self.$sheetView) {page in
            switch page {
            case SheetView.contacts:
                FindFriendsView()
            case SheetView.inbox:
                InboxView()// test one for now
            default:
                Text("asdf")
            }
            
        }
        .onAppear() {
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
