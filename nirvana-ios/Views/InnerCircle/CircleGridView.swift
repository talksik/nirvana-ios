//
//  CircleGridView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack
import AVKit

struct CircleGridView: View {
    @EnvironmentObject var innerCircleVM: InnerCircleViewModel
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var convoVM: ConvoViewModel
    
    @State var queuePlayer = AVQueuePlayer()
    @State var timeObserverToken: Any?
    
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
                                        Text("\(convoUsers.count)")
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
                        .id(currConvo.id) // id for scrollviewreader
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
                        }
//                        .animation(
//                            Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
//                           value: self.animateLiveConvos
//                        )
                        .animation(Animation.spring())
                    }
                    
                    // active friends
                    ForEach(0..<activeFriends.count, id: \.self) {value in
                        let adjustedValue = value + convos.count
                        let friendId = activeFriends[value]
                        
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: adjustedValue, userId: friendId)
                            
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .foregroundColor(self.getBubbleTint(friendDbId: friendId)) // different color for a selected user
                                    .blur(radius: 8)
                                    .cornerRadius(100)
                                
                                // this friend is online
                                if self.authSessionStore.relevantUsersDict[friendId]?.userStatus == .online {
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color.green)
                                        .font(.title2)
                                        .padding(5)
                                }
                                else if self.haveNewMessageFromFriend(friendDbId: friendId) { // check if the last message in the conversation between me and my friend was me talking or him
                                    Image(systemName: "arrow.down.left.circle.fill")
                                        .foregroundColor(Color.orange)
                                        .font(.title2)
                                }
//
                                Image(self.authSessionStore.relevantUsersDict[friendId]?.avatar ?? Avatars.avatarSystemNames[0])
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
                        .id(friendId) // id for scrollviewreader
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
                                    // stop any player still playing of a message
                                    self.queuePlayer.removeAllItems()
                                    
                                    print("activated long press!")
                                    self.selectedFriendIndex = friendId
                                    
                                    // TODO: haptics stopped working again
                                    self.activateHaptics()
                                    
                                    self.record()
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
                                    
                                    // stop recording
                                    print("stopped recording")
                                    
                                    self.selectedFriendIndex = nil
                                    
                                    self.innerCircleVM.stopRecording(sender: self.authSessionStore.user!, receiver: self.authSessionStore.relevantUsersDict[friendId]!)
                                    
