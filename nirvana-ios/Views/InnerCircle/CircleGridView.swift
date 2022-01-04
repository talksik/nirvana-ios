//
//  CircleGridView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack
import AVKit
import AlertToast

struct CircleGridView: View {
    @EnvironmentObject var innerCircleVM: InnerCircleViewModel
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var convoVM: ConvoViewModel
    
    @GestureState var dragState = DragState.inactive
    
    let universalSize = UIScreen.main.bounds
    
    // magic variables for grid
    // TODO: make the top left person or one horizontal person be in the center of screen...makes the top honeycomb pop
    @State var numberOfItems: Int = 12
    private static let size: CGFloat = 130 // TODO: scaling with screen size? nahhh no need
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = 3 // scaling the circles and calculating column count
    
    // TODO: change the size to adaptive or something to make outer ring items shrink their overall size and fit better
    let gridItems: [GridItem] = Array(
        repeating: GridItem(.fixed(Self.size), spacing: spacingBetweenColumns, alignment: .center),
        count: totalColumns)
    
    @Binding var selectedFriendIndex: String?
    @State var lastPersonIdSentMessageTo: String?
    
    private let big:CGFloat = 1
    private let medium:CGFloat = 0.9
    private let small:CGFloat = 0.8
    private let supersmall:CGFloat = 0.7
    
    // TODO: centered honeycomb + side: maybe have two honeycombs: one in the center of 7 people and then everyone else surrounding
    // TODO: maybe make our "center" offset to a little to the top left to make it more honeycomb from top left
    private let center: CGPoint = CGPoint(x: UIScreen.main.bounds.width*0.5,y: UIScreen.main.bounds.height*0.5)
    
    let longPressMinDuration = 0.5
    
    @State var alertActive = false
    @State var alertText = ""
    @State var alertSubtext = ""
    
    @State var animateLiveConvos = false
    
    let maxNumAvatarsToShowInConvo = 3
    
    enum GridItemType: String {
        case convo
        case activeFriend
        case inboxUser
        case staleState
    }
    
    @State var initialGridId = "initial"
    
    var body: some View {
        // main communication hub
        // TODO: client side, sort the honeycomb from top left to bottom right
        // based on most close friends to least
        
        // MARK: data entry point
        let activeFriends = self.authSessionStore.friendsArr
        let inboxUsers = self.authSessionStore.inboxUsersArr
        let convos = self.convoVM.relevantConvos
        
        ScrollViewReader {scrollReaderValue in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: gridItems,
                    alignment: .center,
                    spacing: Self.spacingBetweenRows
                ) {
                    // live convos
                    ForEach(0..<convos.count, id: \.self) {value in
                        let currConvo = self.convoVM.relevantConvos[value]
                        let filteredUsers = self.authSessionStore.relevantUsersDict.filter {
                            return currConvo.users.contains($0.key)
                        }
                        let convoUsers: [User] = Array(filteredUsers.values)
                        
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: value, userId: nil, convoId: currConvo.id)
                                                        
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .foregroundColor(self.getBubbleTint(convoId: currConvo.id))
                                
                                ZStack {
                                    Color.clear
                                    ProfilePicturesOverlappedView(users: Array(convoUsers.prefix(maxNumAvatarsToShowInConvo)))
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 20)
                                }
                                
                                // top right number or people in convo
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.green)
                                    .font(.title2)
                                    .padding(5)
                                    .overlay(
                                        Text("\(currConvo.users.count)")
                                            .foregroundColor(Color.white)
                                            .font(.caption2)
                                    )
                            }
                            .scaleEffect(scale)
                            .padding(scale * 5)
                        } // geometry reader
                        .offset(
                            x: honeycombOffSetX(value),
                            y: 0
                        )
                        .id("\(value)") // id for scrollviewreader
                        .frame(height: Self.size)
                        .onTapGesture {
                            // if not in a call already
                            if !self.convoVM.isInCall() {
                                print("joining convo now")
                                
                                if let convoId = currConvo.id {
                                    self.convoVM.selectedConvoId = convoId
                                    self.convoVM.joinConvo(convoId: convoId)
                                    
                                    // if had selected an individual, don't want them selected here anymore
                                    self.selectedFriendIndex = nil
                                }
                                else {
                                    print("no convo id to join")
                                }
                            }
                            else {
                                self.convoVM.toast = .alreadyInCall
                            }
                        }
