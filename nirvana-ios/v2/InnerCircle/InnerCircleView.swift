//
//  InnerCircleView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import SwiftUI

struct InnerCircleView: View {
    let universalSize = UIScreen.main.bounds
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
            content
        }
        .onAppear() {
            self.animateWaves = true
        }
    }
    
    // magiv variables for grid
    private static let size: CGFloat = 100
    private static let spacingBetweenColumns: CGFloat = 16
    private static let spacingBetweenRows: CGFloat = 16
    private static let totalColumns: Int = 10
    
    let frameSize: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5)
    
    @State private var selectedUserIndex = 0
    
    let gridItems: [GridItem] = Array(
        repeating: GridItem(.fixed(size), spacing: spacingBetweenColumns, alignment: .center),
        count: totalColumns)
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // header
            header
            
            // main communication hub
//            Circle()
//                .foregroundColor(Color.white.opacity(0.5))
//                .frame(width: universalSize.width * 0.75)
//                .frame(maxWidth: .infinity)
//                .blur(radius: 8)
                
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: gridItems,
                    alignment: .center,
                    spacing: Self.spacingBetweenRows
                ) {
                    
                    ForEach(1..<60) { value in
                        GeometryReader {gridProxy in
                            let posRelToGrid = gridProxy.frame(in: .global) // relative to the entire lazygrid
                            
                            Image("Artboards_Diversity_Avatars_by_Netguru-\(value)")
                                .resizable()
                                .scaledToFit()
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(100)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 20)
                                .scaleEffect(
                                    scale(
                                        x: isEvenRow(value) ? gridProxy.frame(in: .global).midX + gridProxy.size.width/2 :
                                            gridProxy.frame(in: .global).midX,
                                        y: gridProxy.frame(in: .global).midY,
                                        value: value%43
                                    )
                                )
                                .offset(
                                    x: honeycombOffSetX(value),
                                    y: 0
                                )
                                .onTapGesture {
                                    self.selectedUserIndex = value
                                    
                                    print("the selected item is: \(value)")
                                    
                                    let rowNumber = value / Self.totalColumns // 10 / 10
                                    
                                    print("the rownumber is: \(rowNumber)")
                                                                
                                    // make every even row have the honeycomb offset
                                    if rowNumber % 2 == 0 {
                                        print("the offset is \(Self.size / 2 + Self.spacingBetweenColumns / 2 )") // account for the column spacing from before
                                    } else {
                                        print("there is no offset")
                                    }
                                }
                                .animation(Animation.spring(), value: selectedUserIndex)
                            
                        }
                        .frame(height: Self.size)
                    }
                } // lazyvgrid
                .padding(.trailing, Self.size / 2 + Self.spacingBetweenColumns / 2)
            } // scrollview
            
            // navigation/footer
            
            Spacer()
        }
    }
    
    private func isEvenRow(_ value: Int) -> Bool {
        return (value / gridItems.count) % 2 == 0
    }
    
    private func slope(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return (p2.y - p1.y)/(p2.x - p1.x)
    }
    
    private func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDist = abs(p2.x - p1.x)
        let yDist = abs(p2.y - p2.y)
        
        return CGFloat(
            sqrt(
                pow(xDist, 2) + pow(yDist, 2)
            )
        )
    }
    
    func offsetY(proxy: GeometryProxy, factor: CGFloat) -> CGFloat {
            let y = proxy.frame(in: .global).midY

            if y < frameSize.y {
                return abs(y - frameSize.y) * factor
            }

            return -abs(y - frameSize.y) * factor

        }

        func offset(a: CGFloat, b: CGFloat, factor: CGFloat) -> CGFloat {
            return abs(a - b) * factor
        }

        func distance2(x: CGFloat, y: CGFloat, value: Int) -> CGFloat {
            //Fix crash with Slope
            let m = (frameSize.y - y)/(frameSize.x - x)


            let angle = abs(atan(m) * 180 / .pi)


            //print("Angle: ", angle, apps[value])
            //print("Slope: ", m, apps[value])
            let ipadAngle: CGFloat = 35

            if angle > ipadAngle {
                let y2 = (y > frameSize.y) ? frameSize.y*2 : 0
                let x2 = (y2 - y)/m + x
                //print(apps[value], x2, y2)
                return distance3(x: x2, y: y2, value: value)
            } else {
                let x2 = (x > frameSize.x) ? frameSize.x*2 : 0
                let y2 = m * (x2 - x) + y
                //print(apps[value], x2, y2)
                return distance3(x: x2, y: y2, value: value)
            }
        }

        func distance3(x: CGFloat, y: CGFloat, value: Int) -> CGFloat {
            let xDist = abs(x - frameSize.x)
            let yDist = abs(y - frameSize.y)

            return CGFloat(sqrt(xDist * xDist + yDist * yDist))
        }
    
    
    func scale(x: CGFloat, y: CGFloat, value: Int) -> CGFloat {
            let xDist = abs(x - frameSize.x)
            let yDist = abs(y - frameSize.y)

            let maxDistanceToCenter = distance2(x: x, y: y, value: value)//CGFloat(sqrt(frameSize.x * frameSize.x + frameSize.y * frameSize.y))
            let result = CGFloat(sqrt(xDist * xDist + yDist * yDist))

            //print("distance: \(apps[value]) ", result)
            //print("center: \(apps[value]) ", maxDistanceToCenter)
            let total = min(abs(result - maxDistanceToCenter), maxDistanceToCenter*0.7)

            let finalResult = total/(maxDistanceToCenter) * 1.4

            return finalResult
        }
    
    private func honeycombOffSetX(_ value: Int) -> CGFloat {
        let rowNumber = ceil(Double(value) / Double(Self.totalColumns)) // round up
        
        // make every even row have the honeycomb offset
        if Int(rowNumber) % 2 == 0 {
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
            
            Text("nirvana")
                .font(Font.custom("Satisfy-Regular", size: 28))
                .foregroundColor(NirvanaColor.teal)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Menu {
                Button("Log out") {
                    print("log out button clicked")
                }
                Button("Friends") {
                    print("manage friends page")
                }
            } label: {
                RemoteImage(url: "https://avatars.githubusercontent.com/u/41487836")
                    .background(NirvanaColor.teal)
                    .aspectRatio(contentMode: .fill)
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
