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
    
    @State var queuePlayer = AVQueuePlayer()
    @GestureState var dragState = DragState.inactive
    
    let universalSize = UIScreen.main.bounds
    
    // magic variables for grid
    // TODO: make the top left person or one horizontal person be in the center of screen...makes the top honeycomb pop
    private static var numberOfItems: Int = 12
    private static let size: CGFloat = UIScreen.main.bounds.height*0.15 // scaling with screen size
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = Int(log2(Double(Self.numberOfItems))) // scaling the circles and calculating column count
    
    @Binding var selectedFriendIndex: Int?
    
    // TODO: change the size to adaptive or something to make outer ring items shrink their overall size and fit better
    let gridItems: [GridItem] = Array(
        repeating: GridItem(.fixed(Self.size), spacing: spacingBetweenColumns, alignment: .center),
        count: totalColumns)
    
    private let big:CGFloat = 1
    private let medium:CGFloat = 0.75
    private let small:CGFloat = 0.5
    private let supersmall:CGFloat = 0.3
    
    // TODO: centered honeycomb + side: maybe have two honeycombs: one in the center of 7 people and then everyone else surrounding
    // TODO: maybe make our "center" offset to a little to the top left to make it more honeycomb from top left
    private let center: CGPoint = CGPoint(x: UIScreen.main.bounds.width*0.5,y: UIScreen.main.bounds.height*0.5)
    
    var body: some View {
        gridContent
    }
        
    let longPressMinDuration = 0.5
    
    private var gridContent: some View {
        // main communication hub
        // TODO: client side, sort the honeycomb from top left to bottom right
        // based on most close friends to least
        ScrollViewReader {scrollReaderValue in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: gridItems,
                    alignment: .center,
                    spacing: Self.spacingBetweenRows
                ) {
                    ForEach(Array(self.authSessionStore.friendsArr.enumerated()), id: \.offset) { value, friend in
//                    for (value, element) in self.authSessionStore.friendMessagesDict.keys.enumerated() {
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: value)
                            
                            // TODO: sort the list but may already be sorted from the query and creation of the array of messages?
                            // shouldn't be nil...hopefully
                            
                            ZStack(alignment: .topTrailing) {
                                // check if the last message in the conversation between me and my friend was me talking or him
                                // also check if I have listened to it once or twice
                                if self.haveNewMessageFromFriend(friendDbId: friend.id!) { // him talking
                                    Image(systemName: "wave.3.right.circle.fill")
                                        .foregroundColor(Color.orange)
                                        .font(.title)
                                }
                                
                                Circle()
                                    .foregroundColor(self.getBubbleTint(friendIndex: value, friendDbId: friend.id!)) // different color for a selected user
                                    .blur(radius: 8)
                                    .cornerRadius(100)
                                    
                                Image(friend.avatar ?? Avatars.avatarSystemNames[0])
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 20)
                            }
                            .scaleEffect(scale)
                            .padding(scale * 5)
                        } // geometry reader
                        .offset(
                            x: honeycombOffSetX(value),
                            y: 0
                        )
                        .id(value) // id for scrollviewreader
                        .frame(height: Self.size)
                        .onTapGesture {
                            self.handleTap(friendIndex: value, friend: friend)
                        }// TODO: maybe add simulataneous gesture or sequence? with the tap gesture?
                        .gesture(
                            LongPressGesture(minimumDuration: longPressMinDuration)
                                .onEnded {_ in // on activation of long press
                                    // stop any player still playing of a message
                                    self.queuePlayer.removeAllItems()
                                    
                                    print("activated long press!")
                                    self.selectedFriendIndex = value
                                    
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
                                    
                                    self.innerCircleVM.stopRecording(senderId: self.authSessionStore.user!.id!, receiverId: friend.id!)
                                    
//                                    self.recordingGestureDeactived()
                                }
                        )
//                        .simultaneousGesture(
//                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                .onChanged {_ in
//                                    self.recordingGestureActive(friendIndex: value, friend: friend)
//                                }
//                                .onEnded {_ in
//                                    self.recordingGestureDeactived()
//                                }
//                        )
                        .animation(Animation.spring())
                    }
                } // TODO: add padding based on if we are on any cornering item to allow the bubble to enlargen
                .padding(.trailing, Self.size / 2 + Self.spacingBetweenColumns / 2) // because of the offset of last column
                .padding(.top, Self.size / 2 + Self.spacingBetweenRows / 2) // because we are going under the nav bar
            }// scrollview
            .onAppear {
                //TODO: was causing problems so commenting out
                //may not need anymore with bottom nav activation
//                scrollReaderValue.scrollTo(Self.numberOfItems / 2)
            }
        } // scrollview reader
    }
    
    private func haveNewMessageFromFriend(friendDbId: String) -> Bool {
        if self.authSessionStore.user != nil {
            let userId = self.authSessionStore.user!.id // O(1) // currUser who is signed in
            
            // get most recent message in the convo and see who has spoken
            if let messagesRelatedToFriend = self.authSessionStore.friendMessagesDict[friendDbId] { // O(1)
                return messagesRelatedToFriend.first?.receiverId == userId
            }
        }
        
        return false
    }
    
    private func getBubbleTint(friendIndex: Int, friendDbId: String) -> Color {
        if (friendIndex == self.selectedFriendIndex) { // user clicked on this user
            return NirvanaColor.dimTeal.opacity(0.4)
        }
        else if self.haveNewMessageFromFriend(friendDbId: friendDbId) { // this user has a message
            return Color.orange.opacity(0.8)
        }
      
        return Color.white.opacity(0.4)
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
    private func getScale(proxy: GeometryProxy, itemNumber: Int) -> CGFloat {
        // if this user is selected
        if itemNumber == self.selectedFriendIndex {
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
    private func handleTap(friendIndex: Int, friend: User) {
        print("tap gesture activated")
        
        // clearing the player to make room for this friend's convo or to deselect this user
        self.queuePlayer.removeAllItems()
         
        // if user had previously selected user, put nil as a toggle
        if self.selectedFriendIndex == friendIndex {
            self.selectedFriendIndex = nil
            return
        } else {
            self.selectedFriendIndex = friendIndex
        }
        
        // TODO: OPTIMIZATION...buffer and load all AVAssets to create AVPlayerItems before a tap happens...but this can also cause load in background if user is not playing a message right now...this isn't an optimization of the data/firestore but rather the player
        
        // I want to play the last x messages if I was the receiver...the array is sorted from backend so that the
        // most recent comes first
        // ["sarth": [ME, HIM...]] -> play nothing
        // ["sarth": [HIM, HIM, me, him...]] -> play his two messages
        
        // traverse through reversed list of messages and add to audio player queue
        // TODO: protect against force unwraps
        var AVPlayerItems: [AVPlayerItem] = []
        let messagesRelatedToFriend = self.authSessionStore.friendMessagesDict[friend.id!] ?? []
        
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
            
            
            // TODO: right now not updating all of that
            // update the listencount and firstlistentimestamp of those messages in firestore
            // this should update ui to show that there is no message to show
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
        impactHeavy.impactOccurred()
    }
    
    private func record() {
        // call parent view model/environment object vm functions
        
        self.innerCircleVM.startRecording()
    }
    
    // TODO: fill in here
    private func recordingGestureDeactived() {
        
    }
}