//                        .animation(
//                            Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
//                           value: self.animateLiveConvos
//                        )
                        .animation(Animation.spring())
                    }
                    
                    /* ACTIVE FRIENDS */
                    ForEach(0..<activeFriends.count, id: \.self) {value in
                        let adjustedValue = value + convos.count
                        let friendId = activeFriends[value]
                        
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: adjustedValue, userId: friendId)
                            
                            ZStack(alignment: .topTrailing) {
                                // bubble color
                                Circle()
                                    .foregroundColor(self.getBubbleTint(friendDbId: friendId))
                                    .blur(radius: 8)
                                    .cornerRadius(100)
                                
                                if self.haveNewMessageFromFriend(friendDbId: friendId) {
                                    ProgressBarView(progress: self.selectedFriendIndex == friendId ? self.innerCircleVM.messagesListeningProgress : Float(1), color: Color.orange)
                                }
                                else if friendId == self.lastPersonIdSentMessageTo {  // show that I sent a message to the last person I sent a message to
                                    ProgressBarView(progress: self.innerCircleVM.toast == InnerCircleViewModel.Toast.clipSent ? Float(1) : Float(0), color: NirvanaColor.dimTeal)
                                }
                                
                                // user status
                                UserStatusView(status: self.authSessionStore.relevantUsersDict[friendId]?.userStatus, size: 20, padding: 5)

                                // inside avatar
                                Image(self.authSessionStore.relevantUsersDict[friendId]?.avatar ?? SystemImages.avatars[0])
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 20)
                            }
                            .scaleEffect(scale)
                            .padding(scale * 5)
                        } // geometry reader
                        .offset(
                            x: honeycombOffSetX(adjustedValue),
                            y: 0
                        )
                        .blur(radius: self.getBlur(friendDbId: friendId))
                        .id("\(adjustedValue)") // id for scrollviewreader
                        .frame(height: Self.size)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded{_ in
                                    self.handleTap(gridItemIndex: value, friendId: friendId)
                                }
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: longPressMinDuration)
                                .onEnded {_ in // on activation of long press
                                    print("activated long press!")
                                    
                                    self.activateHaptics()
                                    
                                    // stop any player still playing of a message
                                    self.innerCircleVM.stopPlayingAnyAudio()
                                    
                                    // if friend and I are online, and I am not in a convo, start convo immediately with them
                                    if self.authSessionStore.relevantUsersDict[friendId]?.userStatus == .online
                                        && self.authSessionStore.user?.userStatus == .online && !self.convoVM.isInCall() {
                                        print("starting a direct convo...getting it going")
                                        
                                        self.selectedFriendIndex = nil // deselect and clear up ui for the call
                                        
                                        self.convoVM.startConvo(friendId: friendId)
                                    } // if I am in a convo and I am adding someone else online, then make them join my convo
                                    else if self.convoVM.isInCall() && self.authSessionStore.relevantUsersDict[friendId]?.userStatus == .online {
                                        print("chaining the convo with more people...forcing someone else in")
                                        
                                        self.selectedFriendIndex = nil // deselect and clear up ui for the call
                                        
                                        self.convoVM.addThirdPartyToConvo(friendId: friendId)
                                    } // if I am in a convo and I long press on someone not online, send a clip which can include other peoples' voice
                                    else {
                                        self.selectedFriendIndex = friendId
                                        
                                        if self.convoVM.isInCall() {
                                            print("recoding a message and sending to this offline friend")
                                            
                                            self.convoVM.toast = .friendNotOnline
                                        }
                                        
                                        self.record()
                                    }
                                }
                                .sequenced(before:
                                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                  )
                                .updating(self.$dragState) { gestureValue, state, transaction in
//                                    print("in updating: \(gestureValue) \(state), \(transaction)")
                                    switch gestureValue {
                                    // Long press begins.
                                    case .first(true):
                                        state = .pressing
                                    // Long press confirmed, dragging may begin.
                                    case .second(true, let drag):
                                        state = .dragging(translation: drag?.translation ?? .zero)
                                    // Dragging ended or the long press cancelled.
                                    default:
                                        state = .inactive
                                    }
                                }
                                .onEnded { gestureValue in
                                    guard case .second(true, let drag?) = gestureValue else { return }
                                    
                                    // only stop recording if I was recording
                                    if self.innerCircleVM.isRecording {
                                        // stop recording
                                        print("stopping recording")
                                        
                                        self.lastPersonIdSentMessageTo = self.selectedFriendIndex
                                        self.selectedFriendIndex = nil
                                        
                                        self.innerCircleVM.stopRecording(sender: self.authSessionStore.user!, receiver: self.authSessionStore.relevantUsersDict[friendId]!)
                                        
    //                                    self.recordingGestureDeactived()
                                    }
                                }
                        )
                        .animation(Animation.spring())
                    }
                    
                    /* INBOX USERS */
                    ForEach(0..<inboxUsers.count, id: \.self) {inboxValue in
                        let inboxUserId = inboxUsers[inboxValue]
                        let adjustedValue = inboxValue + activeFriends.count + convos.count // IMPORTANT: accounting for the active friends iterations
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: adjustedValue, userId: inboxUserId) * 0.75 // don't want inbox to match size of active
                                                        
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "arrow.down.left.circle.fill")
                                    .foregroundColor(Color.orange)
                                    .font(.title)
                                
                                Circle()
                                    .foregroundColor(Color.orange.opacity(0.4))
                                    .blur(radius: 5)
                                    .cornerRadius(100)
                                    
                                Image(self.authSessionStore.relevantUsersDict[inboxUserId]?.avatar ?? SystemImages.avatars[0])
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 20)
                                    .blur(radius: 5)
                            }
                            .scaleEffect(scale)
                            .padding(scale * 5)
                        } // geometry reader
                        .offset(
                            x: honeycombOffSetX(adjustedValue),
                            y: 0
                        )
                        .id("\(adjustedValue)") // id for scrollviewreader
                        .frame(height: Self.size)
                        .onTapGesture {
                            // action to open alert to add this person to circle or reject
                            let inboxFriendName: String = self.authSessionStore.relevantUsersDict[inboxUserId]?.nickname ?? ""
                            let inboxFriendNumber: String = self.authSessionStore.relevantUsersDict[inboxUserId]?.phoneNumber ?? ""
                            
                            self.alertText = "🌴Add \(inboxFriendName) to your circle?"
                            self.alertSubtext = "\(inboxFriendName) started a convo with you... \n \(inboxFriendNumber) \n Remember: you have \(10 - activeFriends.count) spots left!"
                            self.alertActive.toggle()
                        }
                        .animation(Animation.spring())
                        .alert(isPresented: self.$alertActive) {
                            Alert(
                                title: Text(self.alertText),
                                message: Text(self.alertSubtext),
                                primaryButton: .destructive(Text("Reject"), action: {
                                    // create user friend but a rejected one
                                    self.innerCircleVM.activateOrDeactiveInboxUser(activate: false, userId: self.authSessionStore.user!.id!, friendId: inboxUserId)
                                }),
                                secondaryButton: .default(Text("Add"), action: {
                                    // create user friend if have space in circle
                                    // TODO: view models should be able to do this validation, need some way of view models to speak to each other
                                    if self.authSessionStore.friendsArr.count >= RuleBook.maxFriends {
                                        self.innerCircleVM.toast = .maxFriendsInCircle
                                        return
                                    }
                                    
                                    self.innerCircleVM.activateOrDeactiveInboxUser(activate: true, userId: self.authSessionStore.user!.id!, friendId: inboxUserId)
                                })
                            )
                        }
                    }
                    
                    // stale state for adding a contact
                    let staleAdjustedValue = activeFriends.count + inboxUsers.count + convos.count
                    GeometryReader {gridProxy in
                        let scale = getScale(proxy: gridProxy, itemNumber: staleAdjustedValue, userId: nil) * 0.75 // adjusting size as stale states should be the smallest
                        Button {
                            self.navigationStack.push(FindFriendsView())
                        } label: {
                            ZStack {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(NirvanaColor.dimTeal)
                                    .font(.largeTitle)
                                
                                Circle()
                                    .foregroundColor(Color.white.opacity(0.2))
                                    .blur(radius: 8)
                                    .cornerRadius(100)
                            }
                            .scaleEffect(scale)
                            .padding(scale * 5)
                        }
                        
                    } // geometry reader
                    .offset(
                        x: honeycombOffSetX(staleAdjustedValue),
                        y: 0
                    )
                    .id(staleAdjustedValue) // id for scrollviewreader
                    .frame(height: Self.size)
                    .animation(Animation.spring())
                                        
                } //lazygrid // TODO: add padding based on if we are on any cornering item to allow the bubble to enlargen
                .padding(.horizontal, Self.size + Self.spacingBetweenColumns)
                .id(initialGridId)
            }// scrollview
            .onAppear {
                // scrolling to middle of grid
                self.scrollProxy = scrollReaderValue
                self.scrollTo(location: .centerOfGrid)
                self.animateLiveConvos = true
            }
            .onReceive(self.authSessionStore.$messagesArr) {_ in
                
                print("new messages found!!!! on receive going to cache all messages to load them faster for you!")
                
                // TODO: might be including messages of inbox users? overloading memory?
                self.innerCircleVM.cacheIncomingMessages(friendMessagesDict: self.authSessionStore.relevantMessagesByUserDict)
            }
            .onChange(of: self.authSessionStore.friendsArr) {_ in
                // update the grid as arrays have changed
                self.initialGridId = UUID().uuidString
                
                // scrolling to middle of grid
                if self.authSessionStore.friendsArr.count > 0 {
                    let numItems = (activeFriends.count + inboxUsers.count + convos.count + 1)
                    scrollReaderValue.scrollTo(numItems / 2)
                }
            }// just not smooth so taking out