//                                    self.recordingGestureDeactived()
                                }
                        )
                        .animation(Animation.spring())
                    }
                    
                    // inbox users
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
                                    
                                Image(self.authSessionStore.relevantUsersDict[inboxUserId]?.avatar ?? Avatars.avatarSystemNames[0])
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
                        .id(inboxUserId) // id for scrollviewreader
                        .frame(height: Self.size)
                        .onTapGesture {
                            // action to open alert to add this person to circle or reject
                            let inboxFriendName = self.authSessionStore.relevantUsersDict[inboxUserId]?.nickname ?? ""
                            let inboxFriendNumber = self.authSessionStore.relevantUsersDict[inboxUserId]?.phoneNumber
                            
                            self.alertText = "🌴Add to your circle?"
                            self.alertSubtext = "\(inboxFriendName ?? "") started a convo with you... \n \(inboxFriendNumber ?? "") \n Remember: you have \(10 - activeFriends.count) spots left!"
                            self.alertActive.toggle()
                        }
                        .animation(Animation.spring())
                        .alert(isPresented: self.$alertActive) {
                            Alert(
                                title: Text(self.alertText),
                                message: Text(self.alertSubtext),
                                primaryButton: .destructive(Text("Reject"), action: {
                                    // create user friend but a rejected one
                                    if self.authSessionStore.friendsArr.count < 10 || self.authSessionStore.user?.phoneNumber == "+19499230445" {
                                        self.innerCircleVM.activateOrDeactiveInboxUser(activate: false, userId: self.authSessionStore.user!.id!, friendId: inboxUserId) { res in
                                            print(res)
                                        }
                                    }
                                }),
                                secondaryButton: .default(Text("Add"), action: {
                                    // create user friend
                                    self.innerCircleVM.activateOrDeactiveInboxUser(activate: true, userId: self.authSessionStore.user!.id!, friendId: inboxUserId) { res in
                                        print(res)
                                    }
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
                    .id(UUID().uuidString) // id for scrollviewreader
                    .frame(height: Self.size)
                    .animation(Animation.spring())
                                        
                } //lazygrid // TODO: add padding based on if we are on any cornering item to allow the bubble to enlargen
                .padding(.trailing, Self.size / 2 + Self.spacingBetweenColumns / 2) // because of the offset of last column
                .padding(.top, Self.size / 2 + Self.spacingBetweenRows / 2) // because we are going under the nav bar
            }// scrollview
            .onAppear {
                // scrolling to first person in grid
                if self.authSessionStore.friendsArr.count > 0 {
                    scrollReaderValue.scrollTo(self.selectedFriendIndex)
                }
                
                self.animateLiveConvos = true
            }
        } // scrollview reader
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
            return NirvanaColor.teal.opacity(0.7)
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
        
        // if friend and I are online, start convo immediately with them
        if self.authSessionStore.relevantUsersDict[friendId]?.userStatus == .online
            && self.authSessionStore.user?.userStatus == .online {
            self.convoVM.startConvo(friendId: friendId)
            
            return
        }
        
        // TODO: if I am in a call and I am adding someone else online, then make them join my convo
        
        // clearing the player to make room for this friend's convo or to deselect this user
        self.queuePlayer.removeAllItems()
         
        // if user had previously selected user, put nil as a toggle
        if self.selectedFriendIndex == friendId {
            self.selectedFriendIndex = nil
            return
        } else {
            self.selectedFriendIndex = friendId
        }
        
        // TODO: OPTIMIZATION...buffer and load all AVAssets to create AVPlayerItems before a tap happens...but this can also cause load in background if user is not playing a message right now...this isn't an optimization of the data/firestore but rather the player
        
        // I want to play the last x messages if I was the receiver...the array is sorted from backend so that the
        // most recent comes first
        // ["sarth": [ME, HIM...]] -> play nothing
        // ["sarth": [HIM, HIM, me, him...]] -> play his two messages
        
        // traverse through reversed list of messages and add to audio player queue
        // TODO: protect against force unwraps
        var AVPlayerItems: [AVPlayerItem] = []
        var AVAssets: [AVAsset] = []
        let messagesRelatedToFriend = self.authSessionStore.relevantMessagesByUserDict[friendId] ?? []
        
        if messagesRelatedToFriend.count == 0 {
            return
        }
        
        for message in messagesRelatedToFriend {
            print("message: the sender is \(message.senderId) and senttime: \(message.sentTimestamp)")
            // if it's starting to get to my messages then don't play
            if message.senderId == self.authSessionStore.user?.id {
                break
            }
            
            // only add to queue if we can convert the database url to a valid url here
            if let audioUrl = URL(string: message.audioDataUrl) {
                let playerMessage: AVPlayerItem = AVPlayerItem(url: audioUrl)
                let playerAsset: AVAsset = AVAsset(url: audioUrl)
                AVAssets.append(playerAsset)
                AVPlayerItems.append(playerMessage)
            }
        }
        
        // start playing if there are messages to listen to
        if AVPlayerItems.count > 0 {
            print("have \(AVPlayerItems.count) messages to play")
            
            // reverse the items because we want to listen to the most recent messages in order
            AVPlayerItems = AVPlayerItems.reversed()
            queuePlayer = AVQueuePlayer(items: AVPlayerItems)
            
            // TODO: make sure these options are viable for different scenarios
            queuePlayer.automaticallyWaitsToMinimizeStalling = false
            queuePlayer.playImmediately(atRate: 1)
//                                queuePlayer.play()
            
            print("player queued up items!!!")
            
            // notify every half second
//            let timeScale = CMTimeScale(NSEC_PER_SEC)
//            let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
            
//            timeObserverToken = queuePlayer.addPeriodicTimeObserver(forInterval: time, queue: .main) {time in
//                // update player transport UI
//                print("periodic time observer: \(time)")
//                // if the current playeritem is the latest one:
//                // 1. deselect this user
//                // 2. update databse that I listened to this
//                if queuePlayer.currentItem == AVPlayerItems.last {
//                    // hide the footer now...ehhh don't need to
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////                        self.selectedFriendIndex = nil
////                    }
//                }
//            }
            
            // TODO: right now not updating all of that
            // update the listencount and firstlistentimestamp of those messages in firestore
            // this should update ui to show that there is no message to show
        }
    }
    
    
    
    func addBoundaryTimeObserver(playerAssets: [AVAsset]) {
        var totalDuration = CMTime.zero
        for item in playerAssets {
            print(item.duration)
            totalDuration = CMTimeAdd(item.duration, totalDuration)
        }
        print(totalDuration)
        
        // Divide the total duration into quarters.
        let interval = CMTimeMultiplyByFloat64(totalDuration, multiplier: 0.95)
        var currentTime = CMTime.zero
        var times = [NSValue]()

        // Calculate boundary times
        while currentTime < totalDuration {
            currentTime = currentTime + interval
            times.append(NSValue(time:currentTime))
        }

        print(times)
        
        timeObserverToken = queuePlayer.addBoundaryTimeObserver(forTimes: times,
                                                           queue: DispatchQueue.main) {
            // Update UI
            print("activated time boundary")
        }
        
    }
    
    func removeBoundaryTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.queuePlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
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
