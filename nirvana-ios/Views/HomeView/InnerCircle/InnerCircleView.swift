//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI

struct InnerCircleView: View {
    let universalSize = UIScreen.main.bounds
    // y position of where waves should start
    let baseLineY = UIScreen.main.bounds.height * 0.95
    
    @State var animateWaves = false
    
    var body: some View {
        ZStack {
            // background
            ZStack {
                AngularGradient(
                    gradient: Gradient(
                        colors: [NirvanaColor.solidBlue, NirvanaColor.dimTeal, Color.orange, NirvanaColor.solidBlue]),
                    center: .center,
                    angle: .degrees(120))
                 
                LinearGradient(gradient: Gradient(
                    colors: [NirvanaColor.white.opacity(0), NirvanaColor.white.opacity(1.0)]), startPoint: .bottom, endPoint: .top)
                
                getWave(peakPercentage: 0.4, troughPercentage: 0.65, peakAltercation: baseLineY + 100, troughAltercation: baseLineY - 90)
                    .foregroundColor(NirvanaColor.dimTeal.opacity(0.5))
                    .blur(radius:2)
                    .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                    .animation(
                        Animation.linear(duration: 20).repeatForever(autoreverses: false)
                    )
                
                getWave(peakPercentage: 0.2, troughPercentage: 0.75, peakAltercation: baseLineY - 50, troughAltercation: baseLineY + 100)
                    .foregroundColor(Color.orange.opacity(0.3))
                    .blur(radius:2)
                    .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                    .animation(
                        Animation.linear(duration: 10).repeatForever(autoreverses: false)
                    )
                
                getWave(peakPercentage: 0.25, troughPercentage: 0.75, peakAltercation: baseLineY + 70, troughAltercation: baseLineY - 100)
                    .foregroundColor(NirvanaColor.teal.opacity(0.3))
                    .blur(radius:2)
                    .offset(x: self.animateWaves ? -1*universalSize.width : 0)
                    .animation(
                        Animation.linear(duration: 12).repeatForever(autoreverses: false)
                    )
    
            }
            .ignoresSafeArea(.all)
            
            // content
            gridContent
            
            // inner circle
//            Rectangle()
//                .foregroundColor(Color.white.opacity(0.5))
//                .frame(width:universalSize.width*0.65, height: universalSize.height*0.3)
//            // outer circle
//            Rectangle()
//                .foregroundColor(Color.white.opacity(0.5))
//                .frame(width:universalSize.width*0.75, height: universalSize.height*0.15)
            //way out circle
//            Ellipse()
//                .foregroundColor(Color.white)
//                .frame(width:universalSize.width*0.65, height: universalSize.height*0.3)
            
            // header
            ZStack(alignment: .top) {
                //TODO: find a better solution than hacking it like this
                Color.clear
                
                header
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
            
            ZStack(alignment: .bottom) {
                //TODO: find a better solution than hacking it like this
                Color.clear
                
                FooterControlsView()
            }
           
        }
        .onAppear() {
            self.animateWaves = true
        }
    }
    
    // magic variables for grid
    // TODO: change the number of columns based on the number of items
    private static var numberOfItems: Int = 20
    private static let size: CGFloat = 80
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = Int(log2(Double(Self.numberOfItems))) // scaling the circles and calculating column count
    
    @State private var selectedUserIndex = 0
    
    // TODO: change the size to adaptive or something to make outer ring items shrink their overall size and fit better
    let gridItems: [GridItem] = Array(
        repeating: GridItem(.fixed(Self.size), spacing: spacingBetweenColumns, alignment: .center),
        count: totalColumns)
    
    private let big:CGFloat = 1
    private let medium:CGFloat = 0.85
    private let small:CGFloat = 0.5
    private let supersmall:CGFloat = 0.3
    
    private let center: CGPoint = CGPoint(x: UIScreen.main.bounds.width*0.5,y: UIScreen.main.bounds.height*0.5)
    
    private var gridContent: some View {
        // main communication hub
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
                            
                            ZStack {
                                Circle()
                                    .foregroundColor(Color.white.opacity(0.4))
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
                            self.selectedUserIndex = value
                            
                            withAnimation(Animation.spring()) {
                                scrollReaderValue.scrollTo(value, anchor: .top)
                            }
                            print("the selected item is: \(value)")
                        }
                        .animation(Animation.spring())
                    }
                } // lazyvgrid
                .padding(.trailing, Self.size / 2 + Self.spacingBetweenColumns / 2) // because of the offset of last column
                .padding(.top, Self.size / 2 + Self.spacingBetweenRows / 2) // because we are going under the nav bar
            }// scrollview
            .onAppear {
                scrollReaderValue.scrollTo(Self.numberOfItems / 2)
            }
        } // scrollview reader
    }
    
    // getting the proxy of an individual item
    // and decoding into a scale that the item should take
    private func getScale(proxy: GeometryProxy, itemNumber: Int) -> CGFloat {
        
        let posRelToGrid = proxy.frame(in: .global) // relative to the entire screen
        let midX = getRowNumber(itemNumber) % 2 == 0 ? posRelToGrid.midX + (Self.size / 2) + (Self.spacingBetweenColumns / 2) : posRelToGrid.midX
        let midY = posRelToGrid.midY
        
        let xdelta = abs(midX - self.center.x)
        let ydelta = abs(midY - self.center.y)
        
        let innerCircleXAcceptance = Self.size
        let innerCircleYAcceptance = Self.size * 0.75
        let outerRingXAcceptance = self.universalSize.width * 0.4
        let outerRingYAcceptance = self.universalSize.height * 0.3
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
            
            Text("nirvana")
                .font(Font.custom("Satisfy-Regular", size: 28))
                .foregroundColor(NirvanaColor.teal)
                .multilineTextAlignment(.center)
            
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
    
    private func getWave(peakPercentage: Double, troughPercentage: Double, peakAltercation: CGFloat, troughAltercation: CGFloat) -> Path {
        Path {path in
            path.move(
                to: CGPoint(
                    x: 0,
                    y: baseLineY
                )
            )

            path.addCurve(
                to: CGPoint(x: universalSize.width, y: baseLineY),
                control1: CGPoint(x: universalSize.width * peakPercentage, y: peakAltercation),
                control2: CGPoint(x: universalSize.width * troughPercentage, y: troughAltercation))
            
            path.addCurve(
                to: CGPoint(x: 2*universalSize.width, y: baseLineY),
                control1: CGPoint(x: universalSize.width * (1 + peakPercentage), y: peakAltercation),
                control2: CGPoint(x: universalSize.width * (1 + troughPercentage), y: troughAltercation))
            
            
            path.addLine(to: CGPoint(x: 2*universalSize.width, y: universalSize.height))
            path.addLine(to: CGPoint(x: 0, y: universalSize.height))
        }
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