//            .onChange(of: self.selectedFriendIndex) {_ in
//                self.scrollTo(location: .selectedFriend)
//            }
        } // scrollview reader
    }
    
    @State private var scrollProxy: ScrollViewProxy?
    
    enum ScrollToLocation {
        case centerOfGrid
        case firstMessage
        case selectedFriend
    }
    
    private func scrollTo(location: ScrollToLocation) {
        if scrollProxy == nil {
            print("can't scroll, did not provide a scrollproxy")
            return
        }
        
        let numItems = self.authSessionStore.friendsArr.count + self.authSessionStore.inboxUsersArr.count + self.convoVM.relevantConvos.count + 1 // 1 for the stale state
        
        switch location {
        case .centerOfGrid:
            self.scrollProxy!.scrollTo(numItems / 2)
        case .firstMessage:
            //TODO: calculate this by iterating through
            print("not implemented to scroll")
            self.scrollProxy!.scrollTo(1)
        case .selectedFriend:
            if self.selectedFriendIndex == nil {
                print("can't scroll, no selected friend")
                return
            }
            
            if let indexOfFriend = self.authSessionStore.friendsArr.firstIndex(of: self.selectedFriendIndex!) {
                print("scrolling to \(indexOfFriend)")
                self.scrollProxy!.scrollTo(indexOfFriend, anchor: UnitPoint.center)
            } else {
                print("could not find friend to scroll to")
            }
        }
    }
    
    private func haveNewMessageFromFriend(friendDbId: String) -> Bool {
        if self.authSessionStore.user != nil {
            let userId = self.authSessionStore.user!.id // O(1) // currUser who is signed in
            
            // get most recent message in the convo and see who has spoken
            if let messagesRelatedToFriend = self.authSessionStore.relevantMessagesByUserDict[friendDbId] { // O(1)
                return messagesRelatedToFriend.first?.receiverId == userId
            }
        }
        
        return false
    }
    
    /**
     dynamic blur control based on if we are recording to a particular friend or not
     */
    private func getBlur(friendDbId: String) -> CGFloat {
        // if we have selected this user and we are recording currently, then don't want to blur this one at all
        if self.selectedFriendIndex == friendDbId {
            return 0
        }
        // if recording, and have someone selected, then want to blur everyone else
        else if self.innerCircleVM.isRecording && friendDbId != self.selectedFriendIndex {
            return 8
        }
        
        return 0
    }
    
    private func getBubbleTint(friendDbId: String) -> Color {
        // TODO: check if I listened to the message before or not
        if self.haveNewMessageFromFriend(friendDbId: friendDbId) { // this friend has a message for me
            return Color.orange.opacity(0.8)
        }
        
        if (friendDbId == self.selectedFriendIndex) { // user clicked on this user
            return NirvanaColor.dimTeal.opacity(0.4)
        }
      
        return NirvanaColor.dimTeal.opacity(0.2)
    }
    
    private func getBubbleTint(convoId: String?) -> Color {
        if convoId != nil && convoId == self.convoVM.selectedConvoId {
            return Color.green
        }
        
        return NirvanaColor.dimTeal.opacity(0.2)
    }
}

