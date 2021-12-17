//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI

struct InnerCircleView: View {
    let universalSize = UIScreen.main.bounds
    
    // TESTING
    // users who will have a thumping thing because they sent a message
    @State var usersWithNewMessage: [Int] = []
    
    var body: some View {
        ZStack {
            // background
            WavesGlassBackgroundView()
            
            // content
            gridContent
            
            // header
            VStack(alignment: .leading) {
                header
                
                bubbleNavigation
                
                Spacer()
            }
            
//            Path { path in
//
//                //draw the axes
//                path.move(to: CGPoint(x:0, y:universalSize.height*0.5 ))
//
//                path.addLine(to: CGPoint(x:universalSize.width, y: universalSize.height*0.5))
//
//                path.move(to: CGPoint(x:universalSize.width*0.5, y:0 ))
//
//                path.addLine(to: CGPoint(x:universalSize.width * 0.5, y: universalSize.height))
//
//
//                //TODO: draw the acceptance boxes
//            }
//            .stroke(Color.black)
//            .edgesIgnoringSafeArea(.all)
            
            footerNavigation
        }
        .onAppear() {            
            // TESTING
            // fake like these users sent a message to view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.usersWithNewMessage = [1, 5, 10]
            }
        }
    }
    
    // TODO: do cool animations with this footer background fill in while
    // recording or playing a message
    var footerNavigation: some View {
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                HStack {
                    if self.selectedUserIndex != nil {
                        Image("Artboards_Diversity_Avatars_by_Netguru-\(self.selectedUserIndex! + 1)")
                            .resizable()
                            .scaledToFit()
                            .background(NirvanaColor.teal.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(5)
                    }
                    
                    
                    VStack (alignment: .leading) {
                        Text("Sarth Shah")
                            .font(.footnote)
                            .foregroundColor(NirvanaColor.light)
                        Text("sent 20 minutes ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Label("Replay", systemImage: "repeat.1.circle.fill")
                        .font(.title2)
                        .labelStyle(.iconOnly)
                        .foregroundColor(Color.orange)
                    
                    
                    Spacer(minLength: 65)
                }
                .frame(maxWidth: .infinity, maxHeight: 60) // 60 is the height of the footer control big circle
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
            }
            
            FooterControlsView()
        }
        .padding()
        .offset(
            x:0,
            y:self.selectedUserIndex == nil ? 150 : 0
        )
        .animation(Animation.spring(), value: self.selectedUserIndex)
    }
    
    var bubbleNavigation : some View {
        HStack(alignment: .center) {
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
        .padding(.horizontal)
    }
    
    // magic variables for grid
    // TODO: change the number of columns based on the number of items
    // TODO: make the top left person or one horizontal person be in the center of screen...makes the top honeycomb pop
    private static var numberOfItems: Int = 12
    private static let size: CGFloat = UIScreen.main.bounds.height*0.15 // scaling with screen size
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = Int(log2(Double(Self.numberOfItems))) // scaling the circles and calculating column count
    
    @State private var selectedUserIndex: Int? = nil
    
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
                    ForEach(0..<Self.numberOfItems) { value in
                        GeometryReader {gridProxy in
                            let scale = getScale(proxy: gridProxy, itemNumber: value)
                            
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .foregroundColor(self.getBubbleTint(userIndex: value)) // different color for a selected user
                                    .blur(radius: 8)
                                    .cornerRadius(100)
                                    
                                Image("Artboards_Diversity_Avatars_by_Netguru-\(value + 1)")
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
                            withAnimation {
                                // if user had previously selected user, put nil as a toggle
                                if self.selectedUserIndex == value {
                                    self.selectedUserIndex = nil
                                } else {
                                    self.selectedUserIndex = value
                                }
                            }
                            
                            print("the selected item is: \(value)")
                        }
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: self.usersWithNewMessage)
                        .animation(Animation.spring())
                    }
                } // lazyvgrid
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
     
    private func getBubbleTint(userIndex: Int) -> Color {
        if (userIndex == self.selectedUserIndex) { // user clicked on this user
            return NirvanaColor.dimTeal.opacity(0.4)
        } else if self.usersWithNewMessage.contains(userIndex) { // this user has a message
            return Color.orange.opacity(0.8)
        }
      
        return Color.white.opacity(0.4)
    }
    
    // getting the proxy of an individual item
    // and decoding into a scale that the item should take
    private func getScale(proxy: GeometryProxy, itemNumber: Int) -> CGFloat {
        // if this user is selected
        if itemNumber == self.selectedUserIndex {
            return big + 0.2
        }
        
        // if this user that we are rendering
        // has a new message for us
        // TODO: too much memory usage doing this across the board
        if self.usersWithNewMessage.contains(itemNumber) {
            return big + 0.2
        }
        
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
    
    private var header: some View {
        HStack(alignment: .center) {
            Image("undraw_handcrafts_leaf")
                .resizable()
                .frame(width: 20.0, height: 32.132)
                .padding(.leading, 20)
            
            Spacer()
            
            Image(systemName: "message.and.waveform")
                .foregroundColor(Color.red.opacity(1))
                .font(.title2)
            
            Menu {
                Button("Log out") {
                    print("log out button clicked")
                }
                Button("Friends") {
                    print("manage friends page")
                }
            } label: {
                Image("Artboards_Diversity_Avatars_by_Netguru-51")
                    .resizable()
                    .scaledToFit()
                    .background(NirvanaColor.teal.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(5)
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
        .padding(.horizontal)
    }
}

struct InnerCircleView_Previews: PreviewProvider {
    static var previews: some View {
        InnerCircleView()
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
