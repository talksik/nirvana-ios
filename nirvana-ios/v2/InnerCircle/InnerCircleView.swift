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
            AngularGradient(
                gradient: Gradient(
                    colors: [NirvanaColor.solidBlue, NirvanaColor.dimTeal, Color.orange, NirvanaColor.solidBlue]),
                center: .center,
                angle: .degrees(120))
             
            LinearGradient(gradient: Gradient(
                colors: [NirvanaColor.white.opacity(0), NirvanaColor.white.opacity(1.0)]), startPoint: .bottom, endPoint: .top)
            
            // wave #1
            Path {path in
                path.move(
                    to: CGPoint(
                        x: 0,
                        y: baseLineY
                    )
                )

                path.addCurve(
                    to: CGPoint(x: universalSize.width, y: baseLineY),
                    control1: CGPoint(x: universalSize.width * 0.4, y: baseLineY + 150),
                    control2: CGPoint(x: universalSize.width * 0.65, y: baseLineY - 100))
                
                path.addCurve(
                    to: CGPoint(x: 2*universalSize.width, y: baseLineY),
                    control1: CGPoint(x: universalSize.width * 1.4, y: baseLineY + 150),
                    control2: CGPoint(x: universalSize.width * 1.65, y: baseLineY - 100))
                
                path.addLine(to: CGPoint(x: 2*universalSize.width, y: universalSize.height))
                path.addLine(to: CGPoint(x: 0, y: universalSize.height))

            }
            .foregroundColor(NirvanaColor.dimTeal.opacity(0.5))
            .blur(radius:2)
            .offset(x: self.animateWaves ? -1*universalSize.width : 0)
            .animation(
                Animation.linear(duration: 20).repeatForever(autoreverses: false)
            )
            
            // wave #2
            Path {path in
                path.move(
                    to: CGPoint(
                        x: 0,
                        y: baseLineY + 20
                    )
                )

                path.addCurve(
                    to: CGPoint(x: universalSize.width, y: baseLineY + 30),
                    control1: CGPoint(x: universalSize.width * 0.2, y: baseLineY - 50),
                    control2: CGPoint(x: universalSize.width * 0.75, y: baseLineY + 100))
                
                path.addCurve(
                    to: CGPoint(x: 2*universalSize.width, y: baseLineY),
                    control1: CGPoint(x: universalSize.width * 1.2, y: baseLineY - 50),
                    control2: CGPoint(x: universalSize.width * 1.75, y: baseLineY + 100))
                
                path.addLine(to: CGPoint(x: 2*universalSize.width, y: universalSize.height))
                path.addLine(to: CGPoint(x: 0, y: universalSize.height))

            }
            .foregroundColor(Color.orange.opacity(0.3))
            .blur(radius:2)
            .offset(x: self.animateWaves ? -1*universalSize.width : 0)
            .animation(
                Animation.linear(duration: 10).repeatForever(autoreverses: false)
            )
            
            // wave #3
            Path {path in
                path.move(
                    to: CGPoint(
                        x: 0,
                        y: baseLineY - 20
                    )
                )

                path.addCurve(
                    to: CGPoint(x: universalSize.width, y: baseLineY),
                    control1: CGPoint(x: universalSize.width * 0.25, y: baseLineY + 70),
                    control2: CGPoint(x: universalSize.width * 0.75, y: baseLineY - 100))
                
                path.addCurve(
                    to: CGPoint(x: 2*universalSize.width, y: baseLineY),
                    control1: CGPoint(x: universalSize.width * 1.25, y: baseLineY + 70),
                    control2: CGPoint(x: universalSize.width * 1.75, y: baseLineY - 100))
                
                
                path.addLine(to: CGPoint(x: 2*universalSize.width, y: universalSize.height))
                path.addLine(to: CGPoint(x: 0, y: universalSize.height))
            }
            .foregroundColor(NirvanaColor.teal.opacity(0.3))
            .blur(radius:2)
            .offset(x: self.animateWaves ? -1*universalSize.width : 0)
            .animation(
                Animation.linear(duration: 12).repeatForever(autoreverses: false)
            )
                
        }
        .onAppear() {
            self.animateWaves = true
        }
        .ignoresSafeArea(.all)
        
    }
}

struct InnerCircleView_Previews: PreviewProvider {
    static var previews: some View {
        InnerCircleView()
    }
}