struct CircleGridView_Previews: PreviewProvider {
    static var previews: some View {
        CircleGridView(selectedFriendIndex: Binding.constant(nil)).environmentObject(AuthSessionStore())
            .environmentObject(InnerCircleViewModel())
    }
}


// extension for the bubble math for the grid
extension CircleGridView {
    // getting the proxy of an individual item
    // and decoding into a scale that the item should take
    private func getScale(proxy: GeometryProxy, itemNumber: Int, userId: String? = nil, convoId: String? = nil) -> CGFloat {
        // if this user is selected
        if userId != nil && userId == self.selectedFriendIndex {
            
            // make it even bigger if we are recording
            if self.innerCircleVM.isRecording {
                return big + 1
            }
            
            return big + 0.2
        }
        
        if convoId != nil && convoId == self.convoVM.selectedConvoId {
            return big + 0.2
        }
        
        // if this user that we are rendering
        // has a new message for us
        // TODO: too much memory usage doing this across the board
//        if self.usersWithNewMessage.contains(itemNumber) {
//            return big + 0.2
//        }
        
        let posRelToGrid = proxy.frame(in: .global) // relative to the entire screen
        let midX = getRowNumber(itemNumber) % 2 == 0 ? posRelToGrid.midX + (Self.size / 2) + (Self.spacingBetweenColumns / 2) : posRelToGrid.midX
        let midY = posRelToGrid.midY
        
        let xdelta = abs(midX - self.center.x)
        let ydelta = abs(midY - self.center.y)
        
        let innerCircleXAcceptance = Self.size * 0.75
        let innerCircleYAcceptance = Self.size * 0.75
        let outerRingXAcceptance = self.universalSize.width * 0.4
        let outerRingYAcceptance = self.universalSize.height * 0.25
        let wayOutRingXAcceptance = self.universalSize.width * 0.425
        let wayOutRingYAcceptance = self.universalSize.height * 0.375
        
        
        if xdelta <= innerCircleXAcceptance && ydelta < innerCircleYAcceptance {
            return big
        } else if xdelta <= outerRingXAcceptance && ydelta < outerRingYAcceptance {
            return medium
        } else if xdelta <= wayOutRingXAcceptance && ydelta < wayOutRingYAcceptance {
            return small
        }
        return supersmall
    }
    
    private static func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDist = abs(p2.x - p1.x)
        let yDist = abs(p2.y - p2.y)
        
        return CGFloat(
            sqrt(
                pow(xDist, 2) + pow(yDist, 2)
            )
        )
    }
    //get row number given a value/item number in the list
    private func getRowNumber(_ value: Int) -> Int {
        return value / Self.totalColumns
    }
    private func honeycombOffSetX(_ value: Int) -> CGFloat {
        let rowNumber = self.getRowNumber(value)
        
        // make every even row have the honeycomb offset
        if rowNumber % 2 == 0 {
            return Self.size / 2 + Self.spacingBetweenColumns / 2 // account for the column spacing from before
        }
        
        return 0
    }
}

// extension for handling the gestures and actions
extension CircleGridView {
    // listening to messages
    private func handleTap(gridItemIndex: Int, friendId: String) {
        print("tap gesture activated")
        
        // don't want user tapping on someone if they are in a call, but they can send a message by pressing and holding
        if self.convoVM.isInCall() {
            self.convoVM.toast = .alreadyInCall
            return
        }
        
        // when deselecting, want to stop playing
        self.innerCircleVM.stopPlayingAnyAudio()
         
        // if user had previously selected user, put nil as a toggle
        if self.selectedFriendIndex == friendId {
            self.selectedFriendIndex = nil
            return
        } else {
            self.selectedFriendIndex = friendId
        }
        
        // I want to play the last x messages if I was the receiver...the array is sorted from backend so that the
        // most recent comes first
        // ["sarth": [ME, HIM...]] -> play nothing
        // ["sarth": [HIM, HIM, me, him...]] -> play his two messages
        
        // traverse through reversed list of messages and add to audio player queue
        var audioUrls: [URL] = []
        let messagesRelatedToFriend = self.authSessionStore.relevantMessagesByUserDict[friendId] ?? []
        
        if messagesRelatedToFriend.count == 0 {
            return
        }
        
        for message in messagesRelatedToFriend {
            // if it's starting to get to my messages then don't play
            if message.senderId == self.authSessionStore.user?.id {
                break
            }
            
            // only add to queue if we can convert the database url to a valid url here
            if let audioUrl = URL(string: message.audioDataUrl) {
                audioUrls.append(audioUrl)
            }
        }
        
        // plays everything from vm
        self.innerCircleVM.playAssets(audioUrls: audioUrls)
    }
    
    enum DragState {
            case inactive
            case pressing
            case dragging(translation: CGSize)
            
            var translation: CGSize {
                switch self {
                case .inactive, .pressing:
                    return .zero
                case .dragging(let translation):
                    return translation
                }
            }
            
            var isActive: Bool {
                switch self {
                case .inactive:
                    return false
                case .pressing, .dragging:
                    return true
                }
            }
            
            var isDragging: Bool {
                switch self {
                case .inactive, .pressing:
                    return false
                case .dragging:
                    return true
                }
            }
        }
    
    private func activateHaptics() {
        // haptics for recording
        print("got haptics on")
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.prepare()
        impactHeavy.impactOccurred()
    }
    
    private func record() {
        self.innerCircleVM.startRecording()
    }
    
    // TODO: fill in here
    private func recordingGestureDeactived() {
        
    }
}
